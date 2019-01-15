import sys
from PySide2.QtWidgets import QApplication
from monitor_window import MonitorWindow

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MonitorWindow(None)
    window.show()
    app.exec_()
