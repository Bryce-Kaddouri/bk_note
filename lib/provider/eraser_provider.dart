import 'package:flutter/material.dart';

class EraserProvider with ChangeNotifier {
  double _strokeWidth = 20;
  double get strokeWidth => _strokeWidth;

  bool _isErasing = false;
  bool get isErasing => _isErasing;

  void setStrokeWidth(double strokeWidth) {
    _strokeWidth = strokeWidth;
    notifyListeners();
  }

  void setIsErasing(bool isErasing) {
    _isErasing = isErasing;
    notifyListeners();
  }
}
