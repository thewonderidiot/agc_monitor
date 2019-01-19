from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QVBoxLayout, QGridLayout, QLabel, QGroupBox, QCheckBox
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from indicator import Indicator
from collections import OrderedDict
import usb_msg as um

INH_SWITCHES = OrderedDict([
    ('RPT', um.WriteControlMNHRPT),
    ('INC', um.WriteControlMNHNC),
    ('ALG', um.WriteControlNHALGA),
    ('ST1', um.WriteControlSTRT1),
    ('ST2', um.WriteControlSTRT2),
])

class Control(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self.usbif = usbif
        self.inh_switches = []
        self.inh_inds = []
        self._setup_ui()

    def _set_inh(self, ind, msg, on):
        ind.set_on(on)
        val = 1 if on else 0
        self.usbif.send(msg(val))

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout = QHBoxLayout(self)
        self.setLayout(layout)

        # Create a group box for the inhibit switches
        nh_group = QGroupBox('INH', self)
        nh_group.setAlignment(Qt.AlignCenter)
        layout.addWidget(nh_group)
        layout.setAlignment(nh_group, Qt.AlignTop)
        layout.setMargin(1)
        layout.setSpacing(1)

        # Set up a grid layout to hold the labels, switches, and indicators
        nh_layout = QGridLayout(nh_group)
        nh_group.setLayout(nh_layout)
        nh_layout.setMargin(1)
        nh_layout.setSpacing(1)

        # Construct the inhibit indicators and switches
        col = 0
        for switch, msg in INH_SWITCHES.items():
            self._create_inh_control(switch, nh_group, nh_layout, col)
            ind = self.inh_inds[-1]
            self.inh_switches[-1].stateChanged.connect(lambda on, ind=ind: self._set_inh(ind, msg, on))
            col += 1

        sl_group = QWidget(self)
        layout.addWidget(sl_group)
        sl_layout = QVBoxLayout(sl_group)
        sl_group.setLayout(sl_layout)
        sl_layout.setMargin(1)
        sl_layout.setSpacing(1)
        sl_layout.addSpacing(4)

        stat_group = QWidget(sl_group)
        sl_layout.addWidget(stat_group)
        stat_layout = QGridLayout(stat_group)
        stat_layout.setMargin(3)
        stat_layout.setSpacing(3)

        for col, name in enumerate(['GO\nJAM', 'MON\nSTOP', 'AGC\nRUN', 'CRS\nCYCL']):
            self._create_status_light(name, stat_group, stat_layout, col)

        label = QLabel('CONTROL', sl_group)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        sl_layout.addWidget(label)


    def _create_inh_control(self, name, parent, layout, col):
        # Create a label for the inhibit switch
        label = QLabel(name, parent)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(8)
        label.setFont(font)
        layout.addWidget(label, 0, col)

        # Add an indicator to show inhibit state
        ind = Indicator(parent, QColor(255, 120, 0))
        ind.setFixedSize(20, 20)
        layout.addWidget(ind, 1, col)
        layout.setAlignment(ind, Qt.AlignCenter)

        # Add a switch to control the inhibit state
        check = QCheckBox(parent)
        layout.addWidget(check, 2, col)
        layout.setAlignment(check, Qt.AlignCenter)
        layout.setColumnMinimumWidth(col, 25)

        self.inh_switches.append(check)
        self.inh_inds.append(ind)

    def _create_status_light(self, name, parent, layout, col):
        label = QLabel(name, parent)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(8)
        label.setFont(font)
        layout.addWidget(label, 1, col)

        # Add an indicator to show inhibit state
        ind = Indicator(parent, QColor(255, 0, 0))
        ind.setFixedSize(20, 20)
        layout.addWidget(ind, 2, col)
        layout.setAlignment(ind, Qt.AlignCenter)
