from PySide2.QtGui import QValidator

class RegValidator(QValidator):
    def __init__(self, max_value):
        super().__init__()
        self.max_value = max_value

    def validate(self, text, pos):
        if text == '':
            return QValidator.Acceptable
        try:
            value = int(text, 8)
            if value <= self.max_value:
                return QValidator.Acceptable
            else:
                return QValidator.Invalid
        except:
            return QValidator.Invalid
