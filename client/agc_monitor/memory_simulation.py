from PySide2.QtWidgets import QHBoxLayout, QWidget, QPushButton, QFileDialog
from PySide2.QtCore import Qt, QThread
from memory_dump import MemoryDump
import usb_msg as um

class MemorySimulation(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        # Set up the UI
        self._setup_ui()

    def _dump_fixed(self):
        self._thread = QThread(self)
        self._md = MemoryDump(self._usbif, um.ReadFixed, um.Fixed, 0o44, 0o2000)
        self._md.moveToThread(self._thread)
        self._thread.started.connect(self._md.dump_memory)
        self._md.finished.connect(self._thread.quit)
        self._thread.start()

    def _setup_ui(self):
        layout = QHBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(2)

        b = QPushButton('Dump Fixed', self)
        b.pressed.connect(self._dump_fixed)
        layout.addWidget(b)

