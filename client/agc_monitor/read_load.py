from PySide2.QtWidgets import QWidget, QFrame, QHBoxLayout, QVBoxLayout, QGridLayout, \
                              QLabel, QGroupBox, QButtonGroup, QRadioButton, QPushButton
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
import usb_msg as um

class ReadLoad(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self._s1_s2_switches = {}
        self._usbif = usbif

        self._setup_ui()

        usbif.send(um.WriteControlLoadReadS1S2(0, 0, 0, 0, 0))

    def _update_s1_s2_switches(self, state):
        switch_states = {switch: self._s1_s2_switches[switch].isChecked() for switch in self._s1_s2_switches.keys()}
        self._usbif.send(um.WriteControlLoadReadS1S2(**switch_states))

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setMargin(1)
        layout.setSpacing(1)

        adv_widget = QWidget(self)
        layout.addWidget(adv_widget)
        adv_layout = QVBoxLayout(adv_widget)
        adv_layout.addSpacing(15)
        l = QLabel('ADV\nS', adv_widget)
        l.setAlignment(Qt.AlignCenter)
        font = l.font()
        font.setPointSize(7)
        font.setBold(True)
        l.setFont(font)
        adv_layout.addWidget(l)

        b = QPushButton(adv_widget)
        b.setFixedSize(20,20)
        b.pressed.connect(lambda: self._usbif.send(um.WriteControlAdvanceS()))
        adv_layout.addWidget(b)
        adv_layout.setAlignment(b, Qt.AlignCenter)

        l = QLabel('CRS\nPARITY', adv_widget)
        l.setFont(font)
        l.setAlignment(Qt.AlignCenter)
        adv_layout.addWidget(l, Qt.AlignCenter)

        b1, b2, b3, s1, s2, s3 = self._create_switch_group(layout, 'LOAD', 'PRESET\nCHAN',
                                                           ['ODD', 'EVEN'], ['S1', 'S2'], ['S1', 'S2'])
        b1.pressed.connect(lambda: self._usbif.send(um.WriteControlLoadS()))
        b2.pressed.connect(lambda: self._usbif.send(um.WriteControlLoadPreset()))
        b3.pressed.connect(lambda: self._usbif.send(um.WriteControlLoadChan()))
        self._s1_s2_switches['load_preset'] = s2
        self._s1_s2_switches['load_chan'] = s3
        s2.toggled.connect(self._update_s1_s2_switches)
        s3.toggled.connect(self._update_s1_s2_switches)

        b1, b2, b3, s1, s2, s3 = self._create_switch_group(layout, 'READ', 'PRESET\nCHAN',
                                                           None, ['S1', 'S2'], ['S1', 'S2'])
        b1.pressed.connect(lambda: self._usbif.send(um.WriteControlReadS()))
        b2.pressed.connect(lambda: self._usbif.send(um.WriteControlReadPreset()))
        b3.pressed.connect(lambda: self._usbif.send(um.WriteControlReadChan()))
        self._s1_s2_switches['read_preset'] = s2
        self._s1_s2_switches['read_chan'] = s3
        s2.toggled.connect(self._update_s1_s2_switches)
        s3.toggled.connect(self._update_s1_s2_switches)

        b1, b2, b3, s1, s2, s3 = self._create_switch_group(layout, 'START', '\nRESTART',
                                                           None, ['S1', 'S2'], None)
        b1.pressed.connect(lambda: self._usbif.send(um.WriteControlStartS()))
        b2.pressed.connect(lambda: self._usbif.send(um.WriteControlStartPreset()))
        b3.pressed.connect(lambda: self._usbif.send(um.WriteControlStart()))
        self._s1_s2_switches['start_preset'] = s2
        s2.toggled.connect(self._update_s1_s2_switches)

        pro_widget = QWidget(self)
        layout.addWidget(pro_widget)
        pro_layout = QVBoxLayout(pro_widget)
        pro_layout.addSpacing(15)

        l = QLabel('PROCEED', pro_widget)
        l.setAlignment(Qt.AlignCenter)
        l.setFont(font)
        pro_layout.addWidget(l)

        b = QPushButton(pro_widget)
        b.setFixedSize(20,20)
        pro_layout.addWidget(b)
        pro_layout.setAlignment(b, Qt.AlignCenter | Qt.AlignTop)
        b.pressed.connect(lambda: self._usbif.send(um.WriteControlProceed()))

        l = QLabel('RESET\nERROR', pro_widget)
        l.setAlignment(Qt.AlignCenter)
        l.setFont(font)
        pro_layout.addWidget(l)

        b = QPushButton(pro_widget)
        b.setFixedSize(20,20)
        pro_layout.addWidget(b)
        pro_layout.setAlignment(b, Qt.AlignCenter | Qt.AlignTop)


    def _create_switch_group(self, layout, group_name, button3, switch1, switch2, switch3):
        group_box = QGroupBox(group_name, self)
        layout.addWidget(group_box)
        group_layout = QGridLayout(group_box)
        group_box.setLayout(group_layout)
        group_layout.setMargin(0)
        group_layout.setSpacing(0)
        
        l = QLabel('S', group_box)
        l.setAlignment(Qt.AlignCenter)

        font = l.font()
        font.setPointSize(7)
        font.setBold(True)
        l.setFont(font)
        l.setMinimumWidth(30)
        group_layout.addWidget(l, 0, 0, Qt.AlignBottom)

        l = QLabel('PRESET', group_box)
        l.setAlignment(Qt.AlignCenter)
        l.setFont(font)
        l.setMinimumWidth(30)
        group_layout.addWidget(l, 0, 1, Qt.AlignBottom)

        l = QLabel(button3, group_box)
        l.setAlignment(Qt.AlignCenter)
        l.setFont(font)
        l.setMinimumWidth(30)
        group_layout.addWidget(l, 0, 2, Qt.AlignBottom)

        b1 = QPushButton(group_box)
        b1.setFixedSize(20,20)
        group_layout.addWidget(b1, 1, 0, Qt.AlignCenter)

        b2 = QPushButton(group_box)
        b2.setFixedSize(20,20)
        group_layout.addWidget(b2, 1, 1, Qt.AlignCenter)

        b3 = QPushButton(group_box)
        b3.setFixedSize(20,20)
        group_layout.addWidget(b3, 1, 2, Qt.AlignCenter)

        s1 = self._create_switch(group_box, group_layout, 0, switch1)
        s2 = self._create_switch(group_box, group_layout, 1, switch2)
        s3 = self._create_switch(group_box, group_layout, 2, switch3)

        return b1, b2, b3, s1, s2, s3

    def _create_switch(self, box, layout, col, labels):
        if labels is None:
            return None

        l = QLabel(labels[0], box)
        l.setMinimumHeight(20)
        l.setAlignment(Qt.AlignCenter | Qt.AlignBottom)

        font = l.font()
        font.setPointSize(7)
        font.setBold(True)
        l.setFont(font)
        layout.addWidget(l, 3, col, Qt.AlignBottom | Qt.AlignCenter)

        r1 = QRadioButton(box)
        r1.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        layout.addWidget(r1, 4, col, Qt.AlignCenter)

        r2 = QRadioButton(box)
        r2.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        layout.addWidget(r2, 5, col, Qt.AlignCenter)

        l = QLabel(labels[1], box)
        l.setAlignment(Qt.AlignCenter)
        l.setFont(font)
        layout.addWidget(l, 6, col, Qt.AlignTop | Qt.AlignCenter)

        g = QButtonGroup(box)
        g.addButton(r1)
        g.addButton(r2)
        r1.setChecked(True)

        return r2
