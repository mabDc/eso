import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../api/api_manager.dart';
import '../ui/ui_discover_item.dart';
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
            height: 4,
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
                onChanged: (enable) {},
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DiscoverItemPage(
                      originTag: allAPI[index].originTag,
                      origin: allAPI[index].origin))),
            ),
          );
        },
      ),
    );
  }
}

class DiscoverItemPage extends StatelessWidget {
  final String originTag;
  final String origin;

  const DiscoverItemPage({this.originTag, this.origin, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DiscoverPageController>.value(
      value: DiscoverPageController(originTag: originTag, origin: origin),
      child: Consumer<DiscoverPageController>(
        builder:
            (BuildContext context, DiscoverPageController pageController, _) {
          return Builder(
            builder: (context) {
              return Scaffold(
                appBar: true
                    ? AppBar(
                        backgroundColor: Colors.white,
                        iconTheme: IconThemeData(color: Colors.grey),
                        actionsIconTheme: IconThemeData(color: Colors.grey),
                        textTheme: Theme.of(context)
                            .textTheme
                            .apply(bodyColor: Colors.black87),
                        actions: pageController.query == ''
                            ? <Widget>[]
                            : <Widget>[
                                IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: pageController.clearQuery,
                                ),
                              ],
                        title: TextField(
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black87),
                            hintText: '搜索 $origin',
                            border: InputBorder.none,
                          ),
                          onChanged: (query) => pageController.query = query,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {},
                        ),
                      )
                    : AppBar(
                        title: Text(pageController.title),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () {},
                          ),
                        ],
                      ),
                body: pageController.isLoading
                    ? LandingPage()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(Duration(seconds: 1));
                          return;
                        },
                        child: buildDiscoverResult(pageController.items),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildDiscoverResult(List<SearchItem> items) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        SearchItem searchItem = items[index];
        if (SearchItemManager.isFavorite(searchItem.url)) {
          searchItem = SearchItemManager.searchItem
              .firstWhere((item) => item.url == searchItem.url);
        }
        return InkWell(
          child: UIDiscoverItem(item: searchItem),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChapterPage(searchItem: searchItem)),
          ),
        );
      },
    );
  }
}
