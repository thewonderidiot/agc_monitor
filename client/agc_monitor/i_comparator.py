from PySide2.QtWidgets import QWidget, QFrame, QVBoxLayout, QHBoxLayout, QGridLayout, QLineEdit, QLabel, QCheckBox
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from reg_validator import RegValidator
from instruction_register import STATUS_INDS
import re
import usb_msg as um
import agc

class IComparator(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._br_cmp_switches = []
        self._br_ign_switches = []
        self._st_cmp_switches = []
        self._st_ign_switches = []
        self._sq_cmp_switches = []
        self._sq_ign_switches = []
        self._status_cmp_switches = {}
        self._status_ign_switches = {}

        self._updating_switches = False

        self._br = 0
        self._st = 0
        self._sqext = 0
        self._sq = 0

        self._br_ign = 0
        self._st_ign = 0
        self._sqext_ign = 0
        self._sq_ign = 0

        self._setup_ui()

        usbif.send(um.WriteControlICompVal(0, 0, 0, 0))
        usbif.send(um.WriteControlICompIgnore(0, 0, 0, 0))
        z = (0,)*(len(STATUS_INDS) * 2)
        self._usbif.send(um.WriteControlICompStatus(*z))

    def _setup_ui(self):
        # Set up our basic layout
        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(3)
        layout.setMargin(1)

        # Construct register groups for BR, ST, and SQ
        self._br_cmp_box, self._br_ign_box = self._create_reg(layout, 2, self._br_cmp_switches, self._br_ign_switches)
        self._st_cmp_box, self._st_ign_box = self._create_reg(layout, 3, self._st_cmp_switches, self._st_ign_switches)
        self._sq_cmp_box, self._sq_ign_box = self._create_reg(layout, 7, self._sq_cmp_switches, self._sq_ign_switches)

        self._create_status_lights(layout)

        # Create a value box for displaying the overall decoded instruction
        inst_widget = QWidget(self)
        layout.addWidget(inst_widget)
        inst_widget.setMinimumWidth(100)
        inst_layout = QHBoxLayout(inst_widget)
        inst_layout.setSpacing(3)
        inst_layout.setMargin(1)
        inst_layout.setContentsMargins(0, 32, 0, 0)

        self._inst_value = QLineEdit(inst_widget)
        self._inst_value.setReadOnly(True)
        self._inst_value.setMaximumSize(65, 32)
        self._inst_value.setText('TC0')
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        self._inst_value.setFont(font)
        self._inst_value.setAlignment(Qt.AlignCenter)
        inst_layout.addWidget(self._inst_value)
        inst_layout.setAlignment(Qt.AlignLeft)

        # Add some spacing to account for lack of parity indicators
        layout.addSpacing(23)

    def _get_switch_value(self, switches):
        val = 0
        for i,s in enumerate(switches):
            bit = len(switches) - i - 1
            if s.isChecked():
                val |= (1 << bit)

        return val

    def _update_inst(self):
        br = int(self._br_cmp_box.text(), 8)
        st = int(self._st_cmp_box.text(), 8)
        sq = int(self._sq_cmp_box.text(), 8)
        sqext = (sq >> 6) & 0o1
        sq &= 0o77

        br_ign = int(self._br_ign_box.text(), 8)
        st_ign = int(self._st_ign_box.text(), 8)
        sq_ign = int(self._sq_ign_box.text(), 8)
        sqext_ign = (sq_ign >> 6) & 0o1
        sq_ign &= 0o77

        if (self._br != br) or (self._st != st) or (self._sq != sq) or (self._sqext != sqext):
            self._br = br
            self._st = st
            self._sq = sq
            self._sqext = sqext
            self._usbif.send(um.WriteControlICompVal(br=br, st=st, sqext=sqext, sq=sq))

        if (self._br_ign != br_ign) or (self._st_ign != st_ign) or (self._sq_ign != sq_ign) or (self._sqext_ign != sqext_ign):
            self._br_ign = br_ign
            self._st_ign = st_ign
            self._sq_ign = sq_ign
            self._sqext_ign = sqext_ign
            self._usbif.send(um.WriteControlICompIgnore(br=br_ign, st=st_ign, sqext=sqext_ign, sq=sq_ign))

        self._inst_value.setText(agc.disassemble(sqext, sq, st))

    def _update_status(self):
        status_cmp = {v: self._status_cmp_switches[v].isChecked() for v in STATUS_INDS.keys()}
        status_ign = {v+'_ign': self._status_ign_switches[v].isChecked() for v in STATUS_INDS.keys()}

        status_bits = {**status_cmp, **status_ign}
        self._usbif.send(um.WriteControlICompStatus(**status_bits))

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
        self._update_inst()

    def _update_reg_box(self, on, box, switches):
        val = self._get_switch_value(switches)
        max_length = box.maxLength()
        fmt = '%%0%uo' % max_length
        box.setText(fmt % val)

        if not self._updating_switches:
            self._update_inst()

    def _create_reg(self, layout, width, cmp_switches, ign_switches):
        # Create a widget to hold the register's bits
        reg_widget = QWidget(self)
        layout.addWidget(reg_widget)
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

        return reg_value, ign_value

    def _create_status_lights(self, layout):
        # Create a frame to hold the register's bits
        status_frame = QFrame(self)
        layout.addWidget(status_frame)
        layout.setAlignment(status_frame, Qt.AlignBottom)
        status_layout = QGridLayout(status_frame)
        status_layout.setSpacing(0)
        status_layout.setMargin(0)
        status_frame.setLayout(status_layout)
        status_frame.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Add indicators for each status in the register, from MSB to LSB
        for col,stat in enumerate(STATUS_INDS.keys()):
            check = QCheckBox(status_frame)
            check.setFixedSize(30,20)
            check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
            check.stateChanged.connect(lambda state: self._update_status())
            status_layout.addWidget(check, 0, col)
            status_layout.setAlignment(check, Qt.AlignCenter)
            self._status_cmp_switches[stat] = check

            check = QCheckBox(status_frame)
            check.setFixedSize(30,20)
            check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
            check.stateChanged.connect(lambda state: self._update_status())
            status_layout.addWidget(check, 1, col)
            status_layout.setAlignment(check, Qt.AlignCenter)
            self._status_ign_switches[stat] = check
