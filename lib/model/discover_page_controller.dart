import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';

class DiscoverPageController with ChangeNotifier {
  final String originTag;
  final String origin;
  int _page;
  bool _hasSearch;

  bool get isLoading => _isLoading;
  bool _isLoading;

  bool get isSearching => _isSearching;
  bool _isSearching;

  TextEditingController get queryController => _queryController;
  TextEditingController _queryController;

  ScrollController get controller => _controller;
  ScrollController _controller;

  List<SearchItem> get items => _items;
  List<SearchItem> _items;

  DiscoverPageController({@required this.originTag, this.origin}) {
    _page = 1;
    _hasSearch = false;
    _isLoading = false;
    _isSearching = false;
    _queryController = TextEditingController();
    _queryController.addListener(() => notifyListeners());
    _controller = ScrollController();
    _controller.addListener((){
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        loadMore();
      }
    });
    fetchData();
  }

  Future<void> fetchData() async {
    if (_isLoading) return;
    _isLoading = true;
    if(!_hasSearch && _isSearching){
      _hasSearch = true;
    }
    List<SearchItem> newItems;
    if (_hasSearch) {
      newItems = await APIManager.search(originTag, _queryController.text, _page);
    } else {
      newItems = await APIManager.discover(originTag, '', _page);
    }
    if (_page == 1) {
      _items?.clear();
      _items = newItems;
    } else {
      _items.addAll(newItems);
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  void loadMore(){
    _page++;
    fetchData();
  }

  Future<void> search() async{
    _page = 1;
    return fetchData();
  }

  void toggleSearching() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void clearInputText() {
    queryController.text = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _queryController.dispose();
    super.dispose();
  }
}
