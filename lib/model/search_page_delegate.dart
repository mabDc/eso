import 'package:flutter/material.dart';

class SearchPageDelegate extends SearchDelegate<String>{
  String searchFieldLabel = "关键词";

  @override
  List<Widget> buildActions(BuildContext context) {
    //右侧显示内容 这里放清除按钮
    if(query.isEmpty){
      return <Widget>[];
    } else {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          },
        ),
      ];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    //左侧显示内容 这里放了返回按钮
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        if (query.isEmpty) {
          close(context, "from search");
        } else {
          query = "";
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //点击了搜索显示的页面
    return Center(
      child: Text('search $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //点击了搜索窗显示的页面
    return Center(
      child: Text('suggestions $query'),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black54),
      inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: Colors.black87)),
      textTheme: theme.textTheme.apply(bodyColor: Colors.black87),
    );
  }
}