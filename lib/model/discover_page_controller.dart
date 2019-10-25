import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

class DiscoverPageController with ChangeNotifier{
  final String originTag;
  final String origin;

  String get title => _title;
  String _title;

  String get query => _query;
  String _query;

  set query(String value) {
    _query = value;
  }

  bool get isLoading => _isLoading;
  bool _isLoading;

  bool get loadPopular => _loadPopular;
  bool _loadPopular;

  List<SearchItem> get items => _items;
  List<SearchItem> _items;

  DiscoverPageController({@required this.originTag, this.origin, String title}){
    if(title == null){
      _title = origin;
    }else{
      _title = title;
    }
    _query = '';
    _loadPopular = true;
    show();
  }

  void show() async {
    if(_loadPopular){
      _loadPopular = false;
      _isLoading = true;
      _items = await APIManager.discover(originTag, '');
      _isLoading = false;
      notifyListeners();
    } else {
      if(_isLoading) return;
      _isLoading = true;
      notifyListeners();
      _items = await APIManager.search(originTag, query);
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearQuery(){
    if(_query != ''){
      _query = '';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}