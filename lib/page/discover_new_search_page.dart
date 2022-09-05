import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_new_page_controller.dart';
import 'package:eso/page/source/login_rule_page.dart';
import 'package:eso/profile.dart';
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
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:eso/ui/round_indicator.dart';
import '../fonticons_icons.dart';
import '../global.dart';
import 'chapter_page.dart';
import 'langding_page.dart';
import 'package:eso/model/moreKeys.dart';

class DiscoverNewSearchPage extends StatefulWidget {
  final String originTag;
  final String origin;
  final Rule rule;
  final List<DiscoverMap> discoverMap;
  const DiscoverNewSearchPage({
    this.rule,
    this.originTag,
    this.origin,
    this.discoverMap,
    Key key,
  }) : super(key: key);

  @override
  _DiscoverNewSearchPage createState() => _DiscoverNewSearchPage();

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

class _DiscoverNewSearchPage extends State<DiscoverNewSearchPage>
    with SingleTickerProviderStateMixin {
  Widget _discover;
  DiscoverPageController __pageController;
  TabController _tabController;

  List<DiscoverMap> map = <DiscoverMap>[];
  List<RequestFilters> pairs = <RequestFilters>[];
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
    //print("Profile.darkMode:${Profile().darkMode}");

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
        rule: widget.rule,
        discoverMap: widget.discoverMap,
        discoverUrl: widget.rule.discoverUrl.trim(),
      ),
      child: Consumer<DiscoverPageController>(
        builder:
            (BuildContext context, DiscoverPageController pageController, _) {
          final _iconTheme = Theme.of(context).primaryIconTheme;
          final _textTheme = Theme.of(context).textTheme;
          final _color = _textTheme.bodyText1.color.withOpacity(0.4);

          List<Widget> children = [];
          if (pageController.showSearchField) {
            children.add(KeepAliveWidget(
              wantKeepAlive: true,
              child: _buildListView(
                  context, pageController, pageController.items.last),
            ));
          } else if (map.isNotEmpty) {
            for (var i = 0; i < map.length; i++) {
              children.add(KeepAliveWidget(
                wantKeepAlive: true,
                child: _buildListView(context, pageController,
                    pageController.items[i], map[i], i),
              ));
            }
          }
          return Scaffold(
            appBar: PreferredSize(
              child: pageController.showSearchField
                  ? AppBar(
                      titleSpacing: 0,
                      leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => pageController.toggleSearching(),
                      ),
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      iconTheme: _iconTheme.copyWith(color: _color),
                      actionsIconTheme: _iconTheme.copyWith(color: _color),
                      actions: pageController.queryController.text == ''
                          ? <Widget>[
                              _buildSwitchStyle(context),
                            ]
                          : <Widget>[
                              IconButton(
                                icon: Icon(FIcons.x),
                                onPressed: pageController.clearInputText,
                              ),
                              _buildSwitchStyle(context),
                            ],
                      title: SearchTextField(
                        controller: pageController.queryController,
                        autofocus: true,
                        hintText: '搜索 ${widget.origin}',
                        onSubmitted: (query) => pageController.search(),
                      ),
                      bottom: _buildAppBarBottom(context, pageController),
                    )
                  : AppBar(
                      centerTitle: true,
                      title: Text(
                        pageController.title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      actions: <Widget>[
                        IconButton(
                            onPressed: () => pageController.login(context),
                            icon: Icon(Icons.account_box)),
                        IconButton(
                          tooltip: "搜索",
                          icon: Icon(FIcons.search),
                          onPressed: pageController.toggleSearching,
                        ),
                        _buildSwitchStyle(context),
                      ],
                      bottom: _buildAppBarBottom(context, pageController),
                    ),
              preferredSize: Size.fromHeight(
                  pageController.showSearchField || children.length == 1
                      ? 50.0
                      : 70.0),
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

  final _bodyKey = Map<int, GlobalKey<StateViewState>>();

  Widget _buildFilters(DiscoverPageController pageController, ListDataItem item,
      {int type}) {
    if (pageController.items.length == 0) return Container();
    bool darkMode = Utils.isDarkMode(context);
    final iswrap = pageController.isWrap;

    final nomal = TextStyle(
      color: darkMode ? Colors.grey : Colors.black,
      fontSize: 13,
      fontWeight: FontWeight.normal,
    );
    final primary = TextStyle(
        color: darkMode ? Theme.of(context).primaryColor : Colors.orange[900],
        fontSize: 13,
        fontWeight: FontWeight.w900);

    final nomalButton = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(const Color(0x00000000)),
      padding: MaterialStateProperty.all(
        const EdgeInsets.only(
          right: 8,
          left: 8,
        ),
      ),
      minimumSize: MaterialStateProperty.all(const Size(45, 10)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );

    final primaryButton = ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.only(
          right: 8,
          left: 8,
        ),
      ),
      minimumSize: MaterialStateProperty.all(const Size(45, 25)),
      backgroundColor: MaterialStateProperty.all(
          darkMode ? Theme.of(context).bottomAppBarColor : Colors.grey[100]),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
    Widget _getlist(RequestFilters rule) => iswrap
        ? Wrap(runSpacing: Platform.isWindows ? 13 : 2, spacing: 12, children: [
            for (var i = 0; i < rule.items.length; i++)
              Container(
                height: 35,
                child: InkWell(
                  onTap: () {
                    rule.value = rule.items[i].value;
                    _select(pageController, item.index, item.pair);
                  },
                  child: Text(
                    rule.items[i].title,
                    style: rule.value == rule.items[i].value ? primary : nomal,
                  ),
                ),
              ),

            // TextButton(
            //   style: rule.value == rule.items[i].value
            //       ? primaryButton
            //       : nomalButton,
            //   onPressed: () {
            //     rule.value = rule.items[i].value;
            //     _select(pageController, item.index, item.pair);
            //   },
            //   child: Text(
            //     rule.items[i].title,
            //     style:
            //         rule.value == rule.items[i].value ? primary : nomal,
            //   ),
            // ),

            // SizedBox(
            //   height: Platform.isWindows ? 30 : 0,
            // )
          ])
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: rule.items.length,
            itemBuilder: (BuildContext context, int index_) {
              final option = rule.items[index_];
              return TextButton(
                style: rule.value == option.value ? primaryButton : nomalButton,
                onPressed: () {
                  rule.value = option.value;
                  _select(pageController, item.index, item.pair);
                },
                child: Text(
                  option.title,
                  style: rule.value == option.value ? primary : nomal,
                ),
              );
            },
          );

    Widget _body = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: Platform.isWindows ? 10 : 10,
        ),
        for (var rule in item.pair)
          Container(
            padding: EdgeInsets.only(left: 8),
            height: iswrap ? null : 35,
            child: _getlist(rule),
          ),
      ],
    );
    return type == null
        ? SliverToBoxAdapter(child: _body)
        : Container(child: _body);
  }

  Widget _buildListView(BuildContext context,
      DiscoverPageController pageController, ListDataItem item,
      [DiscoverMap map, int index]) {
    final pairs = map?.pairs;
    if (pairs == null || pairs.isEmpty || pairs.length == 0) {
      if (item.isLoading) {
        return LandingPage();
      } else if (pageController.showSearchResult == false &&
          pageController.showSearchField) {
        int _length = pageController.history.length;
        List<String> _list = pageController.history.reversed
            .toList()
            .sublist(0, _length > 30 ? 30 : _length);

        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "搜索历史",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    child: Text("清空"),
                    onPressed: () {
                      pageController.clearHistory();
                    },
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _list
                    .map(
                      (e) => Container(
                        padding: EdgeInsets.only(top: 5),
                        child: InkWell(
                          onTap: () {
                            pageController.queryController.text = e;

                            pageController.queryController.selection =
                                TextSelection(
                                    baseOffset: e.length,
                                    extentOffset: e.length);

                            pageController.search();
                          },
                          child: Chip(
                            label: Text(e),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
        );
      }

      return _buildBodyView(pageController, item, index);
    }

    if (item.isLoading) {
      final Widget _pairs = pageController.showSearchField
          ? Container()
          : _buildFilters(pageController, item, type: 1);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_pairs, Expanded(child: LandingPage())],
      );
    }

    return _buildBodyView(pageController, item, index);
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
    bool darkMode = Utils.isDarkMode(context);
    return SizedBar(
      height: 35,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: map.map((e) => Tab(text: e.name ?? '')).toList(),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: RoundTabIndicator(
            insets: EdgeInsets.only(left: 5, right: 5),
            borderSide: BorderSide(
                width: 2.0,
                color: darkMode ? Theme.of(context).primaryColor : Colors.red)),
        labelColor: darkMode ? Theme.of(context).primaryColor : Colors.red,
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
            return buildDiscoverResultList(
                item.items, pageController, item, index);
          case 1:
            return buildDiscoverResultList(
                item.items, pageController, item, index,
                builderItem: (v) => UiSearch2Item(item: v));
          case 2:
            return buildDiscoverResultGrid(
              item.items,
              pageController,
              item,
            );
          case 3:
            return buildDiscoverResultGrid(item.items, pageController, item,
                crossAxisCount: 2,
                builderItem: (v) => UIDiscoverItem(searchItem: v));
          case 4:
            return buildDiscoverResultGrid(item.items, pageController, item,
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                builderItem: (v) => UIDiscoverItem(searchItem: v));
          default:
            return buildDiscoverResultGrid(
              item.items,
              pageController,
              item,
            );
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

  Widget buildDiscoverResultList(List<SearchItem> items,
      DiscoverPageController pageController, ListDataItem item, int index,
      {Widget Function(SearchItem searchItem) builderItem}) {
    Widget _filters = pageController.showSearchField
        ? Container()
        : _buildFilters(pageController, item);
    Widget _listView = SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index_) {
          if (index_ == items.length) {
            if (item.length == 0 && item.pair == null && !item.isLoading)
              return Container();
            if (item.more)
              return InkWell(
                child: LoadMoreView(msg: "正在加载..."),
                onTap: () {
                  if (!item.isLoading) {
                    pageController.loadMore(item);
                  }
                },
              );
            return Container();
          }
          SearchItem searchItem = items[index_];
          if (SearchItemManager.isFavorite(
              searchItem.originTag, searchItem.url)) {
            searchItem = SearchItemManager.searchItem.firstWhere((item) =>
                item.url == searchItem.url &&
                item.originTag == searchItem.originTag);
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
        childCount: items.length + 1,
      ),
    );

    List<Widget> list = [];

    if (pageController.showSearchField) {
      list = [
        _listView,
      ];
    } else {
      list = [
        _filters,
        _listView,
      ];
    }

    Widget _listbody = RefreshIndicator(
      child: Scrollbar(
        controller: item.controller,
        child: CustomScrollView(
          controller: item.controller,
          slivers: list,
        ),
      ),
      onRefresh: () async => await onRefresh(pageController, item, index),
    );

    return Stack(
      children: [
        _listbody,
        buildPage(pageController, item),
      ],
    );
  }

  Widget buildDiscoverResultGrid(List<SearchItem> items,
      DiscoverPageController pageController, ListDataItem item,
      {Widget Function(SearchItem searchItem) builderItem,
      double childAspectRatio,
      int crossAxisCount}) {
    final _size = MediaQuery.of(context).size;
    Widget _filters = pageController.showSearchField
        ? SliverToBoxAdapter(
            child: Container(),
          )
        : _buildFilters(pageController, item);
    Widget _listView = RefreshIndicator(
      child: Scrollbar(
        child: CustomScrollView(
          controller: item.controller,
          slivers: [
            _filters,
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (_size.width < _size.height
                    ? (crossAxisCount ?? 3)
                    : ((crossAxisCount ?? 3) * (_size.width / _size.height))
                        .toInt()),
                childAspectRatio: childAspectRatio ?? 0.65,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == items.length) {
                    if (item.length == 0 &&
                        item.pair == null &&
                        !item.isLoading) return Container();
                    if (item.more)
                      return InkWell(
                        child:
                            LoadMoreView(msg: "正在加载...", axis: Axis.vertical),
                        onTap: () {
                          if (!item.isLoading) {
                            pageController.loadMore(item);
                          }
                        },
                      );
                    return Container();
                  }
                  SearchItem searchItem = items[index];
                  if (SearchItemManager.isFavorite(
                      searchItem.originTag, searchItem.url)) {
                    searchItem = SearchItemManager.searchItem.firstWhere(
                        (item) =>
                            item.originTag == searchItem.originTag &&
                            item.url == searchItem.url);
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
                          builder: (context) =>
                              ChapterPage(searchItem: searchItem)),
                    ),
                  );
                },
                childCount: items.length + 1,
              ),
            )
          ],
        ),
        controller: item.controller,
      ),
      onRefresh: () async => await onRefresh(pageController, item, 0),
    );

    return Stack(
      children: [
        _listView,
        buildPage(pageController, item),
      ],
    );
  }

  Widget buildPage(
    DiscoverPageController pageController,
    ListDataItem item,
  ) =>
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
                    pageController.fetchData(
                      item,
                      goto: true,
                    );
                  }
                } else {
                  Utils.toast("请输入大于0的数字");
                }
              },
            ),
          ),
        ),
      );

  Future<void> onRefresh(DiscoverPageController pageController,
      ListDataItem item, int index) async {
    if (item.isLoading) return;
    if (pageController.showSearchField)
      await pageController.search();
    else {
      item.page = 1;
      await pageController.fetchData(item);
    }
  }

  /// 切换到指定分类
  _select(DiscoverPageController pageController, int index,
      [List<RequestFilters> pair]) {
    pageController.selectDiscoverPair(map[index].name, pair);
  }
}

