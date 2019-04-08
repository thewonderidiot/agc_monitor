from PySide2.QtWidgets import QWidget, QFrame, QGridLayout, \
                              QLabel, QPushButton, QCheckBox
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from collections import OrderedDict
from indicator import Indicator
import usb_msg as um

ALARMS = OrderedDict([
    ('VFAIL', QColor(255,   0,   0)),
    ('OSCAL', QColor(255,   0,   0)),
    ('SCDBL', QColor(255,   0,   0)),
    ('SCAFL', QColor(255,   0,   0)),
    ('CTRAL', QColor(255, 127,   0)),
    ('TCAL',  QColor(255, 127,   0)),
    ('RPTAL', QColor(255, 127,   0)),
    ('FPAL',  QColor(255, 127,   0)),
    ('EPAL',  QColor(255, 127,   0)),
    ('WATCH', QColor(255, 127,   0)),
    ('PIPAL', QColor(180,   0, 255)),
    ('WARN',  QColor(255, 255,   0)),
])

class Alarms(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self._usbif = usbif
        self._alarm_inds = {}

        self._setup_ui()

        #usbif.poll(um.ReadStatusAlarms())
        usbif.listen(self)

        self._reset_alarms()

    def handle_msg(self, msg):
        if isinstance(msg, um.StatusAlarms):
            for v in self._alarm_inds.keys():
                self._alarm_inds[v].set_on(getattr(msg, v))

    def _reset_alarms(self):
        z = (1,) * len(ALARMS)
        self._usbif.send(um.WriteStatusAlarms(*z))

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout = QGridLayout(self)
        self.setLayout(layout)
        layout.setMargin(1)
        layout.setSpacing(1)

        # Construct the alarm indicators
        col = 0
        for n,c in ALARMS.items():
            self._create_alarm(n, c, layout, col)
            col += 1

        check = QCheckBox(self)
        check.setFixedSize(20,20)
        check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
        layout.addWidget(check, 2, 2)
        layout.setAlignment(check, Qt.AlignCenter)
        check.stateChanged.connect(lambda state: self._usbif.send(um.WriteControlDoscal(state)))

        check = QCheckBox(self)
        check.setFixedSize(20,20)
        check.setStyleSheet('QCheckBox::indicator{subcontrol-position:center;}')
        layout.addWidget(check, 2, 3)
        layout.setAlignment(check, Qt.AlignCenter)
        check.stateChanged.connect(lambda state: self._usbif.send(um.WriteControlDbltst(state)))

        b = QPushButton(self)
        b.setFixedSize(20,20)
        layout.addWidget(b, 2, 8, 1, 2)
        layout.setAlignment(b, Qt.AlignCenter)

        label = QLabel('RESET', self)
        label.setAlignment(Qt.AlignRight)
        font = label.font()
        font.setPointSize(8)
        font.setBold(True)
        label.setFont(font)
        label.setMinimumWidth(30)
        layout.addWidget(label, 2, 7, 1, 2)
        layout.setAlignment(label, Qt.AlignCenter)
        b.pressed.connect(lambda: self._reset_alarms())

        label = QLabel('TEST', self)
        label.setAlignment(Qt.AlignRight)
        font = label.font()
        font.setPointSize(8)
        font.setBold(True)
        label.setFont(font)
        label.setMinimumWidth(30)
        layout.addWidget(label, 2, 1, 1, 1)
        layout.setAlignment(label, Qt.AlignRight)

        label = QLabel('ALARMS', self)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label, 2, len(ALARMS)-4, 1, 4, Qt.AlignRight)

    def _create_label(self, text, parent):
        label = QLabel(text, parent)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        label.setMinimumWidth(30)
        return label

    def _create_alarm(self, name, color, layout, col):
        # Create an indicator to show alarm status
        ind = Indicator(self, color)
        ind.setFixedSize(25, 20)
        layout.addWidget(ind, 1, col)
        layout.setAlignment(ind, Qt.AlignCenter)
        self._alarm_inds[name.lower()] = ind

        # Create a label for the indicator
        label = self._create_label(name, self)
        layout.addWidget(label, 0, col, 1, 1)
        layout.setAlignment(label, Qt.AlignCenter | Qt.AlignTop)
