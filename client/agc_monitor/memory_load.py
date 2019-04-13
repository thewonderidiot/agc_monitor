from PySide2.QtCore import QObject, QTimer, Signal, Qt
import array
import os
import agc

class MemoryLoad(QObject):
    finished = Signal()

    def __init__(self, usbif, write_msg, num_banks, bank_size, switches, aux_switch=None):
        QObject.__init__(self)

        self._usbif = usbif
        self._write_msg = write_msg
        self._num_banks = num_banks
        self._bank_size = bank_size

        self._switches = switches
        self._aux_switch = aux_switch
        self._next_bank = 0

        self._timer = QTimer()
        self._timer.timeout.connect(self._load_next_bank)

    def load_memory(self, filename):
        self._load_data = array.array('H')
        with open(filename, 'rb') as f:
            self._load_data.fromfile(f, int(os.path.getsize(filename)/2))
        self._load_data.byteswap()
        self._next_bank = 0
        self._timer.start(20)

    def _load_next_bank(self):
        while self._next_bank <= self._num_banks:
            bank = self._next_bank
            if bank < 0o44:
                sw = self._switches[bank]
            else:
                sw = self._aux_switch

            self._next_bank += 1

            if sw.isChecked():
                sw.setCheckState(Qt.PartiallyChecked)
                break

        if bank == self._num_banks:
            self._complete_load()
            return

        bank_addr = bank * self._bank_size
        words = self._load_data[bank_addr:bank_addr+self._bank_size]

        if len(words) == 0:
            self._complete_load()
            return

        for a,w in enumerate(words):
            d,p = agc.unpack_word(w)
            self._usbif.send(self._write_msg(addr=bank_addr+a, data=d, parity=p))

    def _complete_load(self):
        self._timer.stop()
        for sw in self._switches:
            sw.setTristate(False)
            sw.update()

        if self._aux_switch:
            self._aux_switch.setTristate(False)
            self._aux_switch.update()

        self.finished.emit()
