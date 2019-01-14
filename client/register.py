from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QLineEdit, QLabel
from PySide2.QtGui import QFont, QColor
from indicator import Indicator

class Register(QWidget):
    def __init__(self, parent, name, has_parity, color):
        super().__init__(parent)
        self.name = name
        self.has_parity = has_parity
        self.indicators = []
        self.parity_inds = []

        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(3)
        layout.setMargin(1)

        bit_frame = QFrame(self)
        bit_layout = QHBoxLayout(bit_frame)
        bit_layout.setSpacing(1)
        bit_layout.setMargin(0)
        bit_frame.setLayout(bit_layout)
        bit_frame.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout.addWidget(bit_frame)

        for i in range(16, 0, -1):
            ind = Indicator(bit_frame, color)
            ind.setMinimumSize(20, 32)
            bit_layout.addWidget(ind)
            self.indicators.insert(0, ind)

            if (i < 16) and (i > 1) and ((i % 3) == 1):
                sep = QFrame(bit_frame)
                sep.setFrameStyle(QFrame.VLine | QFrame.Raised)
                bit_layout.addWidget(sep)

        if has_parity:
            sep = QFrame(bit_frame)
            sep.setFrameStyle(QFrame.VLine | QFrame.Raised)
            bit_layout.addWidget(sep)

            for i in range(2, 0, -1):
                ind = Indicator(bit_frame, QColor(255,255,0))
                ind.setMinimumSize(20, 32)
                bit_layout.addWidget(ind)
                self.parity_inds.insert(0, ind)
            

        self.value_box = QLineEdit()
        self.value_box.setMaximumSize(52, 32)
        self.value_box.setReadOnly(True)
        self.value_box.setText('00000')

        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        self.value_box.setFont(font)

        layout.addWidget(self.value_box)

        label = QLabel(name, self)
        font = label.font()
        font.setPointSize(14)
        font.setBold(True)
        label.setFont(font)
        label.setMinimumWidth(20)

        layout.addWidget(label)

        if not has_parity:
            layout.addSpacing(45)


    def setValue(self, x):
        for i in range(0, len(self.indicators)):
            self.indicators[i].setOn((x & (1 << i)) != 0)

        value = ((x & 0o100000) >> 1) | (x & 0o37777)
        self.value_box.setText('%05o' % value)

        sign1 = (x & 0o100000) != 0
        sign2 = (x & 0o040000) != 0

        if (sign1 and not sign2):
            self.value_box.setStyleSheet('color: red;')
        elif (not sign1 and sign2):
            self.value_box.setStyleSheet('color: purple;')
        else:
            self.value_box.setStyleSheet('color: black;')
