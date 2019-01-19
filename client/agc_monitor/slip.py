import warnings

SLIP_END = b'\xC0'
SLIP_ESC = b'\xDB'
SLIP_ESC_END = b'\xDC'
SLIP_ESC_ESC = b'\xDD'

def slip(msg):
    # Escape ESC and END characters, and wrap the result with ENDs
    msg = msg.replace(SLIP_ESC, SLIP_ESC + SLIP_ESC_ESC)
    msg = msg.replace(SLIP_END, SLIP_ESC+SLIP_ESC_END)
    return SLIP_END + msg + SLIP_END

def unslip(msg):
    # Strip off the wrapping ENDs, and unescape ESCs and ENDs
    if (msg[0] != ord(SLIP_END)) or (msg[-1] != ord(SLIP_END)):
        raise RuntimeError('SLIPped message does not start and end with SLIP_END: %02x %02x' % (msg[0], msg[-1]))
    msg = msg[1:-1]
    msg = msg.replace(SLIP_ESC+SLIP_ESC_END, SLIP_END)
    msg = msg.replace(SLIP_ESC+SLIP_ESC_ESC, SLIP_ESC)
    return msg

def unslip_from(data):
    first_end = data.find(SLIP_END)
    if first_end == -1:
        return b'', b''
    elif first_end != 0:
        warnings.warn('Dropping %u bytes from data stream' % first_end)

    data = data[first_end:]
    non_end = 0
    for i, b in enumerate(data):
        if b != ord(SLIP_END):
            non_end = i
            break

    if non_end == 0:
        return b'', data

    next_end = data.find(SLIP_END, non_end)
    if next_end == -1:
        return b'', data

    return unslip(data[non_end-1:next_end+1]), data[next_end+1:]
