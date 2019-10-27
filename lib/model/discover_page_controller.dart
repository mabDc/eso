import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';

class DiscoverPageController with ChangeNotifier {
  /// const
  final String originTag;

  /// private
  int _page;
  bool _showSearch;

  /// private set, public get
  String get title => _title;
  String _title;
  bool get isLoading => _isLoading;
  bool _isLoading;

  bool get isSearching => _isSearching;
  bool _isSearching;

  bool get showFilter => _showFilter;
  bool _showFilter;

  TextEditingController get queryController => _queryController;
  TextEditingController _queryController;

  ScrollController get controller => _controller;
  ScrollController _controller;

  List<SearchItem> get items => _items;
  List<SearchItem> _items;

  DiscoverPageController({
    @required this.originTag,
    @required String origin,
  }) {
    _title = origin;
    _page = 1;
    _showSearch = false;
    _isLoading = false;
    _isSearching = false;
    _showFilter = false;
    _queryController = TextEditingController();
    _queryController.addListener(() => notifyListeners());
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        loadMore();
      }
    });
    fetchData();
  }

  Future<void> fetchData() async {
    if (_isLoading) return;
    _isLoading = true;
    List<SearchItem> newItems;
    if (_showSearch) {
      newItems =
          await APIManager.search(originTag, _queryController.text, _page);
    } else {
      newItems =
          await APIManager.discover(originTag, _queryController.text, _page);
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

  Future<void> refresh() async {
    _page = 1;
    return fetchData();
  }

  void search() async {
    _showSearch = true;
    _page = 1;
    return fetchData();
  }

  void discover(String title, String query) {
    //_showFilter = false;
    _title = title;
    queryController.text = query;
    _showSearch = false;
    _page = 1;
    fetchData();
  }

  void loadMore() {
    _page++;
    fetchData();
  }

  void toggleSearching() {
    queryController.text = '';
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void toggleDiscoverFilter() {
    _showFilter = !_showFilter;
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
