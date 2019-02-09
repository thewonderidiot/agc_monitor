from PySide2.QtWidgets import QWidget
from PySide2.QtGui import QPainter

class ELSegment(QWidget):
    def __init__(self, parent, el_pix, x, y, w, h, on):
        super().__init__(parent)
        self._el_pix = el_pix
        self._x = x
        self._y = y
        self._w = w
        self._h = h
        self._on = on
        self._setup_ui()

    def set_on(self, on):
        if on != self._on:
            self._on = on
            self.update()

    def _setup_ui(self):
        self.setFixedSize(self._w, self._h)

    def paintEvent(self, event):
        p = QPainter(self)
        if self._on:
            p.drawPixmap(0, 0, self._el_pix, self._x, self._y, self._w, self._h)
