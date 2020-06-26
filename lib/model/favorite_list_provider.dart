import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/foundation.dart';

import 'audio_service.dart';

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

  FavoriteListProvider(this.type, this._sortType) {
    updateList();
  }

  void updateList() {
    _searchList = SearchItemManager.getSearchItemByType(type, _sortType);
    if (type == API.AUDIO &&
        AudioService().searchItem != null &&
        !SearchItemManager.isFavorite(AudioService().searchItem.originTag,AudioService().searchItem.url)) {
      _searchList.add(AudioService().searchItem);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _searchList.clear();
    super.dispose();
  }
}
