from PySide2.QtWidgets import QWidget, QFrame, QVBoxLayout, QHBoxLayout, QGridLayout, QLineEdit, QLabel, QCheckBox
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from reg_validator import RegValidator
import re
import usb_msg as um
import agc

class SComparator(QWidget):
    def __init__(self, parent, usbif, num):
        super().__init__(parent)
        self._usbif = usbif

        self._setup_ui(num)

        self._write_s_msg = getattr(um, 'WriteControlS%uS' % num)
        self._write_bank_msg = getattr(um, 'WriteControlS%uBank' % num)
        self._write_s_ign_msg = getattr(um, 'WriteControlS%uSIgnore' % num)
        self._write_bank_ign_msg = getattr(um, 'WriteControlS%uBankIgnore' % num)

        usbif.send(self._write_s_msg(s=0))
        usbif.send(self._write_bank_msg(eb=0, fb=0, fext=0))
        usbif.send(self._write_s_ign_msg(s=0))
        usbif.send(self._write_bank_ign_msg(eb=0, fb=0, fext=0))

    def _setup_ui(self, num):
        # Set up our basic layout
        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(3)
        layout.setMargin(1)

        # Construct register groups for EB, FEXT, FB, and S
        self._eb_cmp_switches = []
        self._eb_ign_switches = []
        self._fext_cmp_switches = []
        self._fext_ign_switches = []
        self._fb_cmp_switches = []
        self._fb_ign_switches = []
        self._s_cmp_switches = []
        self._s_ign_switches = []

        self._updating_switches = False

        self._eb = 0
        self._eb_ign = 0
        self._fext = 0
        self._fext_ign = 0
        self._fb = 0
        self._fb_ign = 0
        self._s = 0
        self._s_ign = 0

        eb, self._eb_cmp_box, self._eb_ign_box = self._create_reg(3, self._eb_cmp_switches, self._eb_ign_switches)
        fext, self._fext_cmp_box, self._fext_ign_box = self._create_reg(3, self._fext_cmp_switches, self._fext_ign_switches)
        fb, self._fb_cmp_box, self._fb_ign_box = self._create_reg(5, self._fb_cmp_switches, self._fb_ign_switches)
        s, self._s_cmp_box, self._s_ign_box = self._create_reg(12, self._s_cmp_switches, self._s_ign_switches)
        layout.addWidget(eb)
        layout.addWidget(fext)
        layout.addWidget(fb)
        layout.addWidget(s)

        # Create a grouping widget for the Sn label and decoded octal value box
        label_value = QWidget(self)
        label_value.setMinimumWidth(100)
        lv_layout = QHBoxLayout(label_value)
        lv_layout.setSpacing(3)
        lv_layout.setMargin(1)
        lv_layout.setContentsMargins(0, 32, 0, 0)
        label_value.setLayout(lv_layout)
        layout.addWidget(label_value)

        # Create a value box for displaying the overall decoded address
        self._addr_box = QLineEdit(label_value)
        self._addr_box.setReadOnly(True)
        self._addr_box.setMaximumSize(65, 32)
        self._addr_box.setText('0000')
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        self._addr_box.setFont(font)
        self._addr_box.setAlignment(Qt.AlignCenter)
        lv_layout.addWidget(self._addr_box)
        
        # Create a label to show 'S'
        label = QLabel('S%u' % num, label_value)
        font = label.font()
        font.setPointSize(14)
        font.setBold(True)
        label.setFont(font)
        lv_layout.addWidget(label)

        # Add some spacing to account for lack of parity indicators
        layout.addSpacing(19)

    def _get_switch_value(self, switches):
        val = 0
        for i,s in enumerate(switches):
            bit = len(switches) - i - 1
            if s.isChecked():
                val |= (1 << bit)

        return val

    def _update_switches(self, box, switches):
        text = box.text()
        if text == '':
            val = 0
        else:
            val = int(text, 8)

        self._updating_switches = True

        for i,s in enumerate(switches):
            bit = len(switches) - i - 1
            s.setChecked((val & (1 << bit)) != 0)

        self._updating_switches = False
        self._update_addr()

    def _update_reg_box(self, on, box, switches):
        val = self._get_switch_value(switches)
        max_length = box.maxLength()
        fmt = '%%0%uo' % max_length
        box.setText(fmt % val)

        if not self._updating_switches:
            self._update_addr()

    def _update_addr(self):
        eb = int(self._eb_cmp_box.text(), 8)
        fext = int(self._fext_cmp_box.text(), 8)
        fb = int(self._fb_cmp_box.text(), 8)
        s = int(self._s_cmp_box.text(), 8)

        eb_ign = int(self._eb_ign_box.text(), 8)
        fext_ign = int(self._fext_ign_box.text(), 8)
        fb_ign = int(self._fb_ign_box.text(), 8)
        s_ign = int(self._s_ign_box.text(), 8)

        if self._s != s:
            self._s = s
            self._usbif.send(self._write_s_msg(s))

        if (self._eb != eb) or (self._fb != fb) or (self._fext != fext):
            self._eb = eb
            self._fext = fext
            self._fb = fb
            self._usbif.send(self._write_bank_msg(eb=eb, fext=fext, fb=fb))

        if self._s_ign != s_ign:
            self._s_ign = s_ign
            self._usbif.send(self._write_s_ign_msg(s_ign))

        if (self._eb_ign != eb_ign) or (self._fb_ign != fb_ign) or (self._fext_ign != fext_ign):
            self._eb_ign = eb_ign
            self._fext_ign = fext_ign
            self._fb_ign = fb_ign
            self._usbif.send(self._write_bank_ign_msg(eb=eb_ign, fext=fext_ign, fb=fb_ign))

        self._addr_box.setText(agc.format_addr(s, eb, fb, fext))

    def _create_reg(self, width, cmp_switches, ign_switches):
        # Create a widget to hold the register's bits
        reg_widget = QWidget(self)
        reg_layout = QVBoxLayout(reg_widget)
        reg_widget.setLayout(reg_layout)
        reg_layout.setSpacing(0)
        reg_layout.setMargin(0)

        # Create a widget to hold the register's value and ignore textboxes
        values = QWidget(reg_widget)
        v_layout = QHBoxLayout(values)
        values.setLayout(v_layout)
        v_layout.setSpacing(1)
        v_layout.setMargin(0)
        reg_layout.addWidget(values)
        reg_layout.setAlignment(values, Qt.AlignRight)

        # Create textboxes to show the register's value and ignore mask in octal
        n_digits = int((width+2)/3)
        if n_digits == 1:
            value_width = 25
        elif n_digits == 2:
            value_width = 30
        else:
            value_width = 45

        reg_value = QLineEdit(values)
        reg_value.setMaximumSize(value_width, 32)
        reg_value.setText(n_digits * '0')
        reg_value.setAlignment(Qt.AlignCenter)
        reg_value.setValidator(RegValidator(2**width-1))
        reg_value.setMaxLength(n_digits)
        reg_value.returnPressed.connect(lambda b=reg_value, s=cmp_switches: self._update_switches(b, s))
        v_layout.addWidget(reg_value)

        ign_value = QLineEdit(values)
        ign_value.setMaximumSize(value_width, 32)
        ign_value.setText(n_digits * '0')
        ign_value.setAlignment(Qt.AlignCenter)
        ign_value.setValidator(RegValidator(2**width-1))
        ign_value.setMaxLength(n_digits)
        ign_value.returnPressed.connect(lambda b=ign_value, s=ign_switches: self._update_switches(b, s))
        v_layout.addWidget(ign_value)

        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        reg_value.setFont(font)
        ign_value.setFont(font)

        # Create a frame to hold the register's bits
        bit_frame = QFrame(reg_widget)
        bit_layout = QGridLayout(bit_frame)
        bit_layout.setSpacing(1)
        bit_layout.setMargin(0)
        bit_frame.setLayout(bit_layout)
        bit_frame.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Add indicators for each bit in the register, from MSB to LSB
        col = 0
        for i in range(width, 0, -1):
            check = QCheckBox(bit_frame)
            check.setFixedSize(20,20)
            check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
            check.stateChanged.connect(lambda state, b=reg_value, s=cmp_switches: self._update_reg_box(state, b, s))
            bit_layout.addWidget(check, 0, col)
            bit_layout.setAlignment(check, Qt.AlignCenter)
            cmp_switches.append(check)

            check = QCheckBox(bit_frame)
            check.setFixedSize(20,20)
            check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
            check.stateChanged.connect(lambda state, b=ign_value, s=ign_switches: self._update_reg_box(state, b, s))
            bit_layout.addWidget(check, 1, col)
            bit_layout.setAlignment(check, Qt.AlignCenter)
            ign_switches.append(check)

            col += 1

            # Add separators between each group of 3 bits
            if (i > 1) and ((i % 3) == 1):
                sep = QFrame(bit_frame)
                sep.setFrameStyle(QFrame.VLine | QFrame.Raised)
                bit_layout.addWidget(sep, 0, col, 2, 1)
                col += 1

        reg_layout.addWidget(bit_frame)

        return reg_widget, reg_value, ign_value
