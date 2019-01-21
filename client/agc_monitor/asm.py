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
