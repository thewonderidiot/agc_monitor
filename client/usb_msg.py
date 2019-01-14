from collections import namedtuple
import struct

WriteMessage = namedtuple('WriteMessage', ['group', 'addr', 'data'])
ReadMessage = namedtuple('ReadMessage', ['group', 'addr'])
DataMessage = namedtuple('DataMessage', ['group', 'addr', 'data'])

DATA_FMT = '>BHH'
READ_FMT = '>BH'

WRITE_FLAG = 0x80

class AddressGroup(object):
    Erasable = 0x00
    Fixed = 0x01
    Channels = 0x02
    SimErasable = 0x10
    SimFixed = 0x11
    Control = 0x20
    MonRegs = 0x21
    MonChannels = 0x22

class ControlReg(object):
    MNHRPT = 4
    MNHNC = 5
    NHALGA = 6

def pack_msg(msg):
    return globals()['_pack_' + type(msg).__name__](msg)

def _pack_WriteMessage(msg):
    return struct.pack(DATA_FMT, msg.group | WRITE_FLAG, msg.addr, msg.data)

def _pack_ReadMessage(msg):
    return struct.pack(READ_FMT, msg.group, msg.addr)

def unpack_msg(data):
    if len(data) != struct.calcsize(DATA_FMT):
        raise RuntimeError('Got message of size %u (only expecting data messages)' % len(data))

    fields = struct.unpack(DATA_FMT, data)
    return DataMessage(*fields)
