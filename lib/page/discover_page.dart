import 'package:flutter/material.dart';
import '../ui/ui_search_item.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [];
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return UiSearchItem(item: items[index]);
        },
      ),
    );
  }
}
