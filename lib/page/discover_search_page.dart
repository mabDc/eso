import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_discover_item.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/widgets/keep_alive_widget.dart';
import 'package:eso/ui/widgets/load_more_view.dart';
import 'package:eso/ui/edit/search_edit.dart';
import 'package:eso/ui/widgets/size_bar.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eso/ui/round_indicator.dart';

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

  List<DiscoverMap> map = <DiscoverMap>[];
  List<DiscoverPair> pairs = <DiscoverPair>[];

  @override
  void dispose() {
    __pageController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.discoverMap == null ||
        widget.discoverMap.isEmpty ||
        widget.discoverMap.first?.pairs == null) return null;
    map = widget.discoverMap;
    pairs = map.first.pairs;
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

          List<Widget> children = [];
          if (pageController.showSearchField) {
            children.add(KeepAliveWidget(
              wantKeepAlive: true,
              child: _buildListView(context, pageController, pageController.items.last),
            ));
          } else if (map.isNotEmpty) {
            for (var i = 0; i < map.length; i++) {
              children.add(KeepAliveWidget(
                wantKeepAlive: true,
                child: _buildListView(
                    context, pageController, pageController.items[i], map[i], i),
              ));
            }
          }

          return Scaffold(
            appBar: pageController.showSearchField
                ? AppBarEx(
                    titleSpacing: 0.0,
                    backgroundColor: Theme.of(context).appBarTheme.color,
                    iconTheme: _iconTheme.copyWith(color: _color),
                    actionsIconTheme: _iconTheme.copyWith(color: _color),
                    leading: AppBarEx.buildLeading(
                      context,
                      onPressed: pageController.toggleSearching,
                    ),
                    actions: pageController.queryController.text == ''
                        ? <Widget>[
                            _buildSwitchStyle(context),
                          ]
                        : <Widget>[
                            AppBarButton(
                              icon: Icon(FIcons.x),
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
                    preferredHeight: 32,
                  )
                : AppBarEx(
                    titleSpacing: 0.0,
                    title: Text(pageController.title),
                    actions: <Widget>[
                      AppBarButton(
                        tooltip: "搜索",
                        icon: Icon(FIcons.search),
                        onPressed: pageController.toggleSearching,
                      ),
//                      IconButton(
//                        icon: Icon(Icons.filter_list),
//                        onPressed: pageController.toggleDiscoverFilter,
//                      ),
                      _buildSwitchStyle(context),
                    ],
                    bottom: _buildAppBarBottom(context, pageController),
                    preferredHeight: 32,
                  ),
            body: children.isEmpty
                ? Container()
                : children.length == 1
                    ? children.first
                    : TabBarView(
                        controller: _tabController,
                        children: children,
                      ),
          );
        },
      ),
    );
  }

  Widget buildPairButton(
      DiscoverPair pair, Color color, DiscoverPageController pageController, int index) {
    return Container(
      height: 24,
      width: 20.0 + 12 * pair.name.length,
      margin: EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: OutlineButton(
        child: Text(
          pair.name,
          style: TextStyle(fontSize: 12),
        ),
        padding: EdgeInsets.zero,
        textColor: color,
        onPressed: () => _select(pageController, index, pair),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        borderSide: color != null ? BorderSide(color: color) : null,
      ),
    );
  }

  Widget _buildListView(
      BuildContext context, DiscoverPageController pageController, ListDataItem item,
      [DiscoverMap map, int index]) {
    final pairs = map?.pairs;
    if (pairs == null || pairs.isEmpty || pairs.length == 1) {
      if (item.isLoading) {
        return LandingPage();
      }
      return Provider.of<Profile>(context, listen: false).switchDiscoverStyle
          ? buildDiscoverResultList(item.items, pageController, item)
          : buildDiscoverResultGrid(item.items, pageController, item);
    }
    Color primaryColor = Theme.of(context).primaryColor;
    final discoverPair = pageController.discoverParams[map.name];
    if (item.isLoading) {
      return Column(
        children: [
          Wrap(
            children: pairs
                .map((pair) => buildPairButton(pair,
                    pair == discoverPair ? primaryColor : null, pageController, index))
                .toList(),
          ),
          Expanded(child: LandingPage())
        ],
      );
    }
    return Column(
      children: [
        Wrap(
          children: pairs
              .map((pair) => buildPairButton(pair,
                  pair == discoverPair ? primaryColor : null, pageController, index))
              .toList(),
        ),
        Expanded(
          child: Provider.of<Profile>(context, listen: false).switchDiscoverStyle
              ? buildDiscoverResultList(item.items, pageController, item)
              : buildDiscoverResultGrid(item.items, pageController, item),
        )
      ],
    );
  }

  PreferredSizeWidget _buildAppBarBottom(
      BuildContext context, DiscoverPageController pageController) {
    if (pageController == null || pageController.showSearchField) return null;
    if (map == null || map.isEmpty || map.length <= 1) return null;
    if (_tabController == null) {
      _tabController = TabController(length: map.length, vsync: this);
      _tabController.addListener(() {
        _select(pageController, _tabController.index);
      });
    }
    return SizedBar(
      height: 42,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: map.map((e) => Tab(text: e.name ?? '')).toList(),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: RoundTabIndicator(
            insets: EdgeInsets.only(left: 5, right: 5),
            borderSide: BorderSide(width: 3.0, color: Theme.of(context).primaryColor)),
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color,
        onTap: (index) {
          _select(pageController, index);
        },
      ),
    );
  }

  Widget _buildSwitchStyle(BuildContext context) {
    return AppBarButton(
      tooltip: "切换显示",
      icon: Provider.of<Profile>(context, listen: true).switchDiscoverStyle
          ? Icon(FIcons.grid)
          : Icon(FIcons.list),
      onPressed: () => Provider.of<Profile>(context, listen: false).switchDiscoverStyle =
          !Provider.of<Profile>(context, listen: false).switchDiscoverStyle,
    );
  }

  Widget buildDiscoverResultList(
      List<SearchItem> items, DiscoverPageController pageController, ListDataItem item) {
    return RefreshIndicator(
      child: ListView.builder(
        controller: item.controller,
        itemCount: items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length) {
            if (item.length == 0 && item.pair == null && !item.isLoading)
              return Container();
            if (item.more) return LoadMoreView(msg: "正在加载...");
            return Container();
          }
          SearchItem searchItem = items[index];
          if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
            searchItem = SearchItemManager.searchItem
                .firstWhere((item) => item.url == searchItem.url);
          }
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: UiSearchItem(item: searchItem),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => ChapterPage(searchItem: searchItem)),
            ),
          );
        },
      ),
      onRefresh: () async => await onRefresh(pageController, item),
    );
  }

  Widget buildDiscoverResultGrid(
      List<SearchItem> items, DiscoverPageController pageController, ListDataItem item) {
    return RefreshIndicator(
      child: GridView.builder(
        controller: item.controller,
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
            if (item.length == 0 && item.pair == null && !item.isLoading)
              return Container();
            if (item.more) return LoadMoreView(msg: '加载中...', axis: Axis.vertical);
            return Container();
          }
          SearchItem searchItem = items[index];
          if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
            searchItem = SearchItemManager.searchItem.firstWhere((item) =>
                item.originTag == searchItem.originTag && item.url == searchItem.url);
          }
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: UIDiscoverItem(searchItem: searchItem),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => ChapterPage(searchItem: searchItem)),
            ),
          );
        },
      ),
      onRefresh: () async => await onRefresh(pageController, item),
    );
  }

  onRefresh(DiscoverPageController pageController, ListDataItem item) async {
    if (item.isLoading) return;
    if (pageController.showSearchField)
      await pageController.search();
    else {
      item.page = 1;
      await pageController.fetchData(item);
    }
  }

  /// 切换到指定分类
  _select(DiscoverPageController pageController, int index, [DiscoverPair pair]) {
    pageController.selectDiscoverPair(map[index].name, pair);
  }
}
