#!/usr/bin/env python
import time
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST
from ctypes import *
import struct
from slip import unslip_from

STYX_VID = 0x2a19
STYX_PID = 0x1007

USB_VID_LIST.clear()
USB_VID_LIST.append(STYX_VID)

USB_PID_LIST.clear()
USB_PID_LIST.append(STYX_PID)

R1 = 21660.0
R2 = 1469.0

with Device() as dev:
    dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x00)
    dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x40)
    dev.ftdi_fn.ftdi_set_latency_timer(2)
    dev.ftdi_fn.ftdi_setflowctrl(0)
    dev.ftdi_fn.ftdi_usb_purge_buffers()

    while True:
        # dev.write('\xC0\xA0\x00\x64\x00\x01\xC0')
        dev.write('\xC0\x22\x00\x08\xC0')
        res = ''
        while not res:
            res = dev.read(64)
        data, rem = unslip_from(res)
        msg = struct.unpack('>BHH', data)
        print(msg)

        continue
        dev.write('\xC0\x20\x00\x63\xC0')
        res = ''
        while not res:
            res = dev.read(64)
        data, rem = unslip_from(res)
        msg = struct.unpack('>BHH', data)
        #temp = (msg[2] >> 4)*503.975/4096 - 273.15
        val = (msg[2] >> 4) / 4096
        print('%03x -> %.02f' % (msg[2]>>4, val*(R1+R2)/R2))

        time.sleep(0.1)

        # dev.write('\xC0\x20\x00\x61\xC0')
        # res = ''
        # while not res:
        #     res = dev.read(64)
        # data, rem = unslip_from(res)
        # msg = struct.unpack('>BHH', data)
        # vint = ((msg[2] >> 4)/4096.0)*3
        # time.sleep(0.1)

        # dev.write('\xC0\x20\x00\x62\xC0')
        # res = ''
        # while not res:
        #     res = dev.read(64)
        # data, rem = unslip_from(res)
        # msg = struct.unpack('>BHH', data)
        # vaux = ((msg[2] >> 4)/4096.0)*3

        # print('temp = %.02f, vccint = %.02f, vccaux = %.02f' % (temp, vint, vaux))
        # time.sleep(0.1)


        # dev.write('\xC0\xA0\x00\x04\x00\x00\xC0')
        # dev.write('\xC0\x20\x00\x04\xC0')
        # res = ''
        # while not res:
        #     res = dev.read(64).hex()
        # print(res)
        # time.sleep(0.1)
