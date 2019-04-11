from PySide2.QtWidgets import QFrame, QVBoxLayout, QWidget
from PySide2.QtCore import Qt
from memory_simulation import MemorySimulation
from core_rope_sim import CoreRopeSim
from measurements import Measurements
from alarms import Alarms

class AlarmMemPanel(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        # Set up the UI
        self._setup_ui()

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setAlignment(Qt.AlignTop)
        layout.setSpacing(2)
        layout.setMargin(2)
        layout.addSpacing(20)

        self._alarms = Alarms(self, self._usbif)
        layout.addWidget(self._alarms)

        self._meas = Measurements(self, self._usbif)
        layout.addWidget(self._meas)

        self._core_rope_sim = CoreRopeSim(self, self._usbif)
        layout.addWidget(self._core_rope_sim)
        layout.setAlignment(self._core_rope_sim, Qt.AlignTop)

        #self._mem_sim = MemorySimulation(self, self._usbif)
        #layout.addWidget(self._mem_sim)
