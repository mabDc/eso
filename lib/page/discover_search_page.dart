import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eso/api/api.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/main.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/ui/ui_discover_item.dart';
import 'package:eso/ui/ui_search2_item.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/widgets/keep_alive_widget.dart';
import 'package:eso/ui/widgets/load_more_view.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/ui/widgets/right_sheet.dart';
import 'package:eso/ui/widgets/size_bar.dart';
import 'package:eso/ui/widgets/state_view.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:eso/ui/round_indicator.dart';
import '../fonticons_icons.dart';
import '../global.dart';
import 'chapter_page.dart';
import 'langding_page.dart';

class DiscoverSearchPage extends StatefulWidget {
  final String originTag;
  final String origin;
  final Rule rule;
  final List<DiscoverMap> discoverMap;

  const DiscoverSearchPage({
    this.rule,
    this.originTag,
    this.origin,
    this.discoverMap,
    Key key,
  }) : super(key: key);

  @override
  _DiscoverSearchPageState createState() => _DiscoverSearchPageState();

  int get viewStyle => rule == null
      ? 0
      : rule.viewStyle == null
          ? 0
          : rule.viewStyle;

  /// 切换显示样式
  switchViewStyle() async {
    if (rule == null) return;
    var _style = viewStyle + 1;
    if (_style > 4) _style = 0;
    rule.viewStyle = _style;
    await Global.ruleDao.insertOrUpdateRule(rule);
  }
}

