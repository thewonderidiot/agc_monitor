import threading
import queue
import time
import warnings
from ctypes import *
from PySide2.QtCore import QTimer
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST, FtdiError

from slip import slip, unslip, unslip_from
import usb_msg as um

STYX_VID = 0x2a19
STYX_PID = 0x1007

class USBInterface(threading.Thread):
    def __init__(self):
        super().__init__()

        # Clear the FTDI VID and PID lists and replace them with the Styx
        # PID and VID, so we will only match Styx boards
        USB_VID_LIST.clear()
        USB_VID_LIST.append(STYX_VID)

        USB_PID_LIST.clear()
        USB_PID_LIST.append(STYX_PID)

        self.dev = None
        self.tx_queue = queue.Queue()
        self.rx_queue = queue.Queue()
        self.connected = threading.Event()
        self.alive = threading.Event()
        self.alive.set()

        self.poll_msgs = []
        self.subscriptions = {}

        self.rx_bytes = b''

        self.timer = QTimer(None)
        self.timer.timeout.connect(self._transmit_poll_msgs)
        self.timer.start(20)

    def run(self):
        # Main run loop. Try to connect if we're not connected, otherwise
        # perform routine servicing
        while self.alive.isSet():
            if not self.connected.isSet():
                # FIXME: Try to auto-connect
                time.sleep(0.1)
            else:
                self._service()

        # Clean up the device, if we managed to attach to it
        if self.dev:
            self.dev.flush()
            self.dev.close()

    def connect(self):
        if self.connected.isSet():
            return True

        try:
            # Attempt to construct an FTDI Device
            self.dev = Device()

            # Reset the mode, then switch into serial FIFO
            self.dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x00)
            time.sleep(0.01)
            self.dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x40)

            # Set communication params
            self.dev.ftdi_fn.ftdi_set_latency_timer(2)
            self.dev.ftdi_fn.ftdi_setflowctrl(0)
            self.dev.ftdi_fn.ftdi_usb_purge_buffers()

            # Mark ourselves connected
            self.connected.set()
            return True

        except FtdiError:
            # No luck connecting/talking to the board; clear the connect status
            self.connected.clear()

        return False

    def send(self, msg):
        self.tx_queue.put(msg)

    def poll(self, msg):
        if msg not in self.poll_msgs:
            self.poll_msgs.append(msg)

    def subscribe(self, subscriber, msg_type):
        if msg_type in self.subscriptions:
            if subscriber not in self.subscriptions[msg_type]:
                self.subscriptions[msg_type].append(subscriber)
        else:
            self.subscriptions[msg_type] = [subscriber]

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

    def _transmit_poll_msgs(self):
        if self.connected.isSet():
            for msg in self.poll_msgs:
                self.send(msg)

        while not self.rx_queue.empty():
            msg = self.rx_queue.get_nowait()
            self._publish(msg)

    def _service(self):
        while not self.tx_queue.empty():
            msg = self.tx_queue.get_nowait()
            packed_msg = um.pack(msg)
            slipped_msg = slip(packed_msg)
            try:
                self.dev.write(slipped_msg)
            except:
                self.connected.clear()
                return

        try:
            self.rx_bytes += self.dev.read(256)
        except:
            self.connected.clear()
            return

        while self.rx_bytes != b'':
            msg_bytes, self.rx_bytes = unslip_from(self.rx_bytes)
            if msg_bytes == b'':
                break

            try:
                msg = um.unpack(msg_bytes)
            except:
                warnings.warn('Unknown message %s' % msg_bytes)
                continue

            self.rx_queue.put(msg)

    def _publish(self, msg):
        if type(msg) in self.subscriptions:
            for subscriber in self.subscriptions[type(msg)]:
                subscriber.handle_msg(msg)
