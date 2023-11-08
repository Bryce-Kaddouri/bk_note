import 'package:flutter/material.dart';

class PenProvider with ChangeNotifier {
  double _strokeWidth = 5;
  double get strokeWidth => _strokeWidth;

  void setStrokeWidth(double strokeWidth) {
    _strokeWidth = strokeWidth;
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

  bool _isPennig = false;
  bool get isPennig => _isPennig;

  void setIsPennig(bool isPennig) {
    _isPennig = isPennig;
    notifyListeners();
  }
}
