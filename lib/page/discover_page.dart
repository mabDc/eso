import 'package:flutter/material.dart';
import '../database/fake_data.dart';
import '../ui/ui_search_item.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = FakeData.searchList;
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return UiSearchItem(
            cover: '${item["cover"]}!cover-400',
            title: '${item["title"]}',
            origin: "漫客栈💰",
            author: '${item["author_title"]}',
            chapter: '${item["chapter_title"]}',
            description: '${item["feature"]}',
          );
        },
      ),
    );
  }
}
