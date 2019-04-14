from PySide2.QtWidgets import QWidget, QFrame, QGridLayout, QLabel, QLineEdit
from PySide2.QtGui import QFont
from PySide2.QtCore import Qt
from configparser import ConfigParser
import os
import usb_msg as um

class Measurements(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self._usbif = usbif

        cfg_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'monitor.cfg')
        config = ConfigParser()
        config.read(cfg_file)
        self._bplssw_rt = float(config['BPLSSW']['RT'])
        self._bplssw_rb = float(config['BPLSSW']['RB'])
        self._p4sw_rt = float(config['P4SW']['RT'])
        self._p4sw_rb = float(config['P4SW']['RB'])
        self._p3v3io_rt = float(config['P3V3IO']['RT'])
        self._p3v3io_rb = float(config['P3V3IO']['RB'])
        self._agc_temp_rt25 = float(config['AGCTEMP']['RT25'])
        self._agc_temp_tcr = float(config['AGCTEMP']['TCR'])
        self._agc_temp_rb = float(config['AGCTEMP']['RB'])

        self._setup_ui()

        usbif.poll(um.ReadStatusMonTemp())
        usbif.poll(um.ReadStatusVccInt())
        usbif.poll(um.ReadStatusVccAux())
        usbif.poll(um.ReadStatusP3v3io())
        usbif.poll(um.ReadStatusAgcTemp())
        usbif.poll(um.ReadStatusBplssw())
        usbif.poll(um.ReadStatusP4sw())
        usbif.listen(self)

    def handle_msg(self, msg):
        if isinstance(msg, um.StatusVccAux):
            self._vccaux.setText('%.02f V' % self._convert_fpga_volts(msg.counts))
        elif isinstance(msg, um.StatusVccInt):
            self._vccint.setText('%.02f V' % self._convert_fpga_volts(msg.counts))
        elif isinstance(msg, um.StatusMonTemp):
            self._mon_temp.setText('%.02f C' % self._convert_mon_temp(msg.counts))
        elif isinstance(msg, um.StatusP3v3io):
            self._p3v3io.setText('%.02f V' % self._convert_agc_volts(msg.counts, self._p3v3io_rt, self._p3v3io_rb))
        elif isinstance(msg, um.StatusBplssw):
            self._bplssw.setText('%.02f V' % self._convert_agc_volts(msg.counts, self._bplssw_rt, self._bplssw_rb))
        elif isinstance(msg, um.StatusP4sw):
            self._p4sw.setText('%.02f V' % self._convert_agc_volts(msg.counts, self._p4sw_rt, self._p4sw_rb))
        elif isinstance(msg, um.StatusAgcTemp):
            self._agc_temp.setText('%.02f C' % self._convert_agc_temp(msg.counts, self._agc_temp_rt25, self._agc_temp_tcr, self._agc_temp_rb))

    def _convert_mon_temp(self, counts):
        # Taken from UG480 p.33
        return ((counts * 503.975) / 4096.0) - 273.15

    def _convert_fpga_volts(self, counts):
        # Taken from UG480 p.34
        return (counts / 4096.0) * 3

    def _convert_agc_volts(self, counts, rt, rb):
        return (counts / 4096.0) * (rt + rb) / rb

    def _convert_agc_temp(self, counts, rt25, tcr, rb):
        if counts < 0x400:
            return 0
        rt = rb * ((3.3 / (counts / 4096.0)) - 1)
        return 25 + ((rt / rt25) - 1) / (tcr/1e6)

    def _setup_ui(self):
        self.setFrameStyle(QFrame.StyledPanel | QFrame.Raised)

        layout = QGridLayout(self)
        self.setLayout(layout)
        layout.setMargin(1)
        layout.setHorizontalSpacing(10)
        layout.setVerticalSpacing(1)

        self._create_header('MONITOR', layout, 0)
        self._mon_temp = self._create_meas('TEMP', layout, 1, 0, True)
        self._vccint = self._create_meas('VCCINT', layout, 2, 0, False)
        self._vccaux = self._create_meas('VCCAUX', layout, 3, 0, False)
        self._p3v3io = self._create_meas('+3V3IO', layout, 4, 0, False)

        self._create_header('AGC', layout, 2)
        self._agc_temp = self._create_meas('TEMP', layout, 1, 2, True)
        self._bplssw = self._create_meas('BPLSSW', layout, 2, 2, False)
        self._p4sw = self._create_meas('+4SW', layout, 3, 2, False)

        label = QLabel('MEASUREMENTS', self)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label, 4, 2, 1, 2, Qt.AlignRight)
    
    def _create_header(self, name, layout, col):
        label = QLabel(name, self)
        font = label.font()
        font.setPointSize(10)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, 0, col, 1, 2)
        layout.setAlignment(label, Qt.AlignCenter)

    def _create_meas(self, name, layout, row, col, temp):
        label = QLabel(name, self)
        font = label.font()
        font.setPointSize(8)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, row, col)
        layout.setAlignment(label, Qt.AlignRight)

        meas_value = QLineEdit(self)
        meas_value.setReadOnly(True)
        meas_value.setMaximumSize(65, 32)
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        meas_value.setFont(font)
        meas_value.setAlignment(Qt.AlignCenter)
        if temp:
            meas_value.setText('0.00 C')
        else:
            meas_value.setText('0.00 V')
        layout.addWidget(meas_value, row, col + 1)
        layout.setAlignment(meas_value, Qt.AlignLeft)

        return meas_value
