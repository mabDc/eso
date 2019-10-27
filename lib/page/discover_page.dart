import 'dart:math';

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
        padding: EdgeInsets.all(6),
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
                        origin: allAPI[index].origin,
                        discoverMap: allAPI[index].discoverMap(),
                      ))),
            ),
          );
        },
      ),
    );
  }
}

class DiscoverItemPage extends StatefulWidget {
  final String originTag;
  final String origin;
  final Map<String, String> discoverMap;

  const DiscoverItemPage({
    this.originTag,
    this.origin,
    this.discoverMap,
    Key key,
  }) : super(key: key);

  @override
  _DiscoverItemPageState createState() => _DiscoverItemPageState();
}

class _DiscoverItemPageState extends State<DiscoverItemPage> {
  Widget _discover;

  @override
  Widget build(BuildContext context) {
    if (_discover == null) {
      _discover = _buildDiscover();
    }
    return _discover;
  }

  Widget _buildDiscover() {
    return ChangeNotifierProvider<DiscoverPageController>.value(
      value: DiscoverPageController(
          originTag: widget.originTag, origin: widget.origin),
      child: Consumer<DiscoverPageController>(
        builder:
            (BuildContext context, DiscoverPageController pageController, _) {
          return Scaffold(
            appBar: pageController.isSearching
                ? AppBar(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.grey),
                    actionsIconTheme: IconThemeData(color: Colors.grey),
                    textTheme: Theme.of(context)
                        .textTheme
                        .apply(bodyColor: Colors.black87),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: pageController.toggleSearching,
                    ),
                    actions: pageController.queryController.text == ''
                        ? <Widget>[]
                        : <Widget>[
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: pageController.clearInputText,
                            ),
                          ],
                    title: TextField(
                      controller: pageController.queryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: '搜索 ${widget.origin}',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black87),
                      cursorColor: Theme.of(context).primaryColor,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) => pageController.search(),
                    ),
                  )
                : AppBar(
                    title: Text(pageController.title),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: pageController.toggleSearching,
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list),
                        onPressed: pageController.toggleDiscoverFilter,
                      ),
                    ],
                  ),
            body: RefreshIndicator(
              onRefresh: pageController.refresh,
              child: Column(
                children: <Widget>[
                  pageController.showFilter
                      ? Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              children: _buildFilter(pageController.discover),
                            ),
                          ),
                        )
                      : Container(),
                  Expanded(
                    flex: 2,
                    child: pageController.isLoading
                        ? LandingPage()
                        : buildDiscoverResult(
                            pageController.items, pageController.controller),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFilter(Function(String title, String query) discover) {
    final keys = widget.discoverMap.keys.toList();
    final values = widget.discoverMap.values.toList();
    if (keys.length == 0) {
      return <Widget>[
        Text(
          '暂无更多发现',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        )
      ];
    }
    final bottons = List<RaisedButton>(keys.length);
    final random = Random();
    for (var i = 0; i < keys.length; i++) {
      bottons[i] = RaisedButton(
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: Colors.primaries[random.nextInt(Colors.primaries.length)]
            .withAlpha(100),
        child: Text(keys[i]),
        onPressed: () => discover(keys[i], values[i]),
      );
    }
    return bottons;
  }

  Widget buildDiscoverResult(
      List<SearchItem> items, ScrollController controller) {
    return GridView.builder(
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: items.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == items.length) {
          return Align(
            alignment: Alignment(0, -0.5),
            child: Text(
              '加载下一页...',
              style: TextStyle(fontSize: 20),
            ),
          );
        }
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
