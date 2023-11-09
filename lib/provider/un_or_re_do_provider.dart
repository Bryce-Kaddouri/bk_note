import 'package:flutter/material.dart';

class UnOrReDoProvider with ChangeNotifier {
  bool _canUndo = false;
  bool get canUndo => _canUndo;

  void setCanUndo(bool canUndo) {
    _canUndo = canUndo;
    notifyListeners();
  }

  bool _canRedo = false;
  bool get canRedo => _canRedo;

  void setCanRedo(bool canRedo) {
    _canRedo = canRedo;
    notifyListeners();
  }
}
