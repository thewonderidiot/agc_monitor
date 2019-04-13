def disassemble(sqext, sqr, st):
    sq = (sqr >> 3) & 0o7
    qc = (sqr >> 1) & 0o3
    io = sqr & 0o7

    if st == 2:
        return 'STD2'
    elif not sqext:
        if sq == 0:
            if st == 1:
                opcode = 'GOJ'
            else:
                opcode = 'TC'
        elif sq == 1:
            if qc == 0:
                opcode = 'CCS'
            else:
                opcode = 'TCF'
        elif sq == 2:
            if qc == 0:
                opcode = 'DAS'
            elif qc == 1:
                opcode = 'LXCH'
            elif qc == 2:
                opcode = 'INCR'
            else:
                opcode = 'ADS'
        elif sq == 3:
            opcode = 'CA'
        elif sq == 4:
            opcode = 'CS'
        elif sq == 5:
            if qc == 0:
                if st == 3:
                    opcode = 'RSM'
                else:
                    opcode = 'NDX'
            elif qc == 1:
                opcode = 'DXCH'
            elif qc == 2:
                opcode = 'TS'
            else:
                opcode = 'XCH'
        elif sq == 6:
            opcode = 'AD'
        else:
            opcode = 'MSK'
    else:
        if sq == 0:
            if io == 0:
                opcode = 'READ'
            elif io == 1:
                opcode = 'WRITE'
            elif io == 2:
                opcode = 'RAND'
            elif io == 3:
                opcode = 'WAND'
            elif io == 4:
                opcode = 'ROR'
            elif io == 5:
                opcode = 'WOR'
            elif io == 6:
                opcode = 'RXOR'
            else:
                opcode = 'RUPT'
        elif sq == 1:
            if qc == 0:
                opcode = 'DV'
            else:
                opcode = 'BZF'
        elif sq == 2:
            if qc == 0:
                opcode = 'MSU'
            elif qc == 1:
                opcode = 'QXCH'
            elif qc == 2:
                opcode = 'AUG'
            else:
                opcode = 'DIM'
        elif sq == 3:
            opcode = 'DCA'
        elif sq == 4:
            opcode = 'DCS'
        elif sq == 5:
            opcode = 'NDXX'
        elif sq == 6:
            if qc == 0:
                opcode = 'SU'
            else:
                opcode = 'BZMF'
        else:
            opcode = 'MP'

    return opcode + str(st)

def format_addr(s, eb, fb, fext):
    # Determine which class of memory is being addressed by looking at S,
    # and further decode the address based on that
    if s < 0o1400:
        # Fixed-erasable memory addresses use only the value of S
        addr = '%04o' % s
    elif s < 0o2000:
        # Switched-erasable memory addresses display as EN,XXXX where N
        # is the EB number, *unless* the switched bank is also one of the
        # fixed banks, in which case the fixed-erasable notation is used
        if (eb < 3):
            addr = '%04o' % ((s-0o1400) + 0o400*eb)
        else:
            addr = 'E%o,%04o' % (eb, s)
    elif s < 0o4000:
        # Switched-fixed memory displays as NN,XXXX where NN is the FB
        # number, with the same fixed-fixed caveat as above.
        if fb in [0o2, 0o3]:
            addr = '%04o' % (0o4000 + (fb-0o3)*0o2000 + s)
        else:
            if (fb < 0o30) or (fext < 0o4):
                bank = fb
            else:
                bank = fb + (fext - 0o3)*0o10
            addr = '%02o,%04o' % (bank, s)
    else:
        # Fixed-fixed addresses also use only the value of S
        addr = '%04o' % s

    return addr

def unpack_word(word):
    parity = (word >> 14) & 0x1
    data = ((word & 0x8000) >> 1) | (word & 0x3FFF)
    return data, parity

def pack_word(data, parity):
    return (parity << 14) | ((data & 0x4000) << 1) | (data & 0x3FFF)
