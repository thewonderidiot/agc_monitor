from PySide2.QtWidgets import QWidget
from PySide2.QtGui import QPainter, QColor, QRadialGradient
from PySide2.QtCore import QPointF

class Indicator(QWidget):
    def __init__(self, parent, color):
        super().__init__(parent)
        self.setMinimumSize(16,16)
        self.color = color
        self.on = False

    def paintEvent(self, event):
        p = QPainter(self)
        p.setRenderHint(QPainter.Antialiasing)
        w = self.width()
        h = self.height()

        d = min(w,h) * 0.9
        r = d/2
        center = QPointF(w/2, h/2)

        if self.on:
            focus = center - QPointF(r, r)
            color0 = self.color
            color1 = self.color.darker(132)
        else:
            focus = center + QPointF(r, r)
            color0 = self.color.darker(255)
            color1 = self.color.darker(800)

        gradient = QRadialGradient(focus, d*1.5, focus)
        gradient.setColorAt(0, color0)
        gradient.setColorAt(1, color1)
        p.setBrush(gradient)
        p.setPen(QColor(96,96,96))
        p.drawEllipse(center,r,r)

    def setOn(self, on):
        self.on = bool(on)
        self.repaint()
