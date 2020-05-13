import 'package:eso/database/search_item.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/ui/ui_discover_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eso/ui/round_indicator.dart';
import '../database/search_item_manager.dart';
import '../model/history_manager.dart';
import '../model/search_page_delegate.dart';
import 'chapter_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          title: TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).textTheme.bodyText1.color,
            unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color,
            indicator: RoundTabIndicator(
                insets: EdgeInsets.only(left: 2, right: 2),
                borderSide: BorderSide(
                    width: 5.0, color: Theme.of(context).primaryColor)),
            tabs: <Widget>[
              Container(
                height: 40,
                alignment: Alignment.center,
                child:Text("漫画",style: TextStyle(fontWeight:FontWeight.bold),)
              ),
              Container(
                height: 40,
                alignment: Alignment.center,
                child:Text("动漫",style: TextStyle(fontWeight:FontWeight.bold),)
              ),
              Container(
                height: 40,
                alignment: Alignment.center,
                child:Text("音乐",style: TextStyle(fontWeight:FontWeight.bold),)
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              onPressed: () => showSearch(
                context: context,
                delegate: SearchPageDelegate(
                  historyManager:
                      Provider.of<HistoryManager>(context, listen: false),
                ),
              ),
            ),
            // IconButton(
            //   icon: Provider.of<Profile>(context, listen: false)
            //           .switchFavoriteStyle
            //       ? Icon(Icons.view_headline,
            //           color: Theme.of(context).textTheme.bodyText1.color)
            //       : Icon(Icons.view_module,
            //           color: Theme.of(context).textTheme.bodyText1.color),
            //   onPressed: () => Provider.of<Profile>(context, listen: false)
            //           .switchFavoriteStyle =
            //       !Provider.of<Profile>(context, listen: false)
            //           .switchFavoriteStyle,
            // ),
          ],
        ),
        body: TabBarView(
          children: _buildTabPage(context),
        ),
      ),
    );
  }

  List<Widget> _buildTabPage(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < 5; i++) {
      if (i == 1 || i == 4) continue;//跳过小说和RSS

      List<SearchItem> searchItems = SearchItemManager.getSearchItemByType(i);
      if (i == 3) {
        if (AudioService().searchItem != null &&
            !SearchItemManager.isFavorite(AudioService().searchItem.url)) {
          searchItems.add(AudioService().searchItem);
        }
      }

      list.add(
        RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1));
            return;
          },
          child:_buildFavoriteGrid(searchItems),
        ),
      );
    }
    return list;
  }

  // Widget _buildFavoriteList(List<SearchItem> searchItems) {
  //   return Padding(
  //       padding: EdgeInsets.all(8),
  //       child: ListView.separated(
  //         separatorBuilder: (context, index) {
  //           return SizedBox(
  //             height: 8.0,
  //           );
  //         },
  //         itemCount: searchItems.length,
  //         itemBuilder: (context, index) {
  //           final searchItem = searchItems[index];
  //           final longPress =
  //               Provider.of<Profile>(context, listen: false).switchLongPress;
  //           VoidCallback openChapter = () => Navigator.of(context).push(
  //               MaterialPageRoute(
  //                   builder: (context) => ChapterPage(searchItem: searchItem)));
  //           VoidCallback openContent = () => Navigator.of(context)
  //               .push(ContentPageRoute().route(searchItem));
  //           return InkWell(
  //             child: UiShelfItem(searchItem: searchItem),
  //             onTap: longPress ? openChapter : openContent,
  //             onLongPress: longPress ? openContent : openChapter,
  //           );
  //         },
  //       ));
  // }

  Widget _buildFavoriteGrid(List<SearchItem> searchItems) {
    return Padding(
        padding: EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: searchItems.length,
          itemBuilder: (context, index) {
            final searchItem = searchItems[index];
            final longPress =
                Provider.of<Profile>(context, listen: false).switchLongPress;
            VoidCallback openChapter = () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ChapterPage(searchItem: searchItem)));
            VoidCallback openContent = () => Navigator.of(context)
                .push(ContentPageRoute().route(searchItem));
            return InkWell(
              child: UIDiscoverItem(searchItem: searchItem),
              onTap: longPress ? openChapter : openContent,
              onLongPress: longPress ? openContent : openChapter,
            );
          },
        ));
  }
}
