import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/material.dart';
import '../ui/ui_discover_item.dart';
import '../api/api_manager.dart';
import 'chapter_page.dart';
import 'langding_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allAPI = APIManager.allAPI;
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 6,
          );
        },
        itemCount: allAPI.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(allAPI[index].origin),
              trailing: Switch(
                activeColor: Theme.of(context).primaryColor,
                value: true,
                onChanged: (enable) {

                },
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DiscoverItemPage(
                      allAPI[index].originTag, allAPI[index].origin))),
            ),
          );
        },
      ),
    );
  }
}

class DiscoverItemPage extends StatelessWidget {
  final String originTag;
  final String name;

  const DiscoverItemPage(this.originTag, this.name, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<SearchItem>>(
        future: APIManager.discover(originTag, ''),
        builder: (BuildContext context, AsyncSnapshot<List<SearchItem>> data) {
          if (!data.hasData) {
            return LandingPage();
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            padding: EdgeInsets.all(8.0),
            itemCount: data.data.length,
            itemBuilder: (BuildContext context, int index) {
              SearchItem searchItem = data.data[index];
              if (SearchItemManager.isFavorite(searchItem.url)) {
                searchItem = SearchItemManager.searchItem
                    .firstWhere((item) => item.url == searchItem.url);
              }
              return InkWell(
                child: UIDiscoverItem(item: searchItem),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          ChapterPage(searchItem: searchItem)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
