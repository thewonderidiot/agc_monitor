from PySide2.QtWidgets import QWidget
from PySide2.QtGui import QPainter

class Sign(QWidget):
    def __init__(self, parent, el_pix):
        super().__init__(parent)
        self._bits = 0
        self._bit1 = 0
        self._bit2 = 0

        self._el_pix = el_pix

        self._setup_ui()

    def _setup_ui(self):
        self.setFixedSize(20,26)

    def set_relay_bits(self, bits):
        if bits != self._bits:
            self._bits = bits
            self._bit1 = (bits >> 0) & 0x1
            self._bit2 = (bits >> 1) & 0x1
            self.update()

    def paintEvent(self, event):
        p = QPainter(self)
        if self._bit1 | self._bit2:
            p.drawPixmap(0, 10, self._el_pix, 143, 62, 20, 6)
        if self._bit2:
            p.drawPixmap(8,  0, self._el_pix, 156, 50, 5, 11)
            p.drawPixmap(8, 15, self._el_pix, 156, 50, 5, 11)
