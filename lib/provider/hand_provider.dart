import 'package:flutter/material.dart';

class HandProvider with ChangeNotifier {
  bool _isHanding = false;
  bool get isHanding => _isHanding;

  void setIsHanding(bool isHanding) {
    _isHanding = isHanding;
    notifyListeners();
  }
}
