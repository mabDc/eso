import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/foundation.dart';

import 'audio_service.dart';

class FavoriteListProvider with ChangeNotifier {
  List<SearchItem> _searchList;
  int type;
  SortType _sortType = SortType.CREATE;
  get sortType => _sortType;
  get searchList => _searchList;

  FavoriteListProvider(int type) {
    this.type = type;
    getFavoriteList();
  }

  ///获取收藏列表
  void getFavoriteList({sortType: SortType.CREATE}) async {
    _searchList = SearchItemManager.getSearchItemByType(type, sortType: sortType);
    if (type == API.AUDIO && AudioService().searchItem != null &&
        !SearchItemManager.isFavorite(AudioService().searchItem.url)) {
      _searchList.add(AudioService().searchItem);
    }
    notifyListeners();
  }

  ///切换排序
  void sortList(SortType _sortType) {
    this._sortType = _sortType;
    getFavoriteList(sortType: _sortType);
    notifyListeners();
  }

  @override
  void dispose() {
    _searchList.clear();
    super.dispose();
  }
}
