from PySide2.QtWidgets import QWidget, QStyleOption, QStyle, QPushButton
from PySide2.QtGui import QPainter, QPixmap
from PySide2.QtCore import Qt

from el_segment import ELSegment
from seven_segment import SevenSegment
from sign import Sign

import usb_msg as um

class DSKY(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        self._setup_ui()

        usbif.poll(um.ReadDSKYProg())
        usbif.poll(um.ReadDSKYVerb())
        usbif.poll(um.ReadDSKYNoun())
        usbif.poll(um.ReadDSKYReg1L())
        usbif.poll(um.ReadDSKYReg1H())
        usbif.poll(um.ReadDSKYReg2L())
        usbif.poll(um.ReadDSKYReg2H())
        usbif.poll(um.ReadDSKYReg3L())
        usbif.poll(um.ReadDSKYReg3H())

        usbif.subscribe(self, um.DSKYProg)
        usbif.subscribe(self, um.DSKYVerb)
        usbif.subscribe(self, um.DSKYNoun)
        usbif.subscribe(self, um.DSKYReg1L)
        usbif.subscribe(self, um.DSKYReg1H)
        usbif.subscribe(self, um.DSKYReg2L)
        usbif.subscribe(self, um.DSKYReg2H)
        usbif.subscribe(self, um.DSKYReg3L)
        usbif.subscribe(self, um.DSKYReg3H)

    def handle_msg(self, msg):
        if isinstance(msg, um.DSKYProg):
            self._prog[0].set_relay_bits(msg.digit1)
            self._prog[1].set_relay_bits(msg.digit2)
        elif isinstance(msg, um.DSKYVerb):
            self._verb[0].set_relay_bits(msg.digit1)
            self._verb[1].set_relay_bits(msg.digit2)
        elif isinstance(msg, um.DSKYNoun):
            self._noun[0].set_relay_bits(msg.digit1)
            self._noun[1].set_relay_bits(msg.digit2)
        elif isinstance(msg, um.DSKYReg1L):
            self._reg1[2].set_relay_bits(msg.digit3)
            self._reg1[3].set_relay_bits(msg.digit4)
            self._reg1[4].set_relay_bits(msg.digit5)
        elif isinstance(msg, um.DSKYReg1H):
            self._sign1.set_relay_bits(msg.sign)
            self._reg1[0].set_relay_bits(msg.digit1)
            self._reg1[1].set_relay_bits(msg.digit2)
        elif isinstance(msg, um.DSKYReg2L):
            self._reg2[2].set_relay_bits(msg.digit3)
            self._reg2[3].set_relay_bits(msg.digit4)
            self._reg2[4].set_relay_bits(msg.digit5)
        elif isinstance(msg, um.DSKYReg2H):
            self._sign2.set_relay_bits(msg.sign)
            self._reg2[0].set_relay_bits(msg.digit1)
            self._reg2[1].set_relay_bits(msg.digit2)
        elif isinstance(msg, um.DSKYReg3L):
            self._reg3[2].set_relay_bits(msg.digit3)
            self._reg3[3].set_relay_bits(msg.digit4)
            self._reg3[4].set_relay_bits(msg.digit5)
        elif isinstance(msg, um.DSKYReg3H):
            self._sign3.set_relay_bits(msg.sign)
            self._reg3[0].set_relay_bits(msg.digit1)
            self._reg3[1].set_relay_bits(msg.digit2)

    def _setup_ui(self):
        self.setObjectName('#DSKY')
        self.setWindowFlags(Qt.Window)
        self.setFixedSize(500,580)
        self.setStyleSheet('DSKY{background-image: url(:/resources/dsky.png);}')
        self.setWindowTitle('Monitor DSKY')

        el_pix = QPixmap(':/resources/el.png')

        self._acty = ELSegment(self, el_pix, 0, 1, 65, 61, False)
        self._acty.move(285, 36)
        self._perms = self._create_permanent_segments(el_pix)
        self._prog = self._create_mode(el_pix, 394, 60)
        self._verb = self._create_mode(el_pix, 287, 129)
        self._noun = self._create_mode(el_pix, 394, 129)
        self._sign1, self._reg1 = self._create_reg(el_pix, 287, 184)
        self._sign2, self._reg2 = self._create_reg(el_pix, 287, 239)
        self._sign3, self._reg3 = self._create_reg(el_pix, 287, 294)

        self._create_button(8,   404, 0b10001) # VERB
        self._create_button(8,   474, 0b11111) # NOUN
        self._create_button(78,  369, 0b11010) # +
        self._create_button(78,  439, 0b11011) # -
        self._create_button(78,  509, 0b10000) # 0
        self._create_button(148, 369, 0b00111) # 7
        self._create_button(148, 439, 0b00100) # 4
        self._create_button(148, 509, 0b00001) # 1
        self._create_button(218, 369, 0b01000) # 8
        self._create_button(218, 439, 0b00101) # 5
        self._create_button(218, 509, 0b00010) # 2
        self._create_button(288, 369, 0b01001) # 9
        self._create_button(288, 439, 0b00110) # 6
        self._create_button(288, 509, 0b00011) # 3
        self._create_button(359, 369, 0b11110) # CLR
        self._create_button(359, 439, None)    # PRO
        self._create_button(359, 509, 0b11001) # KEY REL
        self._create_button(429, 404, 0b11100) # ENTER
        self._create_button(429, 474, 0b10010) # RESET

        self.show()


    def _create_reg(self, el_pix, col, row):
        digits = []

        sign = Sign(self, el_pix)
        sign.move(col, row + 6)

        for i in range(5):
            ss = SevenSegment(self, el_pix)
            ss.move(col + 18 + 30*i, row)
            digits.append(ss)

        return sign, digits

    def _create_mode(self, el_pix, col, row):
        digits = []
        for i in range(2):
            ss = SevenSegment(self, el_pix)
            ss.move(col + 30*i, row)
            digits.append(ss)

        return digits

    def _create_permanent_segments(self, el_pix):
        perms = []

        # PROG
        el = ELSegment(self, el_pix, 66, 0, 64, 19, True)
        el.move(393, 37)
        perms.append(el)

        # VERB
        el = ELSegment(self, el_pix, 66, 41, 64, 20, True)
        el.move(286, 106)
        perms.append(el)

        # NOUN
        el = ELSegment(self, el_pix, 66, 20, 64, 20, True)
        el.move(393, 106)
        perms.append(el)

        for i in range(3):
            el = ELSegment(self, el_pix, 0, 63, 142, 5, True)
            el.move(305, 170+i*55)
            perms.append(el)

    def _create_button(self, x, y, keycode):
        b = QPushButton(self)
        b.setFixedSize(63, 63)
        b.move(x, y)
        b.setStyleSheet('QPushButton{background-color: rgba(0,0,0,0);}')
        b.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        if keycode is None:
            b.pressed.connect(lambda k=keycode: self._usbif.send(um.WriteDSKYProceed()))
        else:
            b.pressed.connect(lambda k=keycode: self._usbif.send(um.WriteDSKYButton(k)))

    def paintEvent(self, event):
        opt = QStyleOption()
        opt.init(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PE_Widget, opt, p, self)
