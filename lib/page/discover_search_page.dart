import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_discover_item.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/widgets/load_more_view.dart';
import 'package:eso/ui/widgets/search_edit.dart';
import 'package:eso/ui/widgets/size_bar.dart';
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

class _DiscoverSearchPageState extends State<DiscoverSearchPage>
    with SingleTickerProviderStateMixin {
  Widget _discover;
  DiscoverPageController __pageController;
  TabController _tabController;

  @override
  void dispose() {
    __pageController?.dispose();
    _tabController?.dispose();
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
        builder: (BuildContext context, DiscoverPageController pageController, _) {
          final _iconTheme = Theme.of(context).primaryIconTheme;
          final _textTheme = Theme.of(context).textTheme;
          final _color = _textTheme.bodyText1.color.withOpacity(0.4);
          return Scaffold(
            appBar: pageController.showSearchField
                ? AppBar(
                    titleSpacing: 0.0,
                    backgroundColor: Theme.of(context).appBarTheme.color,
                    iconTheme: _iconTheme.copyWith(color: _color),
                    actionsIconTheme: _iconTheme.copyWith(color: _color),
                    leading: BackButton(
                      onPressed: pageController.toggleSearching,
                    ),
                    actions: pageController.queryController.text == ''
                        ? <Widget>[
                            _buildSwitchStyle(context),
                          ]
                        : <Widget>[
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: pageController.clearInputText,
                            ),
                            _buildSwitchStyle(context),
                          ],
                    title: SearchEdit(
                      controller: pageController.queryController,
                      autofocus: true,
                      hintText: '搜索 ${widget.origin}',
                      onSubmitted: (query) => pageController.search(),
                    ),
                    bottom: _buildAppBarBottom(context, pageController),
                  )
                : AppBar(
                    titleSpacing: 0.0,
                    title: Text(pageController.title),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: pageController.toggleSearching,
                      ),
                    //  IconButton(
                    //    icon: Icon(Icons.filter_list),
                    //    onPressed: pageController.toggleDiscoverFilter,
                    //  ),
                      _buildSwitchStyle(context),
                    ],
                    bottom: _buildAppBarBottom(context, pageController),
                  ),
            body: pageController.isLoading
                ? LandingPage()
                : Provider.of<Profile>(context, listen: false).switchDiscoverStyle
                    ? buildDiscoverResultList(
                        pageController.items, pageController.controller)
                    : buildDiscoverResultGrid(
                        pageController.items, pageController.controller),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBarBottom(BuildContext context, DiscoverPageController pageController) {
    if (pageController == null)
      return null;
    if (widget.discoverMap == null || widget.discoverMap.length == 0 || widget.discoverMap.first?.pairs == null)
      return null;
    if (widget.discoverMap.first.pairs.length <= 1)
      return null;
    final _map = widget.discoverMap.first;
    final pairs = widget.discoverMap.first.pairs;
    if (_tabController == null) {
      _tabController = TabController(length: pairs.length, vsync: this);
    }
    return SizedBar(
      height: 50,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: pairs.map((e) => Container(child: Text(e.name ?? ''), alignment: Alignment.center)).toList(),
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.black87,
        indicatorPadding: const EdgeInsets.only(left: 8, right: 8),
        onTap: (index) {
          pageController.selectDiscoverPair(_map.name, pairs[index]);
        },
      ),
    );
  }

  Widget _buildSwitchStyle(BuildContext context) {
    return IconButton(
      icon: Provider.of<Profile>(context, listen: true).switchDiscoverStyle
          ? Icon(Icons.view_module)
          : Icon(Icons.view_headline),
      onPressed: () => Provider.of<Profile>(context, listen: false).switchDiscoverStyle =
          !Provider.of<Profile>(context, listen: false).switchDiscoverStyle,
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

  Widget buildDiscoverResultList(List<SearchItem> items, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      itemCount: items.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == items.length) {
          return LoadMoreView(msg: "正在加载...");
        }
        SearchItem searchItem = items[index];
        if (SearchItemManager.isFavorite(searchItem.url)) {
          searchItem = SearchItemManager.searchItem
              .firstWhere((item) => item.url == searchItem.url);
        }
        return InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: UiSearchItem(item: searchItem),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ChapterPage(searchItem: searchItem)),
          ),
        );
      },
    );
  }

  Widget buildDiscoverResultGrid(List<SearchItem> items, ScrollController controller) {
    return GridView.builder(
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      padding: const EdgeInsets.all(6.0),
      itemCount: items.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == items.length) {
          return LoadMoreView(msg: '加载中...', axis: Axis.vertical);
        }
        SearchItem searchItem = items[index];
        if (SearchItemManager.isFavorite(searchItem.url)) {
          searchItem = SearchItemManager.searchItem
              .firstWhere((item) => item.url == searchItem.url);
        }
        return InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: UIDiscoverItem(searchItem: searchItem),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ChapterPage(searchItem: searchItem)),
          ),
        );
      },
    );
  }
}
