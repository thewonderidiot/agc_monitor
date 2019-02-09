import threading
import queue
import time
import warnings
from ctypes import *
from PySide2.QtCore import Signal, QObject, QTimer
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST, FtdiError

from slip import slip, unslip, unslip_from
import usb_msg as um

STYX_VID = 0x2a19
STYX_PID = 0x1007

POLL_PERIOD_MS = 20
POLL_DIVIDER = 2

class USBInterface(QObject, threading.Thread):
    connected = Signal(bool)

    def __init__(self):
        QObject.__init__(self)
        threading.Thread.__init__(self)

        # Clear the FTDI VID and PID lists and replace them with the Styx
        # PID and VID, so we will only match Styx boards
        USB_VID_LIST.clear()
        USB_VID_LIST.append(STYX_VID)

        USB_PID_LIST.clear()
        USB_PID_LIST.append(STYX_PID)

        self._dev = None
        self._tx_queue = queue.Queue()
        self._rx_queue = queue.Queue()
        self._connected = threading.Event()
        self._alive = threading.Event()
        self._alive.set()

        self._poll_msgs = []
        self._subscriptions = {}
        self._rx_bytes = b''
        self._poll_ctr = 0

        self._timer = QTimer(None)
        self._timer.timeout.connect(self._transmit_poll_msgs)
        self._timer.start(POLL_PERIOD_MS)

    def run(self):
        # Main run loop. Try to connect if we're not connected, otherwise
        # perform routine servicing
        while self._alive.isSet():
            if not self._connected.isSet():
                self._connect()
                time.sleep(0.5)
            else:
                self._service()

        # Clean up the device, if we managed to attach to it
        if self._dev:
            self._dev.flush()
            self._dev.close()

    def send(self, msg):
        print(msg)
        self._tx_queue.put(msg)

    def poll(self, msg):
        if msg not in self._poll_msgs:
            self._poll_msgs.append(msg)

    def subscribe(self, subscriber, msg_type):
        if msg_type in self._subscriptions:
            if subscriber not in self._subscriptions[msg_type]:
                self._subscriptions[msg_type].append(subscriber)
        else:
            self._subscriptions[msg_type] = [subscriber]

    def join(self, timeout=None):
        self._alive.clear()
        threading.Thread.join(self, timeout)

    def _transmit_poll_msgs(self):
        self._poll_ctr += 1
        if (self._poll_ctr >= POLL_DIVIDER):
            self._poll_ctr = 0

            if self._connected.isSet():
                for msg in self._poll_msgs:
                    self.send(msg)

        while not self._rx_queue.empty():
            msg = self._rx_queue.get_nowait()
            self._publish(msg)

    def _service(self):
        while not self._tx_queue.empty():
            msg = self._tx_queue.get_nowait()
            packed_msg = um.pack(msg)
            slipped_msg = slip(packed_msg)
            try:
                self._dev.write(slipped_msg)
            except:
                self._disconnect()
                return

        try:
            self._rx_bytes += self._dev.read(16)
        except:
            self._disconnect()
            return

        while self._rx_bytes != b'':
            msg_bytes, self._rx_bytes = unslip_from(self._rx_bytes)
            if msg_bytes == b'':
                break

            try:
                msg = um.unpack(msg_bytes)
            except:
                warnings.warn('Unknown message %s' % msg_bytes)
                continue

            self._rx_queue.put(msg)

    def _connect(self):
        if self._connected.isSet():
            return

        try:
            # Attempt to construct an FTDI Device
            self._dev = Device('MON001')

            # Reset the mode, then switch into serial FIFO
            self._dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x00)
            time.sleep(0.01)
            self._dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x40)

            # Set communication params
            self._dev.ftdi_fn.ftdi_set_latency_timer(2)
            self._dev.ftdi_fn.ftdi_setflowctrl(0)
            self._dev.ftdi_fn.ftdi_usb_purge_buffers()

            # Mark ourselves connected
            self._connected.set()
            self.connected.emit(True)

        except FtdiError:
            pass

    def _disconnect(self):
        if self._connected.isSet():
            self._connected.clear()
            self.connected.emit(False)

    def _publish(self, msg):
        if type(msg) in self._subscriptions:
            for subscriber in self._subscriptions[type(msg)]:
                subscriber.handle_msg(msg)
