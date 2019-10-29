import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';

class DiscoverPageController with ChangeNotifier {
  /// const
  final String originTag;
  final List<DiscoverMap> discoverMap;
  /// private
  int _page;
  bool _showSearchResult;
  Map<String, DiscoverPair> _discoverParams;

  /// private set, public get
  String get title => _title;
  String _title;
  bool get isLoading => _isLoading;
  bool _isLoading;

  bool get showSearchField => _showSearchField;
  bool _showSearchField;

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
    @required this.discoverMap,
    @required String origin,
  }) {
    _discoverParams = Map<String, DiscoverPair>();
    discoverMap.forEach((map) => _discoverParams[map.name] = map.pairs.first);
    _title = origin;
    _page = 1;
    _showSearchResult = false;
    _isLoading = false;
    _showSearchField = false;
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

  void selectDiscoverPair(String name,DiscoverPair pair){
    if(_discoverParams[name] != pair){
      _discoverParams[name]= pair;
      _discover();
    }
  }

  DiscoverPair getDiscoverPair(String name){
    return _discoverParams[name];
  }

  void resetDiscoverParams(){
    _discoverParams = Map<String, DiscoverPair>();
    discoverMap.forEach((map) => _discoverParams[map.name] = map.pairs.first);
    notifyListeners();
  }

  Future<void> fetchData({needShowLoading = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if(needShowLoading){
      notifyListeners();
    }
    List<SearchItem> newItems;
    if (_showSearchResult) {
      newItems =
          await APIManager.search(originTag, _queryController.text, _page);
    } else {
      newItems =
          await APIManager.discover(originTag, _discoverParams, _page);
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
    _showSearchResult = true;
    _page = 1;
    return fetchData();
  }

  void _discover() {
    //_showFilter = false;
    _showSearchResult = false;
    _page = 1;
    fetchData(needShowLoading: true);
  }

  void loadMore() {
    _page++;
    fetchData();
  }

  void toggleSearching() {
    queryController.text = '';
    _showSearchField = !_showSearchField;
    _showFilter = false;
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
