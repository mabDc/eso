import 'dart:async';

import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/evnts/restore_event.dart';
import 'package:eso/utils.dart';
import 'package:flutter/foundation.dart';

class FavoriteListProvider with ChangeNotifier {
  List<SearchItem> _searchList;
  List<SearchItem> get searchList => _searchList;

  SortType _sortType;
  SortType get sortType => _sortType;
  set sortType(SortType value) {
    if (value != sortType) {
      _sortType = value;
      updateList();
    }
  }

  final int type;

  StreamSubscription _eventStream;

  FavoriteListProvider(this.type, this._sortType) {
    updateList();
    _eventStream = eventBus.on<RestoreEvent>().listen((event) {
      updateList();
    });
  }

  void updateList() {
    _searchList = SearchItemManager.getSearchItemByType(type, _sortType);
    notifyListeners();
  }

  @override
  void dispose() {
    _searchList.clear();
    _eventStream.cancel();
    super.dispose();
  }
}
