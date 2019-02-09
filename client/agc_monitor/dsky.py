from PySide2.QtWidgets import QWidget, QStyleOption, QStyle
from PySide2.QtGui import QPainter, QPixmap
from PySide2.QtCore import Qt

from el_segment import ELSegment
from seven_segment import SevenSegment
from sign import Sign

class DSKY(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        self._setup_ui()

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

        self.show()


    def _create_reg(self, el_pix, col, row):
        digits = []

        sign = Sign(self, el_pix)
        sign.move(col, row + 6)

        for i in range(5):
            ss = SevenSegment(self, el_pix)
            ss.move(col + 18 + 30*i, row)
            digits.insert(0, ss)

        return sign, digits

    def _create_mode(self, el_pix, col, row):
        digits = []
        for i in range(2):
            ss = SevenSegment(self, el_pix)
            ss.move(col + 30*i, row)
            digits.insert(0, ss)

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

    def paintEvent(self, event):
        opt = QStyleOption()
        opt.init(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PE_Widget, opt, p, self)
