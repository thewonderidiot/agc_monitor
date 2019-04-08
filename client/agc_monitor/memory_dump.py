from PySide2.QtCore import QObject, Signal, QCoreApplication, QTimer, QElapsedTimer
import bisect
import struct


class MemoryDump(QObject):
    finished = Signal()

    def __init__(self, usbif, read_msg, data_msg, num_banks, bank_size):
        QObject.__init__(self)

        self._usbif = usbif
        self._read_msg = read_msg
        self._data_msg = data_msg
        self._num_banks = num_banks
        self._bank_size = bank_size

        self._data = []
        self._read_addrs = []
        self._bank = 0

        self._timer = QElapsedTimer()
        self._check_timer = QTimer()
        self._check_timer.timeout.connect(self._check_progress)
        self._check_timer.start(0.5)

    def handle_msg(self, msg):
        if isinstance(msg, self._data_msg):
            if msg.addr in self._read_addrs:
                self._timer.restart()
                bisect.insort(self._data, msg)

                last_addr = self._read_addrs[-1]
                self._read_addrs.remove(msg.addr)
                if not self._read_addrs:
                    next_bank = self._bank + 1
                    if next_bank < self._num_banks:
                        self._dump_bank(next_bank)
                    else:
                        self.finished.emit()

                elif msg.addr == last_addr:
                    self._dump_addrs(self._read_addrs)

    def _check_progress(self):
        if self._timer.elapsed() >= 500:
            self._dump_addrs(self._read_addrs)

    def _dump_addrs(self, addrs):
        self._read_addrs = addrs
        for a in addrs:
            self._usbif.send(self._read_msg(a))

    def _dump_bank(self, bank):
        self._bank = bank
        bank_start = bank * self._bank_size
        bank_end = bank_start + self._bank_size
        self._dump_addrs(list(range(bank_start, bank_end)))

    def dump_memory(self):
        self._usbif.listen(self)
        self._timer.start()
        self._dump_bank(0)

        # for a in range(b*self._bank_size, (b+1)*self._bank_size):
        #     msg = self._queue.get(True, timeout=0.1)
        #     data = (msg.data & 0o40000) << 1
        #     data |= msg.parity << 14
        #     data |= msg.data & 0o37777
        #     word = struct.pack('>H', data)
        #     rom += word

        # with open('/home/mike/rom.bin', 'wb') as f:
        #     f.write(rom)
