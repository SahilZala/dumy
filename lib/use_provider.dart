import 'package:flutter/cupertino.dart';

class Search extends ChangeNotifier{
  String _search = "";
  String get search => _search;

  void setSearch(String s)
  {
    _search = s;
    notifyListeners();
  }
}