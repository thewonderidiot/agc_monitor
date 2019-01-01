#!/usr/bin/env python
import time
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST
from ctypes import *

STYX_VID = 0x2a19
STYX_PID = 0x1007

USB_VID_LIST.clear()
USB_VID_LIST.append(STYX_VID)

USB_PID_LIST.clear()
USB_PID_LIST.append(STYX_PID)

with Device() as dev:
    dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x00)
    time.sleep(0.1)
    dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x40)
    time.sleep(0.1)
    dev.ftdi_fn.ftdi_set_latency_timer(2)
    time.sleep(0.1)
    dev.ftdi_fn.ftdi_setflowctrl(0)
    time.sleep(0.1)
    dev.ftdi_fn.ftdi_usb_purge_buffers()
    time.sleep(0.1)

    while True:
        dev.write('\xC0\xA0\x00\x00\x00\x00\xC0')
        time.sleep(0.2)
        dev.write('\xC0\xA0\x00\x00\x00\x01\xC0')
        time.sleep(0.2)
