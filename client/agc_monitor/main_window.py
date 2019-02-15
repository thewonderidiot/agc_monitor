from PySide2.QtWidgets import QMainWindow, QHBoxLayout, QLabel, QWidget
from monitor_panel import MonitorPanel
# from alarm_mem_panel import AlarmMemPanel
from usb_interface import USBInterface
from dsky import DSKY
import resources

class MainWindow(QMainWindow):
    def __init__(self, parent):
        super().__init__(parent)
        self.setWindowTitle('AGC Monitor')

        # Construct the USB interface thread first, since widgets need to know
        # where to find it
        self._usbif = USBInterface()
        self._usbif.connected.connect(self.connected)

        # Set up the UI
        self._setup_ui()
        self._dsky = DSKY(self, self._usbif)

        # Kick off the UI thread and try to connect to the device
        self._usbif.start()

    def _setup_ui(self):
        # Create a status bar widget to display connection state
        # FIXME: Replace with an indicator?
        status_bar = self.statusBar()
        self._status = QLabel('')
        status_bar.addWidget(self._status)

        # Create a central widget, give it a layout, and set it up
        central = QWidget(self)
        self.setCentralWidget(central)
        layout = QHBoxLayout(central)
        central.setLayout(layout)
        layout.setSpacing(0)
        layout.setMargin(0)

        # self._alarm_mem_panel = AlarmMemPanel(central, self._usbif)
        # layout.addWidget(self._alarm_mem_panel)

        self._monitor_panel = MonitorPanel(central, self._usbif)
        layout.addWidget(self._monitor_panel)

    def connected(self, connected):
        if connected:
            message = 'Connected!'
        else:
            message = 'Device not found.'

        self._status.setText(message)
        
    def closeEvent(self, event):
        self._usbif.close()
