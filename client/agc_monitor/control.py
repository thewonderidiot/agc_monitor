from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QVBoxLayout, QGridLayout, QLabel, QGroupBox, QCheckBox
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from collections import OrderedDict
from indicator import Indicator
import usb_msg as um

INH_SWITCHES = OrderedDict([
    ('RPT', um.WriteControlMNHRPT),
    ('INC', um.WriteControlMNHNC),
    ('ALG', um.WriteControlNHALGA),
    ('ST1', um.WriteControlSTRT1),
    ('ST2', um.WriteControlSTRT2),
])
STATUS_INDS = OrderedDict([
    ('gojam', 'GO\nJAM'),
    ('mon_stop', 'MON\nSTOP'),
    ('agc_run', 'AGC\nRUN'),
    ('crs_cycle', 'CRS\nCYCL')
])

class Control(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif
        self._inh_switches = []
        self._inh_inds = []
        self._status_inds = {}
        self._setup_ui()

        usbif.poll(um.ReadMonRegStatus())
        usbif.poll(um.ReadControlStopCause())
        usbif.poll(um.ReadStatusSimulation())
        usbif.listen(self)

        for msg in INH_SWITCHES.values():
            usbif.send(msg(0))

    def handle_msg(self, msg):
        if isinstance(msg, um.MonRegStatus):
            self._status_inds['gojam'].set_on(msg.gojam)
            self._status_inds['agc_run'].set_on(msg.run)
        elif isinstance(msg, um.ControlStopCause):
            self._status_inds['mon_stop'].set_on(any(msg))
        elif isinstance(msg, um.StatusSimulation):
            self._status_inds['crs_cycle'].set_on(any(msg))

    def _set_inh(self, ind, msg, on):
        ind.set_on(on)
        val = 1 if on else 0
        self._usbif.send(msg(val))

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
            ind = self._inh_inds[-1]
            self._inh_switches[-1].stateChanged.connect(lambda on, ind=ind, msg=msg: self._set_inh(ind, msg, on))
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

        col = 0
        for name, label in STATUS_INDS.items():
            self._status_inds[name] = self._create_status_light(label, stat_group, stat_layout, col)
            col += 1

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
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, 0, col)

        # Add an indicator to show inhibit state
        ind = Indicator(parent, QColor(255, 120, 0))
        ind.setFixedSize(20, 20)
        layout.addWidget(ind, 1, col)
        layout.setAlignment(ind, Qt.AlignCenter)

        # Add a switch to control the inhibit state
        check = QCheckBox(parent)
        check.setFixedSize(20,20)
        check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
        layout.addWidget(check, 2, col)
        layout.setAlignment(check, Qt.AlignCenter)
        layout.setColumnMinimumWidth(col, 25)

        self._inh_switches.append(check)
        self._inh_inds.append(ind)

    def _create_status_light(self, name, parent, layout, col):
        label = QLabel(name, parent)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, 1, col)

        # Add an indicator to show inhibit state
        ind = Indicator(parent, QColor(255, 0, 0))
        ind.setFixedSize(20, 20)
        layout.addWidget(ind, 2, col)
        layout.setAlignment(ind, Qt.AlignCenter)

        return ind
