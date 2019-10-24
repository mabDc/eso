import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../page/chapter_page.dart';
import '../ui/ui_shelf_item.dart';
import '../model/search_page_delegate.dart';
import '../model/history_manager.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = [];
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.appName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: SearchPageDelegate(
                historyManager: Provider.of<HistoryManager>(context),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          return;
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChapterPage(
                        searchItem: null,
                        chapters: null,
                      ))),
              child: UiShelfItem(),
            );
          },
        ),
      ),
    );
  }
}