class _DiscoverSearchPageState extends State<DiscoverSearchPage>
    with SingleTickerProviderStateMixin {
  Widget _discover;
  DiscoverPageController __pageController;
  TabController _tabController;

  List<DiscoverMap> map = <DiscoverMap>[];
  List<DiscoverPair> pairs = <DiscoverPair>[];

  final _popupMenuController = TextEditingController();

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
        discoverMap: widget.discoverMap,
        searchUrl: widget.rule.searchUrl,
      ),
      child: Consumer<DiscoverPageController>(
        builder: (BuildContext context, DiscoverPageController pageController, _) {
          final _iconTheme = Theme.of(context).primaryIconTheme;
          final _textTheme = Theme.of(context).textTheme;
          final _color = _textTheme.bodyText1.color.withOpacity(0.4);

          List<Widget> children = [];
          if (pageController.showSearchField) {
            children.add(KeepAliveWidget(
              wantKeepAlive: true,
              child: _buildListView(context, pageController, pageController.searchItem),
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
          return Container(
            decoration: globalDecoration,
            child: Scaffold(
              appBar: pageController.showSearchField
                  ? AppBar(
                      titleSpacing: 0,
                      leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => pageController.toggleSearching(),
                      ),
                      backgroundColor: Theme.of(context).appBarTheme.color,
                      iconTheme: _iconTheme.copyWith(color: _color),
                      actionsIconTheme: _iconTheme.copyWith(color: _color),
                      actions: <Widget>[
                        _buildSwitchStyle(context),
                      ],
                      title: SearchTextField(
                        controller: pageController.queryController,
                        autofocus: true,
                        hintText: '搜索 ${widget.origin}',
                        onSubmitted: (query) => pageController.submitSearch(),
                      ),
                      bottom: _buildAppBarBottom(context, pageController),
                    )
                  : AppBar(
                      title: Text(pageController.title),
                      actions: <Widget>[
                        IconButton(
                          tooltip: "搜索",
                          icon: Icon(FIcons.search),
                          onPressed: pageController.toggleSearching,
                        ),
                        _buildSwitchStyle(context),
                      ],
                      bottom: _buildAppBarBottom(context, pageController),
                    ),
              body: children.isEmpty
                  ? Container()
                  : children.length == 1
                      ? children.first
                      : TabBarView(
                          controller: _tabController,
                          children: children,
                        ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPairButton(DiscoverPair pair, Color color, Color bgColor,
      DiscoverPageController pageController, int index,
      {VoidCallback onTap}) {
    return Container(
      height: 24,
      width:
          20 + min(6 * utf8.encode(pair.name).length, 12 * pair.name.length).toDouble(),
      margin: EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: OutlinedButton(
        child: Text(
          pair.name,
          style: TextStyle(fontSize: 12, color: color),
        ),
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor: MaterialStateProperty.all(bgColor),
            shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ))),
        // padding: EdgeInsets.zero,
        // textColor: color,
        onPressed: () {
          _select(pageController, index, pair);
          if (onTap != null) onTap();
        },
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(12)),
        // ),
        // borderSide:
        //     color != null ? BorderSide(color: color, width: Global.borderSize) : null,
      ),
    );
  }

  Widget _buildMorePairIconButton(int index, bool showPairs, DiscoverMap map,
      DiscoverPageController pageController, VoidCallback onChanged) {
    return Container(
      height: 24,
      width: 24,
      margin: EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: IconButton(
        icon: Icon(showPairs ? FIcons.chevron_up : FIcons.chevron_right,
            size: 16, color: Theme.of(context).primaryColor),
        padding: EdgeInsets.zero,
        tooltip: showPairs ? "收起" : "更多",
        onPressed: () {
          if ((map?.pairs?.length ?? 0) > 8) {
            // 大于8个，显示右侧滑页面
            _popupMenuController.text = '';
            showModalRightSheet(
                context: context,
                builder: (context) {
                  return Container(
                    width: min(MediaQuery.of(context).size.width * 0.75, 350),
                    child: _buildMorePairsPopupMenu(index, map, pageController),
                  );
                },
                clickEmptyPop: true);
          } else {
            // 直接展表
            _showAllPairs[index] = !(_showAllPairs[index] ?? false);
            onChanged();
          }
        },
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(width: Global.borderSize, color: Theme.of(context).primaryColor),
      ),
    );
  }

  /// 右侧小分类弹出菜单栏
  Widget _buildMorePairsPopupMenu(
      int index, DiscoverMap map, DiscoverPageController pageController) {
    return SafeArea(
      child: StatefulBuilder(
        builder: (context, _state) {
          var pairs = map?.pairs;
          final Color primaryColor = Theme.of(context).primaryColor;
          final _listKey = GlobalKey();
          final _updateList = (String v) {
            if (Utils.empty(v))
              pairs = map?.pairs;
            else {
              pairs = [];
              if (map?.pairs != null) {
                var _v = v.toLowerCase();
                map.pairs.forEach((pair) {
                  if (pair.name.toLowerCase().indexOf(_v) >= 0) pairs.add(pair);
                });
              }
            }
            _listKey.currentState?.setState(() => null);
          };
          _updateList(_popupMenuController.text);

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SearchTextField(
                hintText: "搜索分类名称",
                controller: _popupMenuController,
                onChanged: (v) => _updateList(v),
                onSubmitted: (v) => _updateList(v),
              ),
            ),
            Divider(height: Global.lineSize),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: StatefulBuilder(
                  key: _listKey,
                  builder: (context, _state) {
                    final discoverPair = pageController.discoverParams[map.name];
                    return Wrap(
                      children: pairs
                          .map((pair) => buildPairButton(
                                  pair,
                                  pair == discoverPair
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).textTheme.bodyLarge.color,
                                  pair == discoverPair
                                      ? primaryColor
                                      : Theme.of(context).cardColor,
                                  pageController,
                                  index, onTap: () {
                                _state(() => null);
                              }))
                          .toList(),
                    );
                  },
                ),
              ),
            )
          ]);
        },
      ),
    );
  }

  final _showAllPairs = Map<int, bool>();
  final _bodyKey = Map<int, GlobalKey<StateViewState>>();

  Widget _buildListView(
      BuildContext context, DiscoverPageController pageController, ListDataItem item,
      [DiscoverMap map, int index]) {
    final pairs = map?.pairs;
    if (pairs == null || pairs.isEmpty || pairs.length == 1) {
      if (pageController.showSearchField && pageController.searchItems.length > 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatefulBuilder(
              builder: (context, _state) {
                return Container(
                  width: double.infinity,
                  color: Theme.of(context).primaryColor.withAlpha(50),
                  padding: const EdgeInsets.fromLTRB(3, 3, 3, 8),
                  child: Wrap(
                    spacing: 3,
                    children: pageController.searchItems.keys.map((option) {
                      final color = option == pageController.selectOption
                          ? Theme.of(context).cardColor
                          : Theme.of(context).textTheme.bodyLarge.color;
                      final bgColor = option == pageController.selectOption
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor;
                      return Container(
                        height: 24,
                        width: 20 +
                            min(6 * utf8.encode(option).length, 12 * option.length)
                                .toDouble(),
                        margin: EdgeInsets.fromLTRB(4, 8, 4, 0),
                        child: OutlinedButton(
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 12, color: color),
                          ),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor: MaterialStateProperty.all(bgColor),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ))),
                          // padding: EdgeInsets.zero,
                          // textColor: color,
                          onPressed: () {
                            pageController.selectOption = option;
                          },
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.all(Radius.circular(12)),
                          // ),
                          // borderSide:
                          //     color != null ? BorderSide(color: color, width: Global.borderSize) : null,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Expanded(
              child: item.isLoading
                  ? LandingPage()
                  : _buildBodyView(pageController, item, index),
            )
          ],
        );
      }

      if (item.isLoading) {
        return LandingPage();
      }

      return _buildBodyView(pageController, item, index);
    }

    final Widget _pairs = StatefulBuilder(
      builder: (context, _state) {
        final discoverPair = pageController.discoverParams[map.name];
        final _showPairs = _showAllPairs[index] ?? false;
        final _pairsViews = pairs
            .map((pair) => buildPairButton(
                pair,
                pair == discoverPair
                    ? Theme.of(context).cardColor
                    : Theme.of(context).textTheme.bodyLarge.color,
                pair == discoverPair
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                pageController,
                index))
            .toList();
        if (_pairsViews.length > 1)
          _pairsViews.add(_buildMorePairIconButton(
              index, _showPairs, map, pageController, () => _state(() => null)));

        return Container(
          width: _showPairs ? double.infinity : null,
          color: Theme.of(context).primaryColor.withAlpha(50),
          padding: _showPairs ? const EdgeInsets.fromLTRB(3, 3, 3, 8) : EdgeInsets.zero,
          child: _showPairs
              ? Wrap(
                  spacing: 3,
                  children: _pairsViews,
                )
              : Flow(
                  delegate: _FlowDelegate(pairs.length),
                  children: _pairsViews,
                ),
        );
      },
    );

    if (item.isLoading) {
      return Column(
        children: [_pairs, Expanded(child: LandingPage())],
      );
    }
    return Column(
      children: [
        _pairs,
        Expanded(
          child: _buildBodyView(pageController, item, index),
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

  Widget _buildBodyView(
      DiscoverPageController pageController, ListDataItem item, int index) {
    if (!_bodyKey.containsKey(index)) _bodyKey[index] = GlobalKey();
    return StateView(
      key: _bodyKey[index],
      builder: (context) {
        switch (widget.viewStyle) {
          case 0:
            return buildDiscoverResultList(item.items, pageController, item);
          case 1:
            return buildDiscoverResultList(item.items, pageController, item,
                builderItem: (v) => UiSearch2Item(item: v));
          case 2:
            return buildDiscoverResultGrid(item.items, pageController, item);
          case 3:
            return buildDiscoverResultGrid(item.items, pageController, item,
                crossAxisCount: 2, builderItem: (v) => UIDiscoverItem(searchItem: v));
          case 4:
            return buildDiscoverResultGrid(item.items, pageController, item,
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                builderItem: (v) => UIDiscoverItem(searchItem: v));
          default:
            return buildDiscoverResultGrid(item.items, pageController, item);
        }
      },
    );
  }

  Widget _buildSwitchStyle(BuildContext context) {
    return IconButton(
      tooltip: "切换布局",
      icon: Icon(FIcons.grid),
      iconSize: 18,
      onPressed: () async {
        await widget.switchViewStyle();
        _bodyKey.forEach((key, value) {
          value.currentState?.update();
        });
      },
    );
  }

  Widget buildDiscoverResultList(
      List<SearchItem> items, DiscoverPageController pageController, ListDataItem item,
      {Widget Function(SearchItem searchItem) builderItem}) {
    return Stack(
      children: [
        RefreshIndicator(
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
                searchItem = SearchItemManager.searchItem.firstWhere((item) =>
                    item.url == searchItem.url && item.originTag == searchItem.originTag);
              }
              return InkWell(
                child: builderItem != null
                    ? builderItem(searchItem)
                    : UiSearchItem(item: searchItem),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ChapterPage(searchItem: searchItem)),
                ),
              );
            },
          ),
          onRefresh: () async => await onRefresh(pageController, item),
        ),
        buildPage(pageController, item),
      ],
    );
  }

  Widget buildDiscoverResultGrid(
      List<SearchItem> items, DiscoverPageController pageController, ListDataItem item,
      {Widget Function(SearchItem searchItem) builderItem,
      double childAspectRatio,
      int crossAxisCount}) {
    final _size = MediaQuery.of(context).size;
    return Stack(
      children: [
        RefreshIndicator(
          child: GridView.builder(
            controller: item.controller,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (_size.width < _size.height
                  ? (crossAxisCount ?? 3)
                  : ((crossAxisCount ?? 3) * (_size.width / _size.height)).toInt()),
              childAspectRatio: childAspectRatio ?? 0.65,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            padding: const EdgeInsets.all(6.0),
            itemCount: items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == items.length) {
                if (item.length == 0 && item.pair == null && !item.isLoading)
                  return Container();
                if (item.more)
                  return LoadMoreView(msg: '加载中...', axis: Axis.vertical, timeout: 20000);
                return Container();
              }
              SearchItem searchItem = items[index];
              if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
                searchItem = SearchItemManager.searchItem.firstWhere((item) =>
                    item.originTag == searchItem.originTag && item.url == searchItem.url);
              }
              return InkWell(
                child: builderItem == null
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: UIDiscoverItem(searchItem: searchItem),
                      )
                    : builderItem(searchItem),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ChapterPage(searchItem: searchItem)),
                ),
              );
            },
          ),
          onRefresh: () async => await onRefresh(pageController, item),
        ),
        buildPage(pageController, item),
      ],
    );
  }

  Widget buildPage(DiscoverPageController pageController, ListDataItem item) =>
      Positioned(
        right: 0,
        bottom: 0,
        child: Card(
          child: IntrinsicWidth(
            child: TextField(
              autofocus: false,
              controller: TextEditingController(text: "${item.page}"),
              textAlign: TextAlign.end,
              keyboardType: Platform.isIOS
                  ? TextInputType.numberWithOptions(signed: true, decimal: true)
                  : TextInputType.number,
              decoration: const InputDecoration(
                suffixText: "页",
                contentPadding: EdgeInsets.all(6),
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value.trim());
                if (page != null && page > 0) {
                  if (pageController.showSearchField) {
                    pageController.search(page, true);
                  } else {
                    item.page = page;
                    pageController.fetchData(item, goto: true);
                  }
                } else {
                  Utils.toast("请输入大于0的数字");
                }
              },
            ),
          ),
        ),
      );

  Future<void> onRefresh(DiscoverPageController pageController, ListDataItem item) async {
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

class _FlowDelegate extends FlowDelegate {
  final int count;
  const _FlowDelegate(this.count) : super();

  @override
  void paintChildren(FlowPaintingContext context) {
    final screenW = context.size.width;
    final lastIndex = context.childCount - 1;
    double padding = 3; //间距
    double x = padding; //x坐标
    double y = padding; //y坐标
    double lastW = context.getChildSize(lastIndex).width + padding;

    for (int i = 0; i < context.childCount - 1; i++) {
      final size = context.getChildSize(i);
      final w = size.width + x + padding;
      if (w <= screenW - lastW) {
        context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
        x = w;
      } else {
        if (i == lastIndex - 1 && (w - padding) <= screenW - 3)
          // lastIndex 是更多按钮， lastIndex - 1 就最真正的最后一个。
          // 如果最后一个显示得下，就不用显示更多按钮了
          context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
        else
          context.paintChild(context.childCount - 1,
              transform: Matrix4.translationValues(screenW - lastW, y, 0));
        return;
      }
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(double.infinity, count == 0 ? 0 : 45);
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
