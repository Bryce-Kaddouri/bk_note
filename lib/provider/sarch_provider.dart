import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  bool _isSearch = false;
  bool get isSearch => _isSearch;

  void setSearch(bool isSearch) {
    _isSearch = isSearch;
    notifyListeners();
  }

  String _searchText = '';
  String get searchText => _searchText;

  void setSearchText(String searchText) {
    _searchText = searchText;
    notifyListeners();
  }
}
