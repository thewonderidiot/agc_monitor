from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QGridLayout, QLineEdit, QCheckBox
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from reg_validator import RegValidator
import re
import usb_msg as um
import agc

class WComparator(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._w_cmp_switches = []
        self._w_ign_switches = []
        self._par_cmp_switches = []
        self._par_ign_switches = []

        self._updating_switches = False

        self._setup_ui()

    def _setup_ui(self):
        # Set up our basic layout
        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(3)
        layout.setMargin(1)

        bit_frame = QFrame(self)
        layout.addWidget(bit_frame)
        bit_layout = QGridLayout(bit_frame)
        bit_layout.setSpacing(1)
        bit_layout.setMargin(0)
        bit_frame.setLayout(bit_layout)
        bit_frame.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        col = 0
        col = self._create_reg(bit_frame, bit_layout, col, 16, self._w_cmp_switches,
                               self._w_ign_switches, self._update_val_box, self._send_ign_val)
        sep = QFrame(bit_frame)
        sep.setFrameStyle(QFrame.VLine | QFrame.Raised)
        bit_layout.addWidget(sep, 0, col, 2, 1)
        self._create_reg(bit_frame, bit_layout, col + 1, 2, self._par_cmp_switches,
                         self._par_ign_switches, self._send_parity, self._send_parity)

        # Create a value box for displaying the overall decoded valess
        self._val_box = QLineEdit(self)
        layout.addWidget(self._val_box)
        self._val_box.setMaximumSize(52, 32)
        self._val_box.setText('00000')
        self._val_box.setValidator(RegValidator(0o77777))
        self._val_box.returnPressed.connect(self._update_cmp_switches)
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        self._val_box.setFont(font)
        self._val_box.setAlignment(Qt.AlignCenter)
        
        # Add some spacing to account for lack of parity indicators
        layout.addSpacing(40)

    def _send_cmp_val(self):
        val = self._get_switch_value(self._w_cmp_switches, False)
        self._usbif.send(um.WriteControlWCompVal(val))

    def _send_ign_val(self, state):
        ignore = self._get_switch_value(self._w_ign_switches, False)
        self._usbif.send(um.WriteControlWCompIgnore(ignore))

    def _send_parity(self, state):
        parity = self._get_switch_value(self._par_cmp_switches, False)
        ignore = self._get_switch_value(self._par_ign_switches, False)
        self._usbif.send(um.WriteControlWCompParity(parity=parity, ignore=ignore))

    def _get_switch_value(self, switches, corrected):
        val = 0
        for i,s in enumerate(switches):
            bit = len(switches) - i - 1
            if corrected:
                if i == 0:
                    bit -= 1
                elif i == 1:
                    continue
            if s.isChecked():
                val |= (1 << bit)

        return val

    def _update_cmp_switches(self):
        text = self._val_box.text()
        if text == '':
            val = 0
        else:
            val = int(text, 8)

        self._updating_switches = True

        for i,s in enumerate(self._w_cmp_switches):
            bit = len(self._w_cmp_switches) - i - 1
            if i == 0:
                bit -= 1
            s.setChecked((val & (1 << bit)) != 0)

        self._updating_switches = False
        self._send_cmp_val()

    def _update_val_box(self, state):
        val = self._get_switch_value(self._w_cmp_switches, True)
        self._val_box.setText('%05o' % val)

        if not self._updating_switches:
            self._send_cmp_val()

    def _create_reg(self, frame, layout, col, width, cmp_switches, ign_switches, cmp_fn, ign_fn):
        # Add indicators for each bit in the register, from MSB to LSB
        for i in range(width, 0, -1):
            check = QCheckBox(frame)
            check.setFixedSize(20,20)
            check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
            check.stateChanged.connect(cmp_fn)
            layout.addWidget(check, 0, col)
            layout.setAlignment(check, Qt.AlignCenter)
            cmp_switches.append(check)

            check = QCheckBox(frame)
            check.setFixedSize(20,20)
            check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
            check.stateChanged.connect(ign_fn)
            layout.addWidget(check, 1, col)
            layout.setAlignment(check, Qt.AlignCenter)
            ign_switches.append(check)

            col += 1

            # Add separators between each group of 3 bits
            if (i < 16) and (i > 1) and ((i % 3) == 1):
                sep = QFrame(frame)
                sep.setFrameStyle(QFrame.VLine | QFrame.Raised)
                layout.addWidget(sep, 0, col, 2, 1)
                col += 1

        return col
