COUNTERS = {
    0o24: 'TIME2',
    0o25: 'TIME1',
    0o26: 'TIME3',
    0o27: 'TIME4',
    0o30: 'TIME5',
    0o31: 'TIME6',
    0o32: 'CDUX',
    0o33: 'CDUY',
    0o34: 'CDUZ',
    0o35: 'CDUT',
    0o36: 'CDUS',
    0o37: 'PIPAX',
    0o40: 'PIPAY',
    0o41: 'PIPAZ',
    0o42: 'Q-RHCCTR',
    0o43: 'P-RHCCTR',
    0o44: 'R-RHCCTR',
    0o45: 'INLINK',
    0o46: 'RNRAD',
    0o47: 'GYROCMD',
    0o50: 'CDUXCMD',
    0o51: 'CDUYCMD',
    0o52: 'CDUZCMD',
    0o53: 'CDUTCMD',
    0o54: 'CDUSCMD',
    0o55: 'THRUST',
    0o56: 'LEMONM',
    0o57: 'OUTLINK',
    0o60: 'ALTM',
}

def disassemble_subinst(sqext, sqr, st):
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

def disassemble_inst(b, count):
    sq = b >> 12
    qc = (b >> 10) & 0o3
    s = b & 0o7777
    es = s & 0o1777

    if count:
        up = sq >> 3
        down = (sq >> 2) & 0o1
        name = COUNTERS[es]
        if name in ('TIME2', 'TIME1', 'TIME3', 'TIME4', 'TIME5'):
            return 'PINC', name
        elif name in ('TIME6', 'GYROCMD', 'CDUXCMD', 'CDUYCMD', 'CDUZCMD', 'CDUTCMD', 'CDUSCMD', 'THRUST', 'LEMONM'):
            return 'DINC', name
        elif name in ('CDUX', 'CDUY', 'CDUZ', 'CDUT', 'CDUS'):
            if down:
                return 'MCDU', name
            else:
                return 'PCDU', name
        elif name in ('INLINK', 'RNRAD'):
            if up:
                return 'SHANC', name
            else:
                return 'SHINC', name
        elif name in ('OUTLINK', 'ALTM'):
            return 'SHINC', name
        else:
            if up and down:
                return 'ZINC', name
            elif up:
                return 'PINC', name
            else:
                return 'MINC', name
    else:
        if sq == 0o0:
            if b == 0o3:
                return 'RELINT', ''
            elif b == 0o4:
                return 'INHINT', ''
            elif b == 0o6:
                return 'EXTEND', ''
            else:
                return 'TC', '%04o' % s
        elif sq == 0o1:
            if qc == 0o0:
                return 'CCS', '%04o' % es
            else:
                return 'TCF', '%04o' % s
        elif sq == 0o2:
            if qc == 0o0:
                return 'DAS', '%04o' % (es - 1)
            elif qc == 0o1:
                return 'LXCH', '%04o' % es
            elif qc == 0o2:
                return 'INCR', '%04o' % es
            else:
                return 'ADS', '%04o' % es
        elif sq == 0o03:
            return 'CA', '%04o' % s
        elif sq == 0o04:
            return 'CS', '%04o' % s
        elif sq == 0o05:
            if qc == 0:
                if s == 0o17:
                    return 'RESUME', ''
                else:
                    return 'INDEX', '%04o' % es
            elif qc == 0o1:
                return 'DXCH', '%04o' % (es - 1)
            elif qc == 0o2:
                return 'TS', '%04o' % es
            else:
                return 'XCH', '%04o' % es
        elif sq == 0o06:
            return 'AD', '%04o' % s
        elif sq == 0o07:
            return 'MASK', '%04o' % s
        elif sq == 0o10:
            io = (b >> 9) & 0o7
            ios = es & 0o777
            if io == 0o0:
                return 'READ', '%04o' % ios
            elif io == 0o1:
                return 'WRITE', '%04o' % ios
            elif io == 0o2:
                return 'RAND', '%04o' % ios
            elif io == 0o3:
                return 'WAND', '%04o' % ios
            elif io == 0o4:
                return 'ROR', '%04o' % ios
            elif io == 0o5:
                return 'WOR', '%04o' % ios
            elif io == 0o6:
                return 'RXOR', '%04o' % ios
            else:
                return 'RUPT', '%04o' % s
        elif sq == 0o11:
            if qc == 0o0:
                return 'DV', '%04o' % es
            else:
                return 'BZF', '%04o' % s
        elif sq == 0o12:
            if qc == 0o0:
                return 'MSU', '%04o' % es
            elif qc == 0o1:
                return 'QXCH', '%04o' % es
            elif qc == 0o2:
                return 'AUG', '%04o' % es
            else:
                return 'DIM', '%04o' % es
        elif sq == 0o13:
            return 'DCA', '%04o' % (s - 1)
        elif sq == 0o14:
            return 'DCS', '%04o' % (s - 1)
        elif sq == 0o15:
            return 'INDEX', '%04o' % s
        elif sq == 0o16:
            if qc == 0o0:
                return 'SU', '%04o' % es
            else:
                return 'BZMF', '%04o' % s
        else:
            return 'MP', '%04o' % s

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
