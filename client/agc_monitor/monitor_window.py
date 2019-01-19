from PySide2.QtWidgets import QMainWindow, QVBoxLayout, QWidget, QLabel
from PySide2.QtGui import QColor
from PySide2.QtCore import Qt
from register import Register
from address_register import AddressRegister
from control import Control
from comp_stop import CompStop
from usb_interface import USBInterface

class MonitorWindow(QMainWindow):
    def __init__(self, parent):
        super().__init__(parent)
        self.setWindowTitle('AGC Monitor')

        # Construct the USB interface thread first, since widgets need to know
        # where to find it
        self._usbif = USBInterface()

        # Set up the UI
        self._setup_ui()

        # Kick off the UI thread and try to connect to the device
        self._usbif.start()
        self.connect()

    def _setup_ui(self):
        # Add a dropdown menu for various non-original actions
        menu = self.menuBar().addMenu('Monitor')
        menu.addAction('Connect', self.connect)

        # Create a status bar widget to display connection state
        # FIXME: Replace with an indicator if this becomes automatic?
        status_bar = self.statusBar()
        self._status = QLabel('')
        status_bar.addWidget(self._status)

        # Create a central widget, give it a layout, and set it up
        central = QWidget(self)
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        central.setLayout(layout)
        layout.setSpacing(2)

        # Add all of the registers for display
        self._reg_a = Register(None, 'A', False, QColor(0,255,0))
        layout.addWidget(self._reg_a)
        layout.setAlignment(self._reg_a, Qt.AlignRight)

        self._reg_l = Register(None, 'L', False, QColor(0,255,0))
        layout.addWidget(self._reg_l)
        layout.setAlignment(self._reg_l, Qt.AlignRight)

        self._reg_q = Register(None, 'Q', False, QColor(0,255,0))
        layout.addWidget(self._reg_q)
        layout.setAlignment(self._reg_q, Qt.AlignRight)

        self._reg_z = Register(None, 'Z', False, QColor(0,255,0))
        layout.addWidget(self._reg_z)
        layout.setAlignment(self._reg_z, Qt.AlignRight)

        self._reg_b = Register(None, 'B', False, QColor(0,255,0))
        layout.addWidget(self._reg_b)
        layout.setAlignment(self._reg_b, Qt.AlignRight)

        self._reg_g = Register(None, 'G', True, QColor(0,255,0))
        layout.addWidget(self._reg_g)
        layout.setAlignment(self._reg_g, Qt.AlignRight)

        self._reg_w = Register(None, 'W', True, QColor(0,255,0))
        layout.addWidget(self._reg_w)
        layout.setAlignment(self._reg_w, Qt.AlignRight)

        self._reg_s = AddressRegister(None, QColor(0, 255, 0))
        layout.addWidget(self._reg_s)
        layout.setAlignment(self._reg_s, Qt.AlignRight)

        # Add the control panel
        self._ctrl_panel = Control(None, self._usbif)
        layout.addWidget(self._ctrl_panel)
        layout.setAlignment(self._ctrl_panel, Qt.AlignLeft)

        # Add the computer stop panel
        self._comp_stop = CompStop(None, self._usbif)
        layout.addWidget(self._comp_stop)
        layout.setAlignment(self._comp_stop, Qt.AlignLeft)

    def connect(self):
        connected = self._usbif.connect()
        if connected:
            message = 'Connected!'
        else:
            message = 'Device not found.'

        self._status.setText(message)
