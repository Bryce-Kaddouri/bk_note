import 'package:flutter/material.dart';

class TextProvider with ChangeNotifier {
  int _fontSize = 20;
  int get fontSize => _fontSize;

  void setFontSize(int fontSize) {
    _fontSize = fontSize;
    notifyListeners();
  }

  double _color = 0.0;
  double get color => _color;

  Color _colorCalculated = Colors.black;
  Color get colorCalculated => _colorCalculated;

  void setColorCalculated() {
    // color is between 0 and 16777215 (16777216 = 256^3)

    int red = (_color / 65536).floor();
    int green = ((_color - red * 65536) / 256).floor();
    int blue = (_color - red * 65536 - green * 256).floor();

    _colorCalculated = Color.fromRGBO(red, green, blue, 1);

    notifyListeners();
  }

  void setColor(double color) {
    _color = color;
    setColorCalculated();
    notifyListeners();
  }

  bool _isTexting = false;
  bool get isTexting => _isTexting;

  void setIsTexting(bool isTexting) {
    _isTexting = isTexting;
    notifyListeners();
  }
}
