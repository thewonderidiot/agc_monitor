from PySide2.QtWidgets import QWidget
from PySide2.QtGui import QPainter, QColor, QRadialGradient
from PySide2.QtCore import QPointF

class Indicator(QWidget):
    def __init__(self, parent, color):
        super().__init__(parent)
        self.setMinimumSize(16,16)
        self._color = color
        self._on = False

    def set_on(self, on):
        # Set our state and redraw
        self._on = bool(on)
        self.repaint()

    def paintEvent(self, event):
        p = QPainter(self)
        p.setRenderHint(QPainter.Antialiasing)

        # Determine the width and height of the indicator
        w = self.width()
        h = self.height()

        # The smaller dimension determines our diameter
        d = min(w,h) * 0.9
        r = d/2

        # Locate the center of the indicator circle
        center = QPointF(w/2, h/2)

        if self._on:
            # Gradient focus in the top left, fading from brighter to bright
            focus = center - QPointF(r, r)
            color0 = self._color
            color1 = self._color.darker(132)
        else:
            # Gradient focus in the bottom right, fading from darker to dark
            focus = center + QPointF(r, r)
            color0 = self._color.darker(800)
            color1 = self._color.darker(255)

        # Construct the gradient and draw the circle using it
        gradient = QRadialGradient(focus, d*1.4, focus)
        gradient.setColorAt(0, color0)
        gradient.setColorAt(1, color1)
        p.setBrush(gradient)
        p.setPen(QColor(96,96,96))
        p.drawEllipse(center,r,r)
