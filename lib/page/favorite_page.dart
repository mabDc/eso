import 'package:eso/database/search_item.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/ui/ui_discover_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/search_item_manager.dart';
import '../global.dart';
import '../model/history_manager.dart';
import '../model/search_page_delegate.dart';
import '../ui/ui_shelf_item.dart';
import 'chapter_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: Provider.of<Profile>(context).switchFavoriteStyle
                ? Icon(Icons.view_headline)
                : Icon(Icons.view_module),
            onPressed: () => Provider.of<Profile>(context).switchFavoriteStyle =
                !Provider.of<Profile>(context).switchFavoriteStyle,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          return;
        },
        child: Provider.of<Profile>(context).switchFavoriteStyle
            ? _buildFavoriteGrid(SearchItemManager.searchItem)
            : _buildFavoriteList(SearchItemManager.searchItem),
      ),
    );
  }

  Widget _buildFavoriteList(List<SearchItem> searchItems) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 8.0,
        );
      },
      itemCount: searchItems.length,
      padding: EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final searchItem = searchItems[index];
        final longPress = Provider.of<Profile>(context).switchLongPress;
        VoidCallback openChapter = () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChapterPage(searchItem: searchItem)));
        VoidCallback openContent = () =>
            Navigator.of(context).push(ContentPageRoute().route(searchItem));
        return InkWell(
          child: UiShelfItem(searchItem: searchItem),
          onTap: longPress ? openChapter : openContent,
          onLongPress: longPress ? openContent : openChapter,
        );
      },
    );
  }

  Widget _buildFavoriteGrid(List<SearchItem> searchItems) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: searchItems.length,
      itemBuilder: (context, index) {
        final searchItem = searchItems[index];
        final longPress = Provider.of<Profile>(context).switchLongPress;
        VoidCallback openChapter = () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChapterPage(searchItem: searchItem)));
        VoidCallback openContent = () =>
            Navigator.of(context).push(ContentPageRoute().route(searchItem));
        return InkWell(
          child: UIDiscoverItem(searchItem: searchItem),
          onTap: longPress ? openChapter : openContent,
          onLongPress: longPress ? openContent : openChapter,
        );
      },
    );
  }
}
