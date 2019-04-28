from PySide2.QtWidgets import QFrame, QGridLayout, QLabel, QCheckBox, QPushButton, QRadioButton, QFileDialog, QSpacerItem
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from memory_load import MemoryLoad
from memory_dump import MemoryDump
import usb_msg as um

class ErasableMemSim(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._bank_switches = []
        self._updating_switches = False

        self._setup_ui()

        self._core_loader = MemoryLoad(usbif, um.WriteSimErasable, 0o10, 256, self._bank_switches, None)
        self._core_loader.finished.connect(self._load_complete)

        self._core_dumper = MemoryDump(usbif, um.ReadErasable, um.Erasable, 0o10, 256, self._bank_switches, None)
        self._core_loader.finished.connect(self._dump_complete)

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Set up our basic layout
        layout = QGridLayout(self)
        self.setLayout(layout)
        layout.setSpacing(1)
        layout.setMargin(1)

        for bank in range(0o10):
            sw = self._create_bank_switch('E%o' % bank, layout, 0, bank, 1)
            sw.stateChanged.connect(self._update_ems_banks)
            self._bank_switches.append(sw)

        for col in range(0o10, 0o22):
            s = QSpacerItem(20,20)
            layout.addItem(s, 1, col)

        label = QLabel('EMS', self)
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

        self._ems_sel = QRadioButton('EMS', self)
        self._ems_sel.setLayoutDirection(Qt.RightToLeft)
        layout.addWidget(self._ems_sel, 5, 6, 2, 3)
        layout.setAlignment(self._ems_sel, Qt.AlignRight)

        self._agc_sel = QRadioButton('AGC', self)
        self._agc_sel.setChecked(True)
        layout.addWidget(self._agc_sel, 5, 8, 2, 3)
        layout.setAlignment(self._agc_sel, Qt.AlignCenter)

        font.setPointSize(7)
        self._ems_sel.setFont(font)
        self._agc_sel.setFont(font)

        b = self._create_button('PAD', layout, 5, 11, 2)
        b.pressed.connect(self._load_pad)
        b = self._create_button('LOAD', layout, 5, 12, 3)
        b.pressed.connect(self._load_core)
        b = self._create_button('DUMP', layout, 5, 14, 2)
        b.pressed.connect(self._dump_core)

    def _update_ems_banks(self):
        if self._updating_switches:
            return
        
        enables = [False] * 8
        for i,sw in enumerate(self._bank_switches):
            enables[i] = sw.isChecked()

        self._usbif.send(um.WriteControlEMSBankEnable(*enables))

    def _set_all(self, state):
        self._updating_switches = True
        for sw in self._bank_switches:
            sw.setChecked(state)
        self._updating_switches = False
        self._update_ems_banks()

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

    def _load_pad(self):
        filename, group = QFileDialog.getOpenFileName(self, 'Load AGC Pad Load', 'pads', 'AGC Pad Load Files (*.pad)')
        if group == '':
            return

        load_data = []
        with open(filename, 'r') as f:
            for l in f.readlines():
                parts = l.split()
                addr_idx = 0
                if len(parts) == 3:
                    if parts[0] in ('CMPAD', 'LMPAD'):
                        addr_idx = 1
                    else:
                        raise RuntimeError('Invalid pad load line "%s"' % l)
                elif len(parts) != 2:
                    raise RuntimeError('Invalid pad load line "%s"' % l)

                addr = int(parts[addr_idx], 8)
                val = int(parts[addr_idx + 1], 8)
                load_data.append((addr, val))
        
        msg_type = um.WriteErasable if self._agc_sel.isChecked() else um.WriteSimErasable
        for addr, val in load_data:
            self._usbif.send(msg_type(addr=addr, data=val, parity=0))

    def _load_core(self):
        filename, group = QFileDialog.getOpenFileName(self, 'Load AGC Core File', 'cores', 'AGC Core Files (*.bin)')
        if group == '':
            return
        self._updating_switches = True
        self._core_loader.load_memory(filename, um.WriteErasable if self._agc_sel.isChecked() else um.WriteSimErasable)

    def _load_complete(self):
        self._updating_switches = False

    def _dump_complete(self):
        self._updating_switches = False
        self._update_ems_banks()

    def _dump_core(self):
        filename, group = QFileDialog.getSaveFileName(self, 'Save AGC Core Dump', 'cores', 'AGC Core Files (*.bin)')
        if group == '':
            return

        self._updating_switches = True

        if self._agc_sel.isChecked():
            z = [False]*8
            self._usbif.send(um.WriteControlEMSBankEnable(*z))

        self._core_dumper.dump_memory(filename)
