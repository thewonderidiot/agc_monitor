from PySide2.QtWidgets import QFrame, QGridLayout, QLabel, QCheckBox, QPushButton, QRadioButton, QFileDialog
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from memory_load import MemoryLoad
from memory_dump import MemoryDump
import usb_msg as um

class CoreRopeSim(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._bank_switches = []
        self._updating_switches = False

        self._setup_ui()

        self._rope_loader = MemoryLoad(usbif, um.WriteSimFixed, 0o100, 1024, self._bank_switches, self._aux_switch)
        self._rope_loader.finished.connect(self._load_complete)

        self._rope_dumper = MemoryDump(usbif, um.ReadFixed, um.Fixed, 0o100, 1024, self._bank_switches, self._aux_switch)
        self._rope_loader.finished.connect(self._dump_complete)

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
            sw.stateChanged.connect(lambda state,bank=bank: self._update_crs_bank(bank))
            self._bank_switches.append(sw)

        self._aux_switch = self._create_bank_switch('44-77', layout, 5, 0, 2)

        label = QLabel('CRS', self)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label, 5, 16, 2, 2, Qt.AlignCenter)

        b = self._create_button('ALL', layout, 5, 1, 3)
        b.pressed.connect(lambda: self._set_all(True))
        b = self._create_button('NONE', layout, 5, 3, 2)
        b.pressed.connect(lambda: self._set_all(False))

        self._crs_sel = QRadioButton('CRS', self)
        self._crs_sel.setLayoutDirection(Qt.RightToLeft)
        layout.addWidget(self._crs_sel, 5, 6, 2, 3)
        layout.setAlignment(self._crs_sel, Qt.AlignRight)

        self._agc_sel = QRadioButton('AGC', self)
        self._agc_sel.setChecked(True)
        layout.addWidget(self._agc_sel, 5, 8, 2, 3)
        layout.setAlignment(self._agc_sel, Qt.AlignCenter)

        font.setPointSize(7)
        self._crs_sel.setFont(font)
        self._agc_sel.setFont(font)

        b = self._create_button('LOAD', layout, 5, 12, 3)
        b.pressed.connect(self._load_rope)
        b = self._create_button('DUMP', layout, 5, 14, 2)
        b.pressed.connect(self._dump_rope)

    def _update_crs_bank(self, bank):
        if self._updating_switches:
            return
        
        group = int(bank / 16)
        first_bank = group * 16

        enables = [False] * 16
        for i in range(16):
            bank = first_bank + i
            if bank < 0o44:
                sw = self._bank_switches[bank]
            else:
                sw = self._aux_switch

            enables[i] = sw.isChecked()

        write_crs_enables = getattr(um, 'WriteControlCRSBankEnable%u' % group)
        self._usbif.send(write_crs_enables(*enables))

    def _update_all_banks(self):
        for bank in [0, 0o20, 0o40, 0o60]:
            self._update_crs_bank(bank)

    def _set_all(self, state):
        self._updating_switches = True
        for sw in self._bank_switches:
            sw.setChecked(state)
        self._updating_switches = False
        self._update_all_banks()

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
        filename, group = QFileDialog.getOpenFileName(self, 'Load AGC Rope', 'roms', 'AGC ROMs (*.bin)')
        if group == '':
            return
        self._updating_switches = True
        self._rope_loader.load_memory(filename)

    def _load_complete(self):
        self._updating_switches = False

    def _dump_complete(self):
        self._updating_switches = False
        self._update_all_banks()

    def _dump_rope(self):
        filename, group = QFileDialog.getSaveFileName(self, 'Save AGC Rope', 'roms', 'AGC ROMs (*.bin)')
        if group == '':
            return

        self._updating_switches = True

        if self._agc_sel.isChecked():
            z = [False]*16
            for m in [um.WriteControlCRSBankEnable0,
                      um.WriteControlCRSBankEnable1,
                      um.WriteControlCRSBankEnable2,
                      um.WriteControlCRSBankEnable3]:
                self._usbif.send(m(*z))

        self._rope_dumper.dump_memory(filename)
