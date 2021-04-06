import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';

class DiscoverPageController with ChangeNotifier {
  /// const
  final String originTag;
  final List<DiscoverMap> discoverMap;

  /// private
  bool _showSearchResult;

  /// private set, public get
  Map<String, DiscoverPair> _discoverParams;
  Map<String, DiscoverPair> get discoverParams => _discoverParams;

  String get title => _title;
  String _title;

  bool get showSearchField => _showSearchField;
  bool _showSearchField;

  bool get showFilter => _showFilter;
  bool _showFilter;

  TextEditingController get queryController => _queryController;
  TextEditingController _queryController;

  List<ListDataItem> get items => _items;
  List<ListDataItem> _items;

  ListDataItem get searchItem => _items.last;

  DiscoverPageController({
    @required this.originTag,
    @required this.discoverMap,
    @required String origin,
  }) {
    _discoverParams = Map<String, DiscoverPair>();
    discoverMap.forEach((map) {
      _discoverParams[map.name] = map.pairs.first;
    });
    _title = origin;
    _showSearchResult = false;
    _showSearchField = false;
    _showFilter = false;
    _queryController = TextEditingController();
    _queryController.addListener(() => notifyListeners());
    APIFromRUle.clearNextUrl();
    initItems();
    fetchData(_items.first);
  }

  void initItems() {
    if (_items != null) return;
    _items = <ListDataItem>[];
    final _addItem = (DiscoverPair element) {
      var item = ListDataItem();
      item.pair = element;
      item.controller = ScrollController();
      item.controller.addListener(() {
        if (item.more &&
            item.controller.position.pixels == item.controller.position.maxScrollExtent) {
          loadMore(item);
        }
      });
      item.page = 1;
      item.isLoading = false;
      item.items = [];
      _items.add(item);
    };

    discoverMap.forEach((element) {
      _addItem(element.pairs.first);
    });

    _addItem(null); // 加一个空的用于搜索
  }

  void selectDiscoverPair(String name, DiscoverPair pair) {
    if (_discoverParams[name] != pair) {
      if (pair == null) {
        pair = _discoverParams[name];
        var index = _items.indexWhere((element) => element.pair == pair);
        var item = _items[index];
        if (item.length == 0) _discover(item);
      } else {
        _discoverParams[name] = pair;
        var index = discoverMap.indexWhere((element) => element.name == name);
        var item = _items[index];
        item.pair = pair;
        _discover(item);
      }
    }
  }

  DiscoverPair getDiscoverPair(String name) {
    return _discoverParams[name];
  }

  void resetDiscoverParams() {
    _discoverParams = Map<String, DiscoverPair>();
    discoverMap.forEach((map) => _discoverParams[map.name] = map.pairs.first);
    notifyListeners();
  }

  Future<void> fetchData(ListDataItem item,
      {bool goto = false, bool needShowLoading = false}) async {
    if (item == null || item.isLoading || discoverMap.isEmpty) return;
    item.isLoading = true;
    if (needShowLoading || goto) {
      notifyListeners();
    }
    List<SearchItem> newItems;
    try {
      if (_showSearchResult) {
        newItems = await APIManager.search(originTag, _queryController.text, item.page);
      } else {
        newItems = await APIManager.discover(
            originTag, {discoverMap.first.name: item.pair}, item.page);
      }
    } catch (e) {
      print(e);
      item.isLoading = false;
      notifyListeners();
      return;
    }
    if (goto || item.page == 1) {
      item.items?.clear();
      item.items = newItems;
    } else {
      item.items.addAll(newItems);
    }
    item.isLoading = false;
    item.more = newItems.length > 0;
    notifyListeners();
  }

  // Future<void> refresh() async {
  //   _page = 1;
  //   return fetchData();
  // }

  search([int page = 1, bool goto = false]) async {
    _showSearchResult = true;
    var item = searchItem;
    item.page = page;
    return await fetchData(item, goto: goto);
  }

  void _discover(ListDataItem item) {
    //_showFilter = false;
    _showSearchResult = false;
    item.page = 1;
    fetchData(item, needShowLoading: true);
  }

  void loadMore(ListDataItem item) {
    item.page++;
    fetchData(item);
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
    APIFromRUle.clearNextUrl();
    _items?.forEach((element) {
      element.dispose();
    });
    _queryController.dispose();
    super.dispose();
  }
}

class ListDataItem {
  ListDataItem(
      {this.items,
      this.pair,
      this.more = true,
      this.controller,
      this.page = 1,
      this.isLoading = false});

  DiscoverPair pair;
  ScrollController controller;
  List<SearchItem> items;
  int page;
  bool isLoading;
  bool more;

  void dispose() {
    if (controller != null) controller.dispose();
    controller = null;
    items?.clear();
  }

  int get length => items?.length ?? 0;
}
