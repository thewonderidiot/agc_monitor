from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QVBoxLayout, QGridLayout, \
                              QLabel, QGroupBox, QCheckBox, QRadioButton
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from collections import OrderedDict
import usb_msg as um

WRITE_W_POSITIONS = OrderedDict([
    ('ALL', um.WriteWMode.ALL),
    ('S', um.WriteWMode.S),
    ('I', um.WriteWMode.I),
    ('S && I', um.WriteWMode.S_I),
    ('P', um.WriteWMode.P),
    ('P && I', um.WriteWMode.P_I),
    ('P && S', um.WriteWMode.P_S),
])

TIME_SWITCHES = OrderedDict([
    ('t01', '1'),
    ('t02', '2'),
    ('t03', '3'),
    ('t04', '4'),
    ('t05', '5'),
    ('t06', '6'),
    ('t07', '7'),
    ('t08', '8'),
    ('t09', '9'),
    ('t10', '10'),
    ('t11', '11'),
    ('t12', '12'),
])

PULSE_SWITCHES = OrderedDict([
    ('a', 'A'),
    ('l', 'L'),
    ('q', 'Q'),
    ('z', 'Z'),
    ('rch', 'RCH'),
    ('wch', 'WCH'),
    ('g', 'G'),
    ('b', 'B'),
    ('y', 'Y'),
    ('ru', 'RU'),
    ('sp1', ''),
    ('sp2', ''),
])

class WriteW(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self._usbif = usbif
        self._time_switches = {}
        self._pulse_switches = {}
        self._mode = WRITE_W_POSITIONS['ALL']

        self._setup_ui()

    def _update_mode(self, mode):
        self._mode = mode
        self._send_mode(self._s2.isChecked())

    def _send_mode(self, s1_s2):
        self._usbif.send(um.WriteControlWriteW(mode=self._mode, s1_s2=s1_s2))

    def _send_times(self, state):
        time_states = {s: self._time_switches[s].isChecked() for s in self._time_switches.keys()}
        self._usbif.send(um.WriteControlTimeSwitches(**time_states))

    def _send_pulses(self, state):
        pulse_states = {s: self._pulse_switches[s].isChecked() for s in self._pulse_switches.keys()}
        self._usbif.send(um.WriteControlPulseSwitches(**pulse_states))

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setMargin(1)
        layout.setSpacing(1)

        s1_s2 = QWidget(self)
        s1_s2_layout = QHBoxLayout(s1_s2)
        s1_s2.setLayout(s1_s2_layout)
        s1_s2_layout.setMargin(1)
        s1_s2_layout.setSpacing(0)
        self._s1 = QRadioButton('S1', s1_s2)
        self._s1.setLayoutDirection(Qt.RightToLeft)
        self._s1.setChecked(True)
        self._s2 = QRadioButton('S2', s1_s2)
        self._s2.toggled.connect(lambda s: self._send_mode(s))
        s1_s2_layout.addWidget(self._s1)
        s1_s2_layout.setAlignment(self._s1, Qt.AlignLeft)
        s1_s2_layout.addWidget(self._s2)
        s1_s2_layout.setAlignment(self._s2, Qt.AlignLeft)

        layout.addWidget(s1_s2)
        layout.setAlignment(s1_s2, Qt.AlignRight)

        write_w_box = QGroupBox('WRITE W', self)
        write_w_layout = QGridLayout(write_w_box)
        write_w_box.setLayout(write_w_layout)
        write_w_layout.setMargin(1)
        write_w_layout.setSpacing(1)

        row = 0
        col = 0
        for label, mode in WRITE_W_POSITIONS.items():
            pos = QRadioButton(label, write_w_box)
            if label == 'ALL':
                pos.setChecked(True)
            pos.pressed.connect(lambda m=mode: self._update_mode(m))
            write_w_layout.addWidget(pos, row, col)
            col += 1
            if row == 0 or col >= 3:
                col = 0
                row += 1

        layout.addWidget(write_w_box)

        switch_frame = QFrame(self)
        switch_frame.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)
        switch_layout = QGridLayout(switch_frame)
        switch_layout.setMargin(1)
        switch_layout.setSpacing(1)
        switch_frame.setLayout(switch_layout)

        layout.addWidget(switch_frame)

        row = self._add_switches(switch_frame, switch_layout, TIME_SWITCHES, self._time_switches, self._send_times, row)
        sep = QFrame(switch_frame)
        sep.setFrameStyle(QFrame.HLine | QFrame.Raised)
        switch_layout.addWidget(sep, row, 0, 1, 6)
        row += 1

        self._add_switches(switch_frame, switch_layout, PULSE_SWITCHES, self._pulse_switches, self._send_pulses, row)


    def _add_switches(self, switch_frame, switch_layout, switches, switch_dict, switch_fn, row):
        col = 0
        for v,l in switches.items():
            check = QCheckBox(switch_frame)
            check.setFixedSize(20,20)
            check.stateChanged.connect(switch_fn)
            switch_dict[v] = check
            switch_layout.addWidget(check, row, col)
            switch_layout.setAlignment(check, Qt.AlignCenter)

            label = QLabel(l, switch_frame)
            font = label.font()
            font.setPointSize(8)
            label.setFont(font)
            switch_layout.addWidget(label, row+1, col)
            switch_layout.setAlignment(label, Qt.AlignCenter)

            col += 1
            if col >= 6:
                col = 0
                row += 2

        return row
