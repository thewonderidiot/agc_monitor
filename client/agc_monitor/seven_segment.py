from PySide2.QtWidgets import QWidget
from PySide2.QtGui import QPainter

class SevenSegment(QWidget):
    def __init__(self, parent, el_pix):
        super().__init__(parent)
        self._bits = 0
        self._bit1 = 0
        self._bit2 = 0
        self._bit3 = 0
        self._bit4 = 0
        self._bit5 = 0

        self._on = True

        self._el_pix = el_pix

        self._setup_ui()

    def _setup_ui(self):
        self.setFixedSize(33,37)

    def set_relay_bits(self, bits):
        if bits != self._bits:
            self._bits = bits
            self._bit1 = (bits >> 0) & 0x1
            self._bit2 = (bits >> 1) & 0x1
            self._bit3 = (bits >> 2) & 0x1
            self._bit4 = (bits >> 3) & 0x1
            self._bit5 = (bits >> 4) & 0x1
            self.update()

    def set_on(self, on):
        if on != self._on:
            self._on = on
            self.update()

    def paintEvent(self, event):
        if self._on:
            p = QPainter(self)
            if self._bit5: # top
                p.drawPixmap(10, 0, self._el_pix, 131, 3, 19, 6)
            if self._bit4: # middle
                p.drawPixmap(9, 16, self._el_pix, 131, 30, 15, 6)
            if self._bit3: # left upper
                p.drawPixmap(5, 1, self._el_pix, 131, 11, 9, 18)
            if self._bit1: # right upper
                p.drawPixmap(23, 0, self._el_pix, 141, 10, 10, 19)
            if (~self._bit2) & (self._bit5): # left lower
                p.drawPixmap(0, 19, self._el_pix, 131, 37, 10, 18)
            if self._bit2 | (~self._bit2 & self._bit3): # right lower
                p.drawPixmap(20, 19, self._el_pix, 143, 37, 9, 18)
            if self._bit5 & (self._bit3 | self._bit4): # bottom
                p.drawPixmap(1, 32, self._el_pix, 131, 56, 23, 5)
