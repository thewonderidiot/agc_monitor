from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QGridLayout, \
                              QLabel, QCheckBox, QPushButton, QRadioButton, QFileDialog
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt, QTimer
import usb_msg as um

class CoreRopeSim(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._bank_switches = []
        self._updating_switches = False

        self._load_timer = QTimer(self)
        self._load_timer.timeout.connect(self._load_next_bank)

        self._setup_ui()

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Set up our basic layout
        layout = QGridLayout(self)
        self.setLayout(layout)
        layout.setSpacing(1)
        layout.setMargin(1)

        for bank in range(0o44):
            col = bank % 18
            row = int(bank / 18) * 2
            sw = self._create_bank_switch('%o' % bank, layout, row, col, 1)
            self._bank_switches.append(sw)

        self._create_bank_switch('44-77', layout, 5, 0, 2)

        label = QLabel('CRS', self)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label, 5, 14, 2, 3, Qt.AlignRight)

        b = self._create_button('ALL', layout, 5, 1, 3)
        b.pressed.connect(lambda: self._set_all(True))
        b = self._create_button('NONE', layout, 5, 3, 2)
        b.pressed.connect(lambda: self._set_all(False))

        self._crs_sel = QRadioButton('CRS', self)
        self._crs_sel.setLayoutDirection(Qt.RightToLeft)
        layout.addWidget(self._crs_sel, 5, 7, 2, 3)
        layout.setAlignment(self._crs_sel, Qt.AlignRight)
        self._crs_sel.setChecked(True)
        #self._s1.toggled.connect(self._set_stop_conds)

        self._agc_sel = QRadioButton('AGC', self)
        layout.addWidget(self._agc_sel, 5, 9, 2, 3)
        layout.setAlignment(self._agc_sel, Qt.AlignCenter)

        font.setPointSize(7)
        self._crs_sel.setFont(font)
        self._agc_sel.setFont(font)

        b = self._create_button('LOAD', layout, 5, 11, 3)
        b.pressed.connect(self._load_rope)
        b = self._create_button('DUMP', layout, 5, 13, 2)

    def _set_all(self, state):
        self._updating_switches = True
        for sw in self._bank_switches:
            sw.setChecked(state)
        self._updating_switches = False

    def _create_button(self, name, layout, row, col, width):
        label = QLabel(name, self)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        label.setMinimumWidth(30)
        layout.addWidget(label, row, col, 1, width)
        layout.setAlignment(label, Qt.AlignCenter)

        b = QPushButton(self)
        b.setFixedSize(20,20)
        layout.addWidget(b, row+1, col, 1, width)
        layout.setAlignment(b, Qt.AlignCenter)
        return b
        
    def _create_bank_switch(self, name, layout, row, col, width):
        label = QLabel(name, self)
        label.setAlignment(Qt.AlignBottom | (Qt.AlignLeft if width == 2 else Qt.AlignCenter))
        font = label.font()
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, row, col, 1, width)

        check = QCheckBox(self)
        check.setFixedSize(20,20)
        check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
        layout.addWidget(check, row + 1, col, 1, 1)
        layout.setAlignment(check, Qt.AlignCenter)
        return check

    def _load_rope(self):
        filename = QFileDialog.getOpenFileName(self, 'Load AGC Rope', '', 'AGC ROMs (*.bin)')
        self._next_bank = 0
        self._load_timer.start(20)

    def _load_next_bank(self):
        bank = self._next_bank
        while bank < len(self._bank_switches):
            sw = self._bank_switches[bank]
            bank += 1
            if sw.isChecked():
                sw.setCheckState(Qt.PartiallyChecked)
                break

        if bank == 0o44:
            self._load_timer.stop()
            for sw in self._bank_switches:
                sw.setTristate(False)
                sw.update()

        self._next_bank = bank
