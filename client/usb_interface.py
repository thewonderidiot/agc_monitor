import threading
import queue
import time
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST, FtdiError
from ctypes import *
from slip import slip, unslip
from usb_msg import WriteMessage, ReadMessage, DataMessage, pack_msg

STYX_VID = 0x2a19
STYX_PID = 0x1007

class USBInterface(threading.Thread):
    def __init__(self):
        super().__init__()

        USB_VID_LIST.clear()
        USB_VID_LIST.append(STYX_VID)

        USB_PID_LIST.clear()
        USB_PID_LIST.append(STYX_PID)

        self.dev = None
        self.queue = queue.Queue()
        self.connected = threading.Event()
        self.alive = threading.Event()
        self.alive.set()

    def run(self):
        while self.alive.isSet():
            if not self.connected.isSet():
                time.sleep(0.1)
            else:
                self._service()

        if self.dev:
            self.dev.flush()
            self.dev.close()

    def connect(self):
        if self.connected.isSet():
            return True

        try:
            self.dev = Device()
            self.dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x00)
            self.dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x40)
            self.dev.ftdi_fn.ftdi_set_latency_timer(2)
            self.dev.ftdi_fn.ftdi_setflowctrl(0)
            self.dev.ftdi_fn.ftdi_usb_purge_buffers()
            self.connected.set()
            return True
        except FtdiError:
            self.connected.clear()

        return False

    def write(self, group, addr, value):
        msg = WriteMessage(group, addr, value)
        self.queue.put(msg)

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

    def _service(self):
        time.sleep(0.01)
        while not self.queue.empty():
            msg = self.queue.get_nowait()
            packed_msg = pack_msg(msg)
            slipped_msg = slip(packed_msg)
            self.dev.write(slipped_msg)
