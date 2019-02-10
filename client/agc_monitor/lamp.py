from PySide2.QtWidgets import QWidget
from PySide2.QtGui import QPainter

class Lamp(QWidget):
    def __init__(self, parent, pix, x, y, w, h, on):
        super().__init__(parent)
        self._pix = pix
        self._x = x
        self._y = y
        self._w = w
        self._h = h
        self._on = on
        self._setup_ui()
        self._flash = False

    def set_on(self, on):
        if on != self._on:
            self._on = on
            self.update()

    def set_flash(self, flash):
        if flash != self._flash:
            self._flash = flash
            if self._on:
                self.update()

    def _setup_ui(self):
        self.setFixedSize(self._w, self._h)

    def paintEvent(self, event):
        p = QPainter(self)
        if self._on and not self._flash:
            p.drawPixmap(0, 0, self._pix, self._x, self._y, self._w, self._h)
