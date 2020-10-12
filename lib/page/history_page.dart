import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryPageProvider(),
      builder: (context, child) {
        final historyItem =
            context.select((HistoryPageProvider provider) => provider.historyItem);
        return Scaffold();
      },
    );
  }
}

class HistoryPageProvider with ChangeNotifier {
  HistoryPageProvider() {
    _historyItem = HistoryItemManager.getHistoryItemByType(_contentType);
  }

  void updateHistory([int contentType]) {
    _contentType = contentType;
    _historyItem = HistoryItemManager.getHistoryItemByType(_contentType);
    notifyListeners();
  }

  int _contentType;

  List<SearchItem> _historyItem;
  List<SearchItem> get historyItem => _historyItem;
  DateTime _loadTime;
  void getRuleListByNameDebounce(String name) {
    _loadTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 301), () {
      if (DateTime.now().difference(_loadTime).inMilliseconds > 300) {
        // getRuleListByName(name);
      }
    });
  }
}
