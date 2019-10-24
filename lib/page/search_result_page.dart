import 'package:eso/api/api.dart';
import 'package:flutter/material.dart';
import '../global.dart';
import '../database/search_item.dart';
import '../api/api_manager.dart';
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
    return DefaultTabController(
      length: APIManager.allAPI.length,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 40,
            width: double.infinity,
            child: TabBar(
              isScrollable: true,
              tabs: APIManager.allAPI.map((api) => Text(api.origin)).toList(),
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black87,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: APIManager.allAPI
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
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = items[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                maintainState: true,
                builder: (context) => FutureBuilder<List>(
                  future: APIManager.getChapter(item.originTag, item.url),
                  builder: (BuildContext context, AsyncSnapshot<List> data) {
                    if (!data.hasData) {
                      return LandingPage();
                    }
                    return ChapterPage(
                      searchItem: item,
                      chapters: data.data,
                    );
                  },
                ),
              )),
              child: UiSearchItem(item: item),
            );
          },
        );
      },
    );
  }
}
