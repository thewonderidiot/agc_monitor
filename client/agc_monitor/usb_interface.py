import warnings
import queue
import time
from ctypes import *
from PySide2.QtCore import QObject, QThread, QTimer, Signal
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST, FtdiError

from slip import slip, unslip, unslip_from
import usb_msg as um

STYX_VID = 0x2a19
STYX_PID = 0x1007

POLL_PERIOD_MS = 20
POLL_DIVIDER = 2

class USBWorker(QObject):
    msg_received = Signal(object)
    connected = Signal(bool)

    def __init__(self):
        QObject.__init__(self)

        # Clear the FTDI VID and PID lists and replace them with the Styx
        # PID and VID, so we will only match Styx boards
        USB_VID_LIST.clear()
        USB_VID_LIST.append(STYX_VID)

        USB_PID_LIST.clear()
        USB_PID_LIST.append(STYX_PID)

        self._dev = None

        self._poll_msgs = []
        self._tx_queue = queue.Queue()
        self._rx_bytes = b''
        self._poll_ctr = 0

        self._timer = QTimer(None)
        self._timer.timeout.connect(self._service)
        self._timer.start(POLL_PERIOD_MS)

    def __del__(self):
        if self._dev:
            self._dev.flush()
            self._dev.close()

    def send_msg(self, msg):
        self._tx_queue.put(msg)

    def poll(self, msg):
        if msg not in self._poll_msgs:
            self._poll_msgs.append(msg)

    def _enqueue_poll_msgs(self):
        for msg in self._poll_msgs:
            self._tx_queue.put(msg)

    def _service(self):
        if self._dev is None:
            self._connect()
        else:
            self._enqueue_poll_msgs()
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
                self._rx_bytes += self._dev.read(4096)
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

                self.msg_received.emit(msg)

    def _connect(self):
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
            self.connected.emit(True)

        except FtdiError:
            pass

    def _disconnect(self):
        self.connected.emit(False)
        self._dev = None


class USBInterface(QObject):
    connected = Signal(bool)
    msg_sent = Signal(object)

    def __init__(self):
        QObject.__init__(self)

        self._thread = QThread()
        self._worker = USBWorker()
        self._worker.moveToThread(self._thread)
        self._thread.finished.connect(self._worker.deleteLater)
        self._worker.connected.connect(self.connected)
        self.msg_sent.connect(self._worker.send_msg)

    def start(self):
        self._thread.start()

    def close(self):
        self._thread.quit()
        self._thread.wait()

    def poll(self, msg):
        self._worker.poll(msg)

    def send(self, msg):
        self.msg_sent.emit(msg)

    def listen(self, listener):
        self._worker.msg_received.connect(listener.handle_msg)
