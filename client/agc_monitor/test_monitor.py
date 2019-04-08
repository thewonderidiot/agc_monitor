#!/usr/bin/env python
import time
from pylibftdi import Device, USB_PID_LIST, USB_VID_LIST
from ctypes import *
import struct
from slip import slip, unslip_from

STYX_VID = 0x2a19
STYX_PID = 0x1007

USB_VID_LIST.clear()
USB_VID_LIST.append(STYX_VID)

USB_PID_LIST.clear()
USB_PID_LIST.append(STYX_PID)

R1 = 21660.0
R2 = 1469.0

with Device('MON001') as dev:
    dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x00)
    dev.ftdi_fn.ftdi_set_bitmode(0xFF, 0x40)
    dev.ftdi_fn.ftdi_set_latency_timer(2)
    dev.ftdi_fn.ftdi_setflowctrl(0)
    dev.ftdi_fn.ftdi_usb_purge_buffers()

    done = False

    # dev.write('\xC0\xA0\x00\x40\x00\x01\xC0')
    # while not done:
    #     for i in range(0o2000):
    #         msg = slip(b'\x01' + struct.pack('>H', i))
    #         dev.write(msg)

    #     rx_bytes = b''
    #     while not done:
    #         rx_bytes += dev.read(128)

    #         while rx_bytes != b'':
    #             data, rx_bytes = unslip_from(rx_bytes)
    #             if data == b'':
    #                 break
    #             msg = struct.unpack('>BHH', data)
    #             print('%04o: %05o%o' % (msg[1], msg[2] >> 1, msg[2] & 1))
    #             if msg[1] == 0o1777:
    #                 done = True
    #                 break

    #     break

    dev.write('\xC0\x20\x00\x64\xC0')
    res = ''
    while not res:
        res = dev.read(64)
    data, rem = unslip_from(res)
    msg = struct.unpack('>BHH', data)
    #temp = (msg[2] >> 4)*503.975/4096 - 273.15
    v = (msg[2] >> 4) / 4096
    #r = 1173.0
    #t = r*(3.296/v - 1)
    r1 = 4700
    r2 = 1200
    x = v*(r1+r2)/r2
    print('%03x -> %f -> %f' % (msg[2]>>4, v, x))

        # time.sleep(0.1)

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
