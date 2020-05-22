import 'package:eso/api/api.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/material.dart';

import '../api/api_manager.dart';
import '../database/search_item.dart';
import '../ui/ui_search_item.dart';
import 'chapter_page.dart';
import 'langding_page.dart';

class SearchResultPage extends StatelessWidget {
  final String query;

  const SearchResultPage({
    this.query,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allAPI = <API>[];
    return DefaultTabController(
      length: allAPI.length,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 40,
            width: double.infinity,
            child: TabBar(
              isScrollable: true,
              tabs: allAPI.map((api) => Text(api.origin)).toList(),
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black87,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: allAPI
                  .map((api) =>
                      buildResult(APIManager.search(api.originTag, query)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResult(Future<List<SearchItem>> future) {
    return FutureBuilder<List<SearchItem>>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<List<SearchItem>> data) {
        if (!data.hasData) {
          return LandingPage();
        }
        List<SearchItem> items = data.data;
        return ListView.separated(
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 8.0,
            );
          },
          itemCount: items.length,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (BuildContext context, int index) {
            SearchItem searchItem = items[index];
            if (SearchItemManager.isFavorite(searchItem.url)) {
              searchItem = SearchItemManager.searchItem
                  .firstWhere((item) => item.url == searchItem.url);
            }
            return InkWell(
              child: UiSearchItem(item: searchItem),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ChapterPage(searchItem: searchItem)),
              ),
            );
          },
        );
      },
    );
  }
}
