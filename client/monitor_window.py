from PySide2.QtWidgets import QMainWindow, QVBoxLayout, QWidget, QLabel
from PySide2.QtGui import QColor
from PySide2.QtCore import Qt
from register import Register
from address_register import AddressRegister
from control import Control
from usb_interface import USBInterface

class MonitorWindow(QMainWindow):
    def __init__(self, parent):
        super().__init__(parent)
        self.setWindowTitle('AGC Monitor')
        self.if_thread = USBInterface()
        self._setup_window()

        self.if_thread.start()
        self.connect()

    def _setup_window(self):
        menu = self.menuBar().addMenu('Monitor')
        menu.addAction('Connect', self.connect)

        status_bar = self.statusBar()
        self.status = QLabel('')
        status_bar.addWidget(self.status)

        central = QWidget(self)
        self.setCentralWidget(central)

        layout = QVBoxLayout(central)
        central.setLayout(layout)
        layout.setSpacing(2)

        self.reg_a = Register(None, 'A', False, QColor(0,255,0))
        layout.addWidget(self.reg_a)
        layout.setAlignment(self.reg_a, Qt.AlignRight)

        self.reg_l = Register(None, 'L', False, QColor(0,255,0))
        layout.addWidget(self.reg_l)
        layout.setAlignment(self.reg_l, Qt.AlignRight)

        self.reg_q = Register(None, 'Q', False, QColor(0,255,0))
        layout.addWidget(self.reg_q)
        layout.setAlignment(self.reg_q, Qt.AlignRight)

        self.reg_z = Register(None, 'Z', False, QColor(0,255,0))
        layout.addWidget(self.reg_z)
        layout.setAlignment(self.reg_z, Qt.AlignRight)

        self.reg_b = Register(None, 'B', False, QColor(0,255,0))
        layout.addWidget(self.reg_b)
        layout.setAlignment(self.reg_b, Qt.AlignRight)

        self.reg_g = Register(None, 'G', True, QColor(0,255,0))
        layout.addWidget(self.reg_g)
        layout.setAlignment(self.reg_g, Qt.AlignRight)

        self.reg_w = Register(None, 'W', True, QColor(0,255,0))
        layout.addWidget(self.reg_w)
        layout.setAlignment(self.reg_w, Qt.AlignRight)

        self.reg_s = AddressRegister(None, QColor(0, 255, 0))
        layout.addWidget(self.reg_s)

        self.ctrl_panel = Control(None, self.if_thread)
        layout.addWidget(self.ctrl_panel)

    def connect(self):
        connected = self.if_thread.connect()
        if connected:
            message = 'Connected!'
        else:
            message = 'Device not found.'

        self.status.setText(message)
