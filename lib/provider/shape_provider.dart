import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ShapeProvier with ChangeNotifier {
  int _strokeWidth = 5;
  int get strokeWidth => _strokeWidth;

  void setStrokeWidth(int strokeWidth) {
    _strokeWidth = strokeWidth;
    notifyListeners();
  }

  double _color = 0.0;
  double get color => _color;

  void setColor(double color) {
    _color = color;
    setColorCalculated();
    notifyListeners();
  }

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

  bool _fillShape = false;
  bool get fillShape => _fillShape;

  void setFillShape(bool fillShape) {
    _fillShape = fillShape;
    notifyListeners();
  }

  int _shapeIndex = -1;
  int get shapeIndex => _shapeIndex;

  void setShapeIndex(int shapeIndex) {
    _shapeIndex = shapeIndex;
    notifyListeners();
  }

  final List<Map<dynamic, dynamic>> _shapeList = [
    {
      LineFactory(): 'Line',
      'icon': PhosphorIconsRegular.lineSegment,
    },
    {
      ArrowFactory(): 'Arrow',
      'icon': PhosphorIconsRegular.arrowUpRight,
    },
    {
      DoubleArrowFactory(): 'Double Arrow',
      'icon': PhosphorIconsRegular.arrowsHorizontal,
    },
    {
      RectangleFactory(): 'Rectangle',
      'icon': PhosphorIconsRegular.rectangle,
    },
    {
      OvalFactory(): 'Oval',
      'icon': PhosphorIconsRegular.circle,
    }
  ];
  List<Map<dynamic, dynamic>> get shapeList => _shapeList;

  bool _isShaping = false;
  bool get isShaping => _isShaping;

  void setIsShaping(bool isShaping) {
    _isShaping = isShaping;
    notifyListeners();
  }
}
