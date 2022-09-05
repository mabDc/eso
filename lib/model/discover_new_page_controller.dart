import 'dart:convert';
import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/model/history_manager.dart';
import 'package:eso/model/moreKeys.dart';
import 'package:eso/page/source/login_rule_page.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

class DiscoverPageController with ChangeNotifier {
  /// const
  final String originTag;
  final List<DiscoverMap> discoverMap;
  final String discoverUrl;
  final Rule rule;

  /// private
  bool _showSearchResult;
  bool _isWrap = true;
  bool get isWrap => _isWrap;

  /// private set, public get
  Map<String, List<RequestFilters>> _discoverParams;
  Map<String, List<RequestFilters>> get discoverParams => _discoverParams;

  bool get showSearchResult => _showSearchResult;
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

  HistoryManager _historyManager;

  List<String> _history;
  List<String> get history => _history;

  DiscoverPageController({
    @required this.originTag,
    @required this.discoverMap,
    @required this.rule,
    @required this.discoverUrl,
    @required String origin,
  }) {
    _discoverParams = Map<String, List<RequestFilters>>();
    ItemMoreKeys moreKeys =
        ItemMoreKeys.fromJson(jsonDecode(rule.discoverMoreKeys));
    _isWrap = moreKeys.isWrap;

    discoverMap.forEach((map) {
      _discoverParams[map.name] = map.pairs;
    });

    _title = origin;
    _showSearchResult = false;
    _showSearchField = false;
    _showFilter = false;
    _historyManager = HistoryManager();
    _queryController = TextEditingController();
    _queryController.addListener(() => notifyListeners());
    _history = List.from(_historyManager.searchHistory);
    APIFromRUle.clearNextUrl();
    initItems();
    fetchData(_items.first);
  }

  void initItems() {
    if (_items != null) return;
    _items = <ListDataItem>[];
    final _addItem = (List<RequestFilters> element, int i) {
      var item = ListDataItem();
      item.index = i;
      print(item.index);
      item.pair = element;
      item.controller = ScrollController();
      item.controller.addListener(() {
        if (item.more &&
            item.controller.position.pixels ==
                item.controller.position.maxScrollExtent) {
          loadMore(
            item,
          );
        }
      });
      item.page = 1;
      item.isLoading = false;
      item.items = [];
      _items.add(item);
    };

    for (var i = 0; i < discoverMap.length; i++) {
      _addItem(discoverMap[i].pairs, i);
    }

    _addItem(null, discoverMap.length); // 加一个空的用于搜索
  }

  void selectDiscoverPair(String name, [List<RequestFilters> pair]) {
    print("name:${name},pair:${pair}");
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

  // RequestFilters getDiscoverPair(String name) {
  //   return _discoverParams[name];
  // }

  void resetDiscoverParams() {
    _discoverParams = Map<String, List<RequestFilters>>();
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
        newItems = await APIManager.search(
            originTag, _queryController.text, item.page);
      } else {
        Map<String, String> filters = {};
        item.pair.forEach((element) {
          filters[element.key] = element.value == null ? '' : element.value;
        });
        await JSEngine.evaluate(
            """
          page = ${item.page};
          params.tabIndex = ${item.index};
          params.pageIndex = page;
          params.filters = ${jsonEncode(filters)};
          1+1;
          """);
        String url =
            jsonEncode(await JSEngine.evaluate(discoverUrl.substring(4)));

        newItems = await APIManager.discover(originTag,
            {discoverMap[item.index].name: DiscoverPair("", url)}, item.page);
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
    _historyManager.newSearch(_queryController.text);
    _history = List.from(_historyManager.searchHistory);
    var item = searchItem;
    item.page = page;
    return await fetchData(
      item,
      goto: goto,
      needShowLoading: true,
    );
  }

  void clearHistory() {
    _historyManager.clearHistory();
    _history = List.from(_historyManager.searchHistory);
    notifyListeners();
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

  void login(BuildContext context) async {
    if (rule.loginUrl.isEmpty && !rule.loginUrl.startsWith("http")) {
      Utils.toast("未配置登陆url");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Platform.isWindows
            ? LoginRulePageWithWindows(rule: rule)
            : LoginRulePage(rule: rule),
      ),
    ).whenComplete(() async {
      print("rule");
      await Global.ruleDao.insertOrUpdateRule(rule);
    });
  }

  void toggleSearching() {
    queryController.text = '';
    _showSearchField = !_showSearchField;

    if (!_showSearchField) {
      searchItem.more = false;
      searchItem.page = 1;
      searchItem.isLoading = false;
      searchItem.items.clear();
      _showSearchResult = false;
    }
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
      {this.index,
      this.items,
      this.pair,
      this.more = true,
      this.controller,
      this.page = 1,
      this.isLoading = false});
  int index;
  List<RequestFilters> pair;
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
