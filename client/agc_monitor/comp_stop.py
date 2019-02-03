from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QVBoxLayout, QGridLayout, \
                              QLabel, QGroupBox, QCheckBox, QRadioButton
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from collections import OrderedDict
from indicator import Indicator
import usb_msg as um

STOP_CONDS = OrderedDict([
    ('T12', 't12'),
    ('NISQ', 'nisq'),
    ('S1', 's1'),
    ('S2', 's2'),
    ('W', 'w'),
    ('S&W', 's_w'),
    ('S&I', 's_i'),
    ('CHAN', 'chan'),
    ('PAR', 'par'),
    ('I', 'i'),
    ('PROG\nSTEP', 'prog_step'),
])

class CompStop(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self._usbif = usbif
        self._stop_switches = {}
        self._stop_inds = {}

        self._setup_ui()

        usbif.poll(um.ReadControlStopCause())
        usbif.subscribe(self, um.ControlStopCause)
        z = (0,)*(len(STOP_CONDS) + 1)
        usbif.send(um.WriteControlStop(*z))

    def handle_msg(self, msg):
        if isinstance(msg, um.ControlStopCause):
            for v in STOP_CONDS.values():
                self._stop_inds[v].set_on(getattr(msg, v))

    def _set_stop_conds(self, on):
        settings = {s: self._stop_switches[s].isChecked() for s in STOP_CONDS.values()}
        settings['s1_s2'] = self._s2.isChecked()
        self._usbif.send(um.WriteControlStop(**settings))

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout = QGridLayout(self)
        self.setLayout(layout)
        layout.setMargin(1)
        layout.setSpacing(1)

        # Construct the stop indicators and switches
        col = 0
        for l,n in STOP_CONDS.items():
            self._create_stop_cond(l, n, layout, col)
            col += 1


        label = QLabel('COMP STOP', self)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label, 3, 0, 1, 4, Qt.AlignRight)

        self._s1 = QRadioButton('S1', self)
        self._s1.setLayoutDirection(Qt.RightToLeft)
        layout.addWidget(self._s1, 3, 5, 1, 2)
        layout.setAlignment(self._s1, Qt.AlignRight)
        self._s1.setChecked(True)
        self._s1.toggled.connect(self._set_stop_conds)

        self._s2 = QRadioButton('S2', self)
        layout.addWidget(self._s2, 3, 6, 1, 2)
        layout.setAlignment(self._s2, Qt.AlignRight)

        font.setPointSize(7)
        self._s1.setFont(font)
        self._s2.setFont(font)

    def _create_stop_cond(self, label_text, name, layout, col):
        # Create an indicator to show stop status
        ind = Indicator(self, QColor(255, 0, 0))
        ind.setFixedSize(25, 20)
        layout.addWidget(ind, 0, col)
        layout.setAlignment(ind, Qt.AlignCenter)
        self._stop_inds[name] = ind

        # Add a switch to control the stop control state
        check = QCheckBox(self)
        check.setFixedSize(20,20)
        check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
        layout.addWidget(check, 1, col)
        layout.setAlignment(check, Qt.AlignCenter)
        check.stateChanged.connect(self._set_stop_conds)
        self._stop_switches[name] = check

        # Create a label for the inhibit switch
        label = QLabel(label_text, self)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        label_height = 2 if '\n' in label_text else 1
        layout.addWidget(label, 2, col, label_height, 1)
        layout.setAlignment(label, Qt.AlignCenter | Qt.AlignTop)
