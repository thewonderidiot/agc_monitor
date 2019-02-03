from PySide2.QtWidgets import QWidget, QFrame, QVBoxLayout, QHBoxLayout, QLineEdit, QLabel
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from indicator import Indicator
import usb_msg as um
import agc

class AddressRegister(QWidget):
    def __init__(self, parent, usbif, color):
        super().__init__(parent)
        self._eb_inds = []
        self._fext_inds = []
        self._fb_inds = []
        self._s_inds = []

        self._eb_value = 0
        self._fext_value = 0
        self._fb_value = 0
        self._s_value = 0

        self._setup_ui(color)

        usbif.poll(um.ReadMonRegS())
        usbif.poll(um.ReadMonRegBB())
        usbif.poll(um.ReadMonChanFEXT())

        usbif.subscribe(self, um.MonRegS)
        usbif.subscribe(self, um.MonRegBB)
        usbif.subscribe(self, um.MonChanFEXT)

    def handle_msg(self, msg):
        if isinstance(msg, um.MonRegS):
            self.set_s_value(msg.s)
        elif isinstance(msg, um.MonRegBB):
            self.set_bank_values(msg.eb, msg.fb)
        elif isinstance(msg, um.MonChanFEXT):
            self.set_fext_value(msg.fext)

    def set_bank_values(self, eb, fb):
        self._set_reg_value(self._eb_inds, self._eb_box, eb)
        self._set_reg_value(self._fb_inds, self._fb_box, fb)
        self._eb_value = eb
        self._fb_value = fb
        self._update_addr_value()

    def set_s_value(self, x):
        self._set_reg_value(self._s_inds, self._s_box, x)
        self._s_value = x
        self._update_addr_value()

    def set_fext_value(self, x):
        self._set_reg_value(self._fext_inds, self._fext_box, x)
        self._fext_value = x
        self._update_addr_value()

    def _setup_ui(self, color):
        # Set up our basic layout
        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(3)
        layout.setMargin(1)

        # Construct register groups for EB, FEXT, FB, and S
        eb_frame, self._eb_box = self._create_reg(self._eb_inds, 'EBANK', 3, color)
        fext_frame, self._fext_box = self._create_reg(self._fext_inds, 'FEXT', 3, color)
        fb_frame, self._fb_box = self._create_reg(self._fb_inds, 'FBANK', 5, color)
        s_frame, self._s_box = self._create_reg(self._s_inds, '', 12, color)
        layout.addWidget(eb_frame)
        layout.addWidget(fext_frame)
        layout.addWidget(fb_frame)
        layout.addWidget(s_frame)

        # Create a grouping widget for the S label and decoded octal value box
        label_value = QWidget(self)
        label_value.setMinimumWidth(100)
        lv_layout = QHBoxLayout(label_value)
        lv_layout.setSpacing(3)
        lv_layout.setMargin(1)
        lv_layout.setContentsMargins(0, 32, 0, 0)
        label_value.setLayout(lv_layout)
        layout.addWidget(label_value)

        # Create a value box for displaying the overall decoded address
        self._addr_value = QLineEdit(label_value)
        self._addr_value.setReadOnly(True)
        self._addr_value.setMaximumSize(65, 32)
        self._addr_value.setText('0000')
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        self._addr_value.setFont(font)
        self._addr_value.setAlignment(Qt.AlignCenter)
        lv_layout.addWidget(self._addr_value)
        
        # Create a label to show 'S'
        label = QLabel('S', label_value)
        font = label.font()
        font.setPointSize(14)
        font.setBold(True)
        label.setFont(font)
        lv_layout.addWidget(label)

        # Add some spacing to account for lack of parity indicators
        layout.addSpacing(36)

    def _update_addr_value(self):
        # Get the values of all tracked registers
        s = self._s_value
        eb = self._eb_value
        fb = self._fb_value
        fext = self._fext_value

        self._addr_value.setText(agc.format_addr(s, eb, fb, fext))

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
