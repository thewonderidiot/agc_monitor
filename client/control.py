from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QGridLayout, QLabel, QGroupBox, QCheckBox
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from indicator import Indicator
from usb_msg import AddressGroup, ControlReg

class Control(QFrame):
    def __init__(self, parent, if_thread):
        super().__init__(parent)
        self.if_thread = if_thread

        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout = QHBoxLayout(self)
        self.setLayout(layout)

        nh_group = QGroupBox('INH', self)
        nh_group.setMaximumWidth(100)
        layout.addWidget(nh_group)
        layout.setMargin(1)
        layout.setSpacing(1)

        nh_layout = QGridLayout(nh_group)
        nh_layout.setMargin(1)
        nh_layout.setSpacing(1)
        nh_group.setLayout(nh_layout)

        self.mnhrpt_check, self.mnhrpt_ind = self._create_inh_control('RPT', nh_group, nh_layout, 0)
        self.mnhnc_check, self.mnhnc_ind = self._create_inh_control('INC', nh_group, nh_layout, 1)
        self.nhalga_check, self.nhalga_ind = self._create_inh_control('ALGA', nh_group, nh_layout, 2)

        self.mnhrpt_check.stateChanged.connect(self._set_mnhrpt)
        self.mnhnc_check.stateChanged.connect(self._set_mnhnc)
        self.nhalga_check.stateChanged.connect(self._set_nhalga)

    def _set_mnhrpt(self, on):
        self.mnhrpt_ind.setOn(on)
        val = 1 if on else 0
        self.if_thread.write(AddressGroup.Control, ControlReg.MNHRPT, val)

    def _set_mnhnc(self, on):
        self.mnhnc_ind.setOn(on)
        val = 1 if on else 0
        self.if_thread.write(AddressGroup.Control, ControlReg.MNHNC, val)

    def _set_nhalga(self, on):
        self.nhalga_ind.setOn(on)
        val = 1 if on else 0
        self.if_thread.write(AddressGroup.Control, ControlReg.NHALGA, val)

    def _create_inh_control(self, name, parent, layout, col):
        label = QLabel(name)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(8)
        label.setFont(font)
        layout.addWidget(label, 0, col)

        ind = Indicator(parent, QColor(255, 120, 0))
        ind.setMinimumSize(20, 20)
        layout.addWidget(ind, 1, col)

        check = QCheckBox(parent)
        layout.addWidget(check, 2, col)
        layout.setAlignment(check, Qt.AlignRight)

        return check, ind

