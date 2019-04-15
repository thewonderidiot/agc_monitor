from PySide2.QtCore import QObject, Signal, QTimer, QElapsedTimer, Qt
import bisect
import array
import agc

class MemoryDump(QObject):
    finished = Signal()

    def __init__(self, usbif, read_msg, data_msg, num_banks, bank_size, switches, aux_switch=None):
        QObject.__init__(self)

        self._usbif = usbif
        self._read_msg = read_msg
        self._data_msg = data_msg
        self._num_banks = num_banks
        self._bank_size = bank_size

        self._data = []
        self._read_addrs = []
        self._bank = 0

        self._switches = switches
        self._aux_switch = aux_switch

        self._timer = QElapsedTimer()
        self._timer.start()
        self._check_timer = QTimer()
        self._check_timer.timeout.connect(self._check_progress)

        usbif.listen(self)

    def handle_msg(self, msg):
        if isinstance(msg, self._data_msg):
            if msg.addr in self._read_addrs:
                self._timer.restart()
                bisect.insort(self._data, msg)

                last_addr = self._read_addrs[-1]
                self._read_addrs.remove(msg.addr)
                if not self._read_addrs:
                    self._dump_next_bank()

                elif msg.addr == last_addr:
                    self._dump_addrs(self._read_addrs)

    def _check_progress(self):
        if self._timer.elapsed() >= 500:
            self._dump_addrs(self._read_addrs)

    def _dump_addrs(self, addrs):
        self._read_addrs = addrs
        for a in addrs:
            self._usbif.send(self._read_msg(a))

    def _dump_next_bank(self):
        while self._bank < self._num_banks:
            if self._bank < 0o44:
                sw = self._switches[self._bank]
            else:
                sw = self._aux_switch

            if sw.isChecked():
                sw.setCheckState(Qt.PartiallyChecked)
                break

            self._bank += 1

        if self._bank == self._num_banks:
            self._complete_dump()
            return

        bank_start = self._bank * self._bank_size
        bank_end = bank_start + self._bank_size
        self._dump_addrs(list(range(bank_start, bank_end)))

        self._bank += 1

    def _complete_dump(self):
        self._check_timer.stop()

        for sw in self._switches:
            sw.setTristate(False)
            sw.update()

        if self._aux_switch:
            self._aux_switch.setTristate(False)
            self._aux_switch.update()

        data = array.array('H')
        data.fromlist([agc.pack_word(m.data, m.parity) for m in self._data])
        data.byteswap()

        with open(self._filename, 'wb') as f:
            data.tofile(f)

        self.finished.emit()

    def dump_memory(self, filename):
        self._filename = filename
        self._bank = 0
        self._data = []
        self._timer.restart()
        self._check_timer.start(5)
        self._dump_next_bank()
