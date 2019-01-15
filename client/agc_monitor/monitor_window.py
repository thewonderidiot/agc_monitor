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

        # Construct the USB interface thread first, since widgets need to know
        # where to find it
        self.if_thread = USBInterface()

        # Set up the UI
        self._setup_ui()

        # Kick off the UI thread and try to connect to the device
        self.if_thread.start()
        self.connect()

    def _setup_ui(self):
        # Add a dropdown menu for various non-original actions
        menu = self.menuBar().addMenu('Monitor')
        menu.addAction('Connect', self.connect)

        # Create a status bar widget to display connection state
        # FIXME: Replace with an indicator if this becomes automatic?
        status_bar = self.statusBar()
        self.status = QLabel('')
        status_bar.addWidget(self.status)

        # Create a central widget, give it a layout, and set it up
        central = QWidget(self)
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        central.setLayout(layout)
        layout.setSpacing(2)

        # Add all of the registers for display
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

        # Add the control panel
        self.ctrl_panel = Control(None, self.if_thread)
        layout.addWidget(self.ctrl_panel)

    def connect(self):
        connected = self.if_thread.connect()
        if connected:
            message = 'Connected!'
        else:
            message = 'Device not found.'

        self.status.setText(message)
