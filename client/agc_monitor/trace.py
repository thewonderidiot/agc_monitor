from PySide2.QtWidgets import QFrame, QVBoxLayout, QLabel, QTableWidget, QTableWidgetItem, QHeaderView, QPushButton
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
import usb_msg as um
import agc

class Trace(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._setup_ui()

        usbif.listen(self)

    def handle_msg(self, msg):
        if isinstance(msg, um.Trace):
            part = msg.addr >> 14
            idx = msg.addr & 0x0FFF;
            if part == 0:
                self._m[idx] = msg.data
            elif part == 1:
                self._z[idx] = msg.data
            elif part == 2:
                self._b[idx] = msg.data
            elif part == 3:
                self._w[idx] = msg.data

            inst = (self._m[idx], self._z[idx], self._b[idx], self._w[idx])
            if None not in inst:
                r = 1023 - idx

                m = self._m[idx]
                count = (m >> 4) & 1
                eb = (m >> 5) & 0o7
                fb = (m >> 8) & 0o37
                fext = (m >> 13) & 0o7
                if fb >= 0o30 and fext & 0o4:
                    print(oct(m))
                    fb += ((fext & 0o3) + 1) * 0o10

                inst, addr = agc.disassemble_inst(self._b[idx], count)

                self._table.item(r, 0).setText('E%o' % eb)
                self._table.item(r, 1).setText('%2o' % fb)
                self._table.item(r, 2).setText('%04o' % self._z[idx])
                self._table.item(r, 3).setText(inst)
                self._table.item(r, 4).setText(addr)
                self._table.item(r, 5).setText('%05o' % self._w[idx])

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Set up our basic layout
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(1)
        layout.setMargin(1)

        self._table = QTableWidget(1024, 6, self)
        layout.addWidget(self._table)

        for c,n in enumerate(['EB', 'FB', 'Z', 'I', 'S', 'W']):
            item = QTableWidgetItem(n)
            self._table.setHorizontalHeaderItem(c, item)

        font = self._table.horizontalHeader().font()
        font.setPointSize(8)
        font.setBold(True)
        item.setFont(font)

        self._table.horizontalHeader().setFont(font)
        self._table.verticalHeader().setFont(font)

        font.setBold(False)

        for r in range(1024):
            for c in range(6):
                item = QTableWidgetItem('')
                item.setFont(font)
                item.setFlags(Qt.ItemIsSelectable | Qt.ItemIsDragEnabled | Qt.ItemIsEnabled)
                self._table.setItem(r, c, item)

        self._table.setColumnWidth(0, 10)
        self._table.setColumnWidth(1, 10)
        for c in range(2, 6):
            self._table.horizontalHeader().setSectionResizeMode(c, QHeaderView.Stretch)

        self._table.resizeRowsToContents()
        self._table.verticalScrollBar().setValue(self._table.verticalScrollBar().maximum())

        b = QPushButton('Dump', self)
        layout.addWidget(b)
        b.pressed.connect(self._dump_trace)

    def _dump_trace(self):
        self._m = [None]*1024
        self._z = [None]*1024
        self._b = [None]*1024
        self._w = [None]*1024

        for i in range(1024):
            self._usbif.send(um.ReadTrace(addr=(i | 0x0000)))
            self._usbif.send(um.ReadTrace(addr=(i | 0x4000)))
            self._usbif.send(um.ReadTrace(addr=(i | 0x8000)))
            self._usbif.send(um.ReadTrace(addr=(i | 0xC000)))