// class _FlowDelegate extends FlowDelegate {
//   final int count;
//   const _FlowDelegate(this.count) : super();
//   @override
//   void paintChildren(FlowPaintingContext context) {
//     final screenW = context.size.width;
//     final lastIndex = context.childCount - 1;
//     double padding = 3; //间距
//     double x = padding; //x坐标
//     double y = padding; //y坐标
//     double lastW = context.getChildSize(lastIndex).width + padding;
//     for (int i = 0; i < context.childCount - 1; i++) {
//       final size = context.getChildSize(i);
//       final w = size.width + x + padding;
//       if (w <= screenW - lastW) {
//         context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
//         x = w;
//       } else {
//         if (i == lastIndex - 1 && (w - padding) <= screenW - 3)
//           // lastIndex 是更多按钮， lastIndex - 1 就最真正的最后一个。
//           // 如果最后一个显示得下，就不用显示更多按钮了
//           context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
//         else
//           context.paintChild(context.childCount - 1,
//               transform: Matrix4.translationValues(screenW - lastW, y, 0));
//         return;
//       }
//     }
//   }
//   @override
//   Size getSize(BoxConstraints constraints) {
//     return Size(double.infinity, count == 0 ? 0 : 45);
//   }
//   @override
//   bool shouldRepaint(FlowDelegate oldDelegate) {
//     return oldDelegate != this;
//   }
// }
