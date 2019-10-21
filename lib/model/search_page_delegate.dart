import 'package:eso/page/chapter_page.dart';

import '../api/mankezhan.dart';
import '../model/search_history.dart';
import '../page/langding_page.dart';
import '../ui/ui_search_item.dart';
import 'package:flutter/material.dart';

class SearchPageDelegate extends SearchDelegate<String> {
  String searchFieldLabel = "关键词";

  final SearchHistory searchHistory;

  SearchPageDelegate({this.searchHistory});

  @override
  List<Widget> buildActions(BuildContext context) {
    //右侧显示内容 这里放清除按钮
    if (query.isEmpty) {
      return <Widget>[];
    } else {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
            showSuggestions(context);
          },
        ),
      ];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    //左侧显示内容 这里放了返回按钮
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, "from search");
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //点击了搜索显示的页面
    query = query.trim();
    if (!searchHistory.searchHistory.contains(query)) {
      searchHistory.newSearch(query);
    }
    return FutureBuilder<List>(
      future: Mankezhan.search(query),
      builder: (BuildContext context, AsyncSnapshot<List> data) {
        if (!data.hasData) {
          return LandingPage();
        }
        final list = data.data;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final item = list[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FutureBuilder<List>(
                  future: Mankezhan.chapter(item["comic_id"]),
                  builder: (BuildContext context, AsyncSnapshot<List> data) {
                    if (!data.hasData) {
                      return LandingPage();
                    }
                    return ChapterPage(
                      searchItem: item,
                      chapter: data.data,
                    );
                  },
                ),
              )),
              child: UiSearchItem(
                cover: '${item["cover"]}!cover-400',
                title: '${item["title"]}',
                origin: "漫客栈💰",
                author: '${item["author_title"]}',
                chapter: '${item["chapter_title"]}',
                description: '${item["feature"]}',
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //点击了搜索窗显示的页面
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(child: Text("搜索历史")),
                IconButton(
                  icon: Icon(Icons.delete_sweep),
                  onPressed: () {
                    searchHistory.clearHistory();
                    showSuggestions(context);
                  },
                )
              ],
            ),
          ),
          Wrap(
              spacing: 8,
              children: searchHistory.searchHistory
                  .map((keyword) => RaisedButton(
                        child: Text('$keyword'),
                        onPressed: () {
                          query = '$keyword';
                          showResults(context);
                        },
                      ))
                  .toList()),
        ],
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black54),
      inputDecorationTheme:
          InputDecorationTheme(hintStyle: TextStyle(color: Colors.black87)),
      textTheme: theme.textTheme.apply(bodyColor: Colors.black87),
    );
  }
}
