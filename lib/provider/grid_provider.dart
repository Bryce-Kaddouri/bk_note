import 'package:flutter/material.dart';

class GridProvider with ChangeNotifier {
  bool _isGrid = true;
  bool get isGrid => _isGrid;

  void setGrid(bool isGrid) {
    _isGrid = isGrid;
    notifyListeners();
  }
}
