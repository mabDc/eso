import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_discover_item.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chapter_page.dart';
import 'langding_page.dart';

class DiscoverSearchPage extends StatefulWidget {
  final String originTag;
  final String origin;
  final List<DiscoverMap> discoverMap;

  const DiscoverSearchPage({
    this.originTag,
    this.origin,
    this.discoverMap,
    Key key,
  }) : super(key: key);

  @override
  _DiscoverSearchPageState createState() => _DiscoverSearchPageState();
}

class _DiscoverSearchPageState extends State<DiscoverSearchPage> {
  Widget _discover;
  DiscoverPageController __pageController;
  @override
  void dispose() {
    __pageController?.dispose();
    super.dispose();
  }

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
          originTag: widget.originTag,
          origin: widget.origin,
          discoverMap: widget.discoverMap),
      child: Consumer<DiscoverPageController>(
        builder:
            (BuildContext context, DiscoverPageController pageController, _) {
          return Scaffold(
            appBar: pageController.showSearchField
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
                      IconButton(
                        icon: Provider.of<Profile>(context).switchDiscoverStyle
                            ? Icon(Icons.view_module)
                            : Icon(Icons.view_headline),
                        onPressed: () => Provider.of<Profile>(context)
                                .switchDiscoverStyle =
                            !Provider.of<Profile>(context).switchDiscoverStyle,
                      ),
                    ],
                  ),
            body: Column(
              children: <Widget>[
                pageController.showFilter
                    ? (widget.discoverMap == null ||
                            widget.discoverMap.length == 0)
                        ? SizedBox(
                            height: 32,
                            child: Text(
                              '暂无更多发现',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: widget.discoverMap
                                  .map((map) => _buildDropdown(
                                      map,
                                      Theme.of(context).primaryColor,
                                      pageController.getDiscoverPair(map.name),
                                      pageController.selectDiscoverPair))
                                  .toList(),
                            ),
                          )
                    : Container(),
                Expanded(
                  flex: 2,
                  child: pageController.isLoading
                      ? LandingPage()
                      : Provider.of<Profile>(context).switchDiscoverStyle
                          ? buildDiscoverResultList(
                              pageController.items, pageController.controller)
                          : buildDiscoverResultGrid(
                              pageController.items, pageController.controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(DiscoverMap map, Color color, DiscoverPair value,
      Function(String, DiscoverPair) select) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 34,
          alignment: Alignment.centerLeft,
          child: Text(
            '${map.name} ',
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<DiscoverPair>(
              isExpanded: true,
              isDense: true,
              underline: Container(),
              value: value,
              items: map.pairs
                  .map((pair) => DropdownMenuItem<DiscoverPair>(
                        child: Text(pair.name),
                        value: pair,
                      ))
                  .toList(),
              onChanged: (value) => select(map.name, value),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDiscoverResultList(
      List<SearchItem> items, ScrollController controller) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 8.0,
        );
      },
      controller: controller,
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
          child: UiSearchItem(item: searchItem),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChapterPage(searchItem: searchItem)),
          ),
        );
      },
    );
  }

  Widget buildDiscoverResultGrid(
      List<SearchItem> items, ScrollController controller) {
    return GridView.builder(
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
          child: UIDiscoverItem(searchItem: searchItem),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChapterPage(searchItem: searchItem)),
          ),
        );
      },
    );
  }
}
