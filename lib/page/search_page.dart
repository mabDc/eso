import 'dart:ui';

import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchProvider(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: TextField(
            cursorColor: Theme.of(context).primaryColor,
            cursorRadius: Radius.circular(2),
            selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: "search keyword",
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                fontSize: 12,
              ),
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                ),
              ),
              prefixIconConstraints: BoxConstraints(),
            ),
            maxLines: 1,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              height: 1.25,
            ),
            onSubmitted: Provider.of<SearchProvider>(context, listen: false).search,
          ),
        ),
        body: Consumer<SearchProvider>(
          builder: (context, provider, child) {
            if (provider.searchList.length == 0) {
              return Container();
            }
            return ListView.builder(
              itemCount: provider.searchList.length,
              itemBuilder: (BuildContext context, int index) {
                return UiSearchItem(item: provider.searchList[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class SearchProvider with ChangeNotifier {
  final int threadCount;
  final List<SearchItem> searchList = <SearchItem>[];
  SearchProvider({this.threadCount = 5});

  void search(String value) async {
    searchList.clear();
    notifyListeners();
    final rules = await Global.ruleDao.findAllRules();
    final times = rules.length ~/ threadCount;

    // 0 3 6
    // 1 4 7
    // 2 5 8
  }

  @override
  void dispose() {
    searchList.clear();
    super.dispose();
  }
}
