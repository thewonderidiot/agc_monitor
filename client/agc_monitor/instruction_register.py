from PySide2.QtWidgets import QWidget, QFrame, QVBoxLayout, QHBoxLayout, QGridLayout, QLineEdit, QLabel
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from collections import OrderedDict
from indicator import Indicator
import usb_msg as um
import agc

STATUS_INDS = OrderedDict([
    ('iip', 'IIP'),
    ('inhl', 'INHL'),
    ('inkl', 'INKL'),
    ('ld', 'LD'),
    ('chld', 'CHLD'),
    ('rd', 'RD'),
    ('chrd', 'CHRD'),
])

class InstructionRegister(QWidget):
    def __init__(self, parent, usbif, color):
        super().__init__(parent)
        self._br_inds = []
        self._st_inds = []
        self._sq_inds = []
        self._status_inds = {}

        self._setup_ui(color)

        usbif.poll(um.ReadMonRegI())
        usbif.poll(um.ReadMonRegStatus())
        usbif.poll(um.ReadStatusPeripheral())

        usbif.listen(self)

    def handle_msg(self, msg):
        if isinstance(msg, um.MonRegI):
            self.set_i_values(msg.br, msg.st, msg.sqext, msg.sq)
        elif isinstance(msg, um.MonRegStatus):
            self._status_inds['iip'].set_on(msg.iip)
            self._status_inds['inhl'].set_on(msg.inhl)
            self._status_inds['inkl'].set_on(msg.inkl)
        elif isinstance(msg, um.StatusPeripheral):
            self._status_inds['ld'].set_on(msg.ld)
            self._status_inds['chld'].set_on(msg.chld)
            self._status_inds['rd'].set_on(msg.rd)
            self._status_inds['chrd'].set_on(msg.chrd)

    def set_i_values(self, br, st, sqext, sq):
        self._set_reg_value(self._br_inds, self._br_value, br)
        self._set_reg_value(self._st_inds, self._st_value, st)
        self._set_reg_value(self._sq_inds, self._sq_value, (sqext << 5) | sq)
        self._inst_value.setText(agc.disassemble_subinst(sqext, sq, st))

    def _setup_ui(self, color):
        # Set up our basic layout
        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(3)
        layout.setMargin(1)

        # Construct register groups for BR, ST, and SQ
        br_frame, self._br_value = self._create_reg(self._br_inds, 'BR', 2, color)
        st_frame, self._st_value = self._create_reg(self._st_inds, 'ST', 3, color)
        sq_frame, self._sq_value = self._create_reg(self._sq_inds, 'SQ', 7, color)
        layout.addWidget(br_frame)
        layout.addWidget(st_frame)
        layout.addWidget(sq_frame)

        stat_group = QWidget(self)
        layout.addWidget(stat_group)
        stat_layout = QGridLayout(stat_group)
        stat_layout.setMargin(0)
        stat_layout.setSpacing(0)

        col = 0
        for name, label in STATUS_INDS.items():
            self._status_inds[name] = self._create_status_light(label, stat_group, stat_layout, col)
            col += 1

        # Create a grouping widget for the I label and decoded instruction value box
        label_value = QWidget(self)
        lv_layout = QHBoxLayout(label_value)
        lv_layout.setSpacing(3)
        lv_layout.setMargin(1)
        lv_layout.setContentsMargins(0, 32, 0, 0)
        label_value.setLayout(lv_layout)
        layout.addWidget(label_value)

        # Create a value box for displaying the overall decoded instruction
        self._inst_value = QLineEdit(label_value)
        self._inst_value.setReadOnly(True)
        self._inst_value.setMaximumSize(65, 32)
        self._inst_value.setText('TC0')
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        self._inst_value.setFont(font)
        self._inst_value.setAlignment(Qt.AlignCenter)
        lv_layout.addWidget(self._inst_value)
        
        # Create a label to show 'I'
        label = QLabel('I', label_value)
        font = label.font()
        font.setPointSize(14)
        font.setBold(True)
        label.setFont(font)
        lv_layout.addWidget(label)

        # Add some spacing to account for lack of parity indicators
        layout.addSpacing(52)

    def _set_reg_value(self, inds, value_box, x):
        # Generic function to display in octal the value of a register, with the
        # appropriate number of digits
        for i in range(0, len(inds)):
            inds[i].set_on((x & (1 << i)) != 0)

        fmt_string = '%%0%oo' % int((len(inds)+2)/3)
        value_box.setText(fmt_string % x)

    def _create_reg(self, ind_list, name, width, color):
        # Create a widget to hold the register's bits
        reg_widget = QWidget(self)
        reg_layout = QVBoxLayout(reg_widget)
        reg_widget.setLayout(reg_layout)
        reg_layout.setSpacing(0)
        reg_layout.setMargin(0)

        # Create a widget to hold the register's label and value textbox
        label_value = QWidget(reg_widget)
        lv_layout = QHBoxLayout(label_value)
        label_value.setLayout(lv_layout)
        lv_layout.setSpacing(1)
        lv_layout.setMargin(0)
        reg_layout.addWidget(label_value)

        # Create a label to show the register's name
        reg_label = QLabel(name, label_value)
        reg_label.setAlignment(Qt.AlignCenter)
        font = reg_label.font()
        font.setPointSize(8)
        reg_label.setFont(font)
        lv_layout.addWidget(reg_label)

        # Create a textbox to show the register's value in octal
        n_digits = int((width+2)/3)
        if n_digits == 1:
            value_width = 25
        elif n_digits == 2:
            value_width = 30
        else:
            value_width = 45

        reg_value = QLineEdit(label_value)
        reg_value.setReadOnly(True)
        reg_value.setMaximumSize(value_width, 32)
        reg_value.setText(n_digits * '0')
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        reg_value.setFont(font)
        reg_value.setAlignment(Qt.AlignCenter)
        lv_layout.addWidget(reg_value)

        # Create a frame to hold the register's bits
        bit_frame = QFrame(reg_widget)
        bit_layout = QHBoxLayout(bit_frame)
        bit_layout.setSpacing(1)
        bit_layout.setMargin(0)
        bit_frame.setLayout(bit_layout)
        bit_frame.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Add indicators for each bit in the register, from MSB to LSB
        for i in range(width, 0, -1):
            ind = Indicator(bit_frame, color)
            ind.setFixedSize(20, 32)
            bit_layout.addWidget(ind)
            ind_list.insert(0, ind)

            # Add separators between each group of 3 bits
            if (i > 1) and ((i % 3) == 1):
                sep = QFrame(bit_frame)
                sep.setFrameStyle(QFrame.VLine | QFrame.Raised)
                bit_layout.addWidget(sep)

        reg_layout.addWidget(bit_frame)

        return reg_widget, reg_value

    def _create_status_light(self, name, parent, layout, col):
        label = QLabel(name, parent)
        label.setAlignment(Qt.AlignBottom | Qt.AlignCenter)
        label.setFixedSize(30,20)
        font = label.font()
        font.setPointSize(8)
        label.setFont(font)
        layout.addWidget(label, 1, col)
        layout.setAlignment(label, Qt.AlignBottom)

        # Add an indicator to show inhibit state
        ind = Indicator(parent, QColor(0, 255, 255))
        ind.setFixedSize(20, 20)
        layout.addWidget(ind, 2, col)
        layout.setAlignment(ind, Qt.AlignCenter)

        return ind
