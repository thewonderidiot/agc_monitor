from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QVBoxLayout, QGridLayout, QLabel, QGroupBox, QCheckBox
from PySide2.QtGui import QFont, QColor
from PySide2.QtCore import Qt
from collections import OrderedDict
from indicator import Indicator
import usb_msg as um

STOP_CONDS = OrderedDict([
    ('T12', 't12'),
    ('NISQ', 'nisq'),
])

class CompStop(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self.usbif = usbif
        self.stop_switches = {}
        self.stop_inds = {}

        self._setup_ui()

    def _set_stop_conds(self, on):
        self.usbif.send(um.WriteControlStop(
            t12 = self.stop_switches['t12'].isChecked(),
            nisq = self.stop_switches['nisq'].isChecked()
        ))

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

    def _create_stop_cond(self, label_text, name, layout, col):
        # Create an indicator to show stop status
        ind = Indicator(self, QColor(255, 0, 0))
        ind.setFixedSize(20, 20)
        layout.addWidget(ind, 0, col)
        layout.setAlignment(ind, Qt.AlignCenter)
        self.stop_inds[name] = ind

        # Add a switch to control the stop control state
        check = QCheckBox(self)
        layout.addWidget(check, 1, col)
        layout.setAlignment(check, Qt.AlignCenter)
        check.stateChanged.connect(self._set_stop_conds)
        self.stop_switches[name] = check

        # Create a label for the inhibit switch
        label = QLabel(label_text, self)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(8)
        label.setFont(font)
        layout.addWidget(label, 2, col)
