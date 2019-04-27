from PySide2.QtWidgets import QFrame, QVBoxLayout, QLabel, QTableWidget, QTableWidgetItem, QHeaderView, \
                              QWidget, QPushButton, QGridLayout, QSpacerItem, QFileDialog
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
import usb_msg as um
import agc
import time

TRACE_DEPTH = 16384

class Trace(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif

        self._setup_ui()

        self._dump_idx = 0

        usbif.listen(self)

    def handle_msg(self, msg):
        if isinstance(msg, um.Trace):
            part = msg.addr >> 14
            idx = msg.addr & 0x3FFF;
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
                r = (TRACE_DEPTH - 1) - idx

                m = self._m[idx]
                count = (m >> 4) & 1
                eb = (m >> 5) & 0o7
                fb = (m >> 8) & 0o37
                fext = (m >> 13) & 0o7
                if fb >= 0o30 and fext & 0o4:
                    fb += ((fext & 0o3) + 1) * 0o10

                inst, addr = agc.disassemble_inst(self._b[idx], count)

                self._table.item(r, 0).setText('E%o' % eb)
                self._table.item(r, 1).setText('%2o' % fb)
                self._table.item(r, 2).setText('%04o' % self._z[idx])
                self._table.item(r, 3).setText(inst)
                self._table.item(r, 4).setText(addr)
                self._table.item(r, 5).setText('%06o' % self._w[idx])

                if ((idx + 1) % 1024) == 0 and self._dump_idx != TRACE_DEPTH:
                    self._dump_trace_data()

    def _dump_trace(self):
        self._m = [None] * TRACE_DEPTH
        self._z = [None] * TRACE_DEPTH
        self._b = [None] * TRACE_DEPTH
        self._w = [None] * TRACE_DEPTH

        for r in range(TRACE_DEPTH):
            for c in range(6):
                self._table.item(r, c).setText('')

        self._dump_idx = 0
        self._dump_trace_data()

    def _dump_trace_data(self):
        for i in range(self._dump_idx, self._dump_idx + 1024):
            self._usbif.send(um.ReadTrace(addr=(i | 0x0000)))
            self._usbif.send(um.ReadTrace(addr=(i | 0x4000)))
            self._usbif.send(um.ReadTrace(addr=(i | 0x8000)))
            self._usbif.send(um.ReadTrace(addr=(i | 0xC000)))

        self._dump_idx += 1024

    def _save_trace(self):
        filename, group = QFileDialog.getSaveFileName(self, 'Save Trace CSV', 'traces', 'AGC Trace CSVs (*.csv)')
        if group == '':
            return

        with open(filename, 'w') as f:
            for r in range(TRACE_DEPTH):
                cells = ['']*6
                for c in range(6):
                    cells[c] = self._table.item(r, c).text()

                f.write(', '.join(cells) + '\n')

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        # Set up our basic layout
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(1)
        layout.setMargin(1)

        self._table = QTableWidget(TRACE_DEPTH, 6, self)
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

        for r in range(TRACE_DEPTH):
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

        controls_widget = QWidget(self)
        layout.addWidget(controls_widget)
        controls_layout = QGridLayout(controls_widget)
        controls_layout.setSpacing(0)
        controls_layout.setMargin(0)

        b = self._create_button('DUMP', controls_layout, 1, 1)
        b.pressed.connect(self._dump_trace)

        b = self._create_button('SAVE', controls_layout, 1, 2)
        b.pressed.connect(self._save_trace)

        s = QSpacerItem(260,20)
        controls_layout.addItem(s, 1, 3)

        label = QLabel('TRACE', controls_widget)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignLeft)
        controls_layout.addWidget(label, 1, 4, 2, 1, Qt.AlignLeft)

    def _create_button(self, name, layout, row, col):
        label = QLabel(name, self)
        label.setAlignment(Qt.AlignCenter)
        font = label.font()
        font.setPointSize(7)
        font.setBold(True)
        label.setFont(font)
        label.setMinimumWidth(30)
        layout.addWidget(label, row, col, 1, 1)
        layout.setAlignment(label, Qt.AlignCenter)

        b = QPushButton(self)
        b.setFixedSize(20,20)
        layout.addWidget(b, row+1, col, 1, 1)
        layout.setAlignment(b, Qt.AlignCenter)
        return b
