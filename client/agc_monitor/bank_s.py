from PySide2.QtWidgets import QWidget, QVBoxLayout, QLabel, QRadioButton
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
import usb_msg as um

class BankS(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self._setup_ui()

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setMargin(1)
        layout.setSpacing(1)
        
        layout.addSpacing(50)

        l = QLabel('BANK S', self)
        l.setMinimumHeight(20)
        l.setAlignment(Qt.AlignCenter | Qt.AlignBottom)

        font = l.font()
        font.setPointSize(7)
        font.setBold(True)
        l.setFont(font)
        layout.addWidget(l, Qt.AlignCenter)

        bank_s = QRadioButton(self)
        bank_s.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        layout.addWidget(bank_s, Qt.AlignTop | Qt.AlignCenter)

        s_only = QRadioButton(self)
        s_only.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        layout.addWidget(s_only, Qt.AlignTop | Qt.AlignCenter)

        l = QLabel('S ONLY', self)
        l.setAlignment(Qt.AlignCenter | Qt.AlignTop)
        l.setFont(font)
        layout.addWidget(l, Qt.AlignTop | Qt.AlignCenter)

        bank_s.setChecked(True)
