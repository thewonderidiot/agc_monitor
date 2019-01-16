import threading
import queue
import time
from ctypes import *
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST, FtdiError
from slip import slip, unslip
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
        self.queue = queue.Queue()
        self.connected = threading.Event()
        self.alive = threading.Event()
        self.alive.set()

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
        self.queue.put(msg)

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

    def _service(self):
        time.sleep(0.01)
        while not self.queue.empty():
            msg = self.queue.get_nowait()
            packed_msg = um.pack(msg)
            slipped_msg = slip(packed_msg)
            self.dev.write(slipped_msg)
