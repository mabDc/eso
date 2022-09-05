// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:eso/api/api_js_engine.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/global.dart';
// import 'package:eso/page/chapter_page.dart';
// import 'package:eso/ui/round_indicator.dart';
// import 'package:eso/ui/ui_discover_item.dart';
// import 'package:eso/ui/ui_search2_item.dart';
// import 'package:eso/ui/ui_search_item.dart';
// import 'package:eso/ui/ui_text_field.dart';
// import 'package:eso/ui/widgets/keep_alive_widget.dart';
// import 'package:eso/ui/widgets/load_more_view.dart';
// import 'package:eso/ui/widgets/size_bar.dart';
// import 'package:eso/ui/widgets/state_view.dart';
// import 'package:eso/utils.dart';
// import 'package:floor/floor.dart';
// import 'package:flutter/material.dart';
// import 'package:eso/model/moreKeys.dart';
// import 'package:flutter/rendering.dart';
// import 'package:win32/win32.dart';
// import '../api/api.dart';
// import '../api/api_manager.dart';
// import '../database/rule.dart';
// import '../fonticons_icons.dart';
// import 'langding_page.dart';
// import 'package:logger/logger.dart';

// class XitemList {
//   bool more;
//   bool load;
//   int page;
//   ScrollController scrollController_;
//   String listdiscoverUrl;
//   List<SearchItem> discoverItems;
//   bool isLoading;
//   XitemList({
//     this.more,
//     this.load,
//     this.page,
//     this.scrollController_,
//     this.listdiscoverUrl,
//     this.discoverItems,
//     this.isLoading,
//   });
// }

// class DiscoverNewPage extends StatefulWidget {
//   final Rule rule;
//   DiscoverNewPage({Key key, this.rule}) : super(key: key);

//   @override
//   State<DiscoverNewPage> createState() => _DiscoverNewPageState();

//   int get viewStyle => rule == null
//       ? 0
//       : rule.viewStyle == null
//           ? 0
//           : rule.viewStyle;

//   /// 切换显示样式
//   switchViewStyle() async {
//     if (rule == null) return;
//     var _style = viewStyle + 1;
//     if (_style > 4) _style = 0;
//     rule.viewStyle = _style;
//     print("_style:${_style}");
//     await Global.ruleDao.insertOrUpdateRule(rule);
//   }
// }

// class _DiscoverNewPageState extends State<DiscoverNewPage>
//     with SingleTickerProviderStateMixin {
//   //DiscoverRule _discoverRule;

//   ItemMoreKeys moreKeys;
//   int currentindex = 0;
//   TabController tabController_;
//   List<XitemList> xitemListData = [];
//   List<XitemList> xitemListDataSearch = [];

//   final _bodyKey = Map<int, GlobalKey<StateViewState>>();

//   @override
//   void initState() {
//     queryController = TextEditingController();
//     moreKeys = ItemMoreKeys.fromJson(jsonDecode(widget.rule.discoverMoreKeys));
//     print("moreKeys:${moreKeys}");
//     for (var i = 0; i < moreKeys.list.length; i++) {
//       xitemListData.add(XitemList(
//         more: false,
//         load: false,
//         page: 1,
//         listdiscoverUrl: null,
//         scrollController_: ScrollController(),
//         discoverItems: [],
//         isLoading: false,
//       ));
//       xitemListData[i].scrollController_.addListener(() {
//         if (xitemListData[i].scrollController_.position.pixels ==
//             xitemListData[i].scrollController_.position.maxScrollExtent) {
//           xitemListData[i].page++;
//           xitemListData[i].more = true;
//           if (!xitemListData[i].isLoading) {
//             parseRule(moreKeys.list[i], xitemListData[i], xitemListData[i].more,
//                 false, xitemListData[i].page);
//           }
//         }
//       });
//     }
//     xitemListDataSearch.add(XitemList(
//       more: false,
//       load: false,
//       page: 1,
//       listdiscoverUrl: null,
//       scrollController_: ScrollController(),
//       discoverItems: [],
//       isLoading: false,
//     ));
//     xitemListDataSearch.first.scrollController_.addListener(() {
//       if (xitemListDataSearch.first.scrollController_.position.pixels ==
//           xitemListDataSearch
//               .first.scrollController_.position.maxScrollExtent) {
//         xitemListDataSearch.first.page++;
//         xitemListDataSearch.first.more = true;
//         if (!xitemListDataSearch.first.isLoading && showSearchResult) {
//           parseRule(
//               null,
//               xitemListDataSearch.first,
//               xitemListDataSearch.first.more,
//               false,
//               xitemListDataSearch.first.page);
//         }
//       }
//     });

//     //print("length:${discoverItems.length}");
//     xitemListData.first.load = true;
//     Future.delayed(Duration(milliseconds: 100), () {
//       parseRule(moreKeys.list.first, xitemListData.first, false, false, 1);
//     });

//     super.initState();
//   }

//   PreferredSizeWidget _buildAppBarBottom() {
//     if (moreKeys == null) return null;
//     if (tabController_ == null) {
//       tabController_ = TabController(
//           initialIndex: currentindex,
//           length: moreKeys.list.length,
//           vsync: this);
//       tabController_.addListener(() {
//         currentindex = tabController_.index;
//         if (tabController_.indexIsChanging ||
//             xitemListData[tabController_.index].discoverItems.length == 0) {
//           xitemListData[tabController_.index].load = true;
//           print("加载动画");
//         }
//         parseRule(moreKeys.list[currentindex],
//             xitemListData[tabController_.index], false, false, 1);
//         print(
//             "滑动事件 currentindex:${currentindex},index:${tabController_.index}");
//       });
//     }

//     return SizedBar(
//       height: 35,
//       child: TabBar(
//         controller: tabController_,
//         isScrollable: true,
//         tabs: moreKeys.list.map((e) => Tab(text: e.title ?? '')).toList(),
//         indicatorSize: TabBarIndicatorSize.label,
//         indicator: RoundTabIndicator(
//             insets: EdgeInsets.only(left: 5, right: 5),
//             borderSide:
//                 BorderSide(width: 3.0, color: Theme.of(context).primaryColor)),
//         labelColor: Theme.of(context).primaryColor,
//         unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color,
//         onTap: (index) {
//           //parseRule(moreKeys.list[index], index, false);
//           //_select(pageController, index);
//         },
//       ),
//     );
//   }

//   Future<void> parseRule(ListFilters listFilters, XitemList items, bool ismore_,
//       bool isRefresh, int loadPage) async {
//     Map<String, String> filters = {};
//     setState(() {});
//     print("items.isLoading:${items.isLoading}");
//     if (items.isLoading) {
//       return;
//     }
//     print("parseRule");
//     if (!ismore_ && items.discoverItems.length > 0 && !isRefresh) {
//       return;
//     }
//     if (isRefresh || !ismore_) {
//       items.discoverItems.clear();
//     }
//     items.isLoading = true;
//     if (listFilters != null) {
//       listFilters.requestFilters.forEach((e) {
//         filters[e.key] = e.value == null ? '' : e.value;
//       });
//       try {
//         await JSEngine.evaluate("""
//           host = ${jsonEncode(widget.rule.host)};
//           page = ${loadPage};
//           params.detailUrl = ${items.listdiscoverUrl};
//           params.tabIndex = ${currentindex};
//           params.pageIndex = page;
//           params.filters = ${jsonEncode(filters)};
//           1+1;
//           """);
//         items.listdiscoverUrl = jsonEncode(
//             await JSEngine.evaluate(widget.rule.discoverUrl.substring(4)));
//       } catch (e) {
//         print("e:{$e}");
//       }

//       print("listdiscoverUrl:${items.listdiscoverUrl}");
//     }
//     try {
//       List<SearchItem> value = [];
//       if (showSearchField) {
//         print("queryController.text:${queryController.text}");
//         value = await APIManager.search(
//             widget.rule.id, queryController.text, loadPage);
//       } else {
//         value = await APIManager.discover(widget.rule.id,
//             {"": DiscoverPair("", items.listdiscoverUrl)}, loadPage);
//       }
//       print("value:${value.length}");
//       if (value.length == 0 && items.more) {
//         items.page--;
//       }
//       items.discoverItems.addAll(value);
//       items.more = value.length > 0;
//     } catch (e) {
//       if (items.more) {
//         items.more = !items.more;
//         items.page--;
//       }
//       print(e);
//       Utils.toast("${e.toString()}");
//     } finally {
//       items.load = false;
//       items.isLoading = false;
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     moreKeys.list.clear();
//     if (xitemListData.length > 0) {
//       xitemListData.clear();
//     }
//     super.dispose();
//   }

//   Future<void> onRefresh(XitemList items) async {
//     items.page = 1;
//     items.load = true;
//     items.discoverItems.clear();
//     await parseRule(moreKeys.list[currentindex], items, true, true, 1);
//     await Future.delayed(Duration(milliseconds: 200), () {
//       print("刷新完成");
//       setState(() {});
//     });
//   }

//   Widget _buildSwitchStyle(BuildContext context) {
//     return IconButton(
//       tooltip: "切换布局",
//       icon: Icon(FIcons.grid),
//       iconSize: 18,
//       onPressed: () async {
//         await widget.switchViewStyle();
//         _bodyKey.forEach((key, value) {
//           value.currentState?.update();
//         });
//       },
//     );
//   }

//   bool showSearchField = false;
//   bool showSearchResult = false;
//   TextEditingController queryController;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: showSearchField
//           ? AppBar(
//               //bottom:  _buildAppBarBottom(),
//               title: SearchTextField(
//                 controller: queryController,
//                 autofocus: true,
//                 hintText: '搜索 ${widget.rule.name}',
//                 onSubmitted: (query) {
//                   print("搜素");
//                   xitemListDataSearch.first.load = true;
//                   showSearchResult = true;
//                   parseRule(null, xitemListDataSearch.first, false, true, 1);
//                   //搜索
//                 },
//               ),
//               toolbarHeight: 40,
//               leading: IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () {
//                     showSearchResult = false;
//                     queryController.text = '';
//                     xitemListDataSearch.first.load = false;
//                     xitemListDataSearch.first.more = false;
//                     xitemListDataSearch.first.listdiscoverUrl = '';
//                     xitemListDataSearch.first.page = 1;
//                     xitemListDataSearch.first.discoverItems.clear();
//                     showSearchField = !showSearchField;
//                     showSearchResult = false;
//                     setState(() {});
//                   }),
//               actions: queryController.text == '' //启用搜索
//                   ? [
//                       _buildSwitchStyle(context),
//                     ]
//                   : [
//                       IconButton(
//                         icon: Icon(FIcons.x),
//                         onPressed: () {
//                           showSearchResult = false;
//                           queryController.text = '';
//                           setState(() {});
//                           //清除
//                         },
//                       ),
//                       _buildSwitchStyle(context),
//                     ],
//             )
//           : AppBar(
//               bottom: _buildAppBarBottom(),
//               title: Text(widget.rule.name),
//               toolbarHeight: 40,
//               actions: [
//                 _buildSwitchStyle(context),
//                 IconButton(
//                     onPressed: () {
//                       showSearchField = true;
//                       setState(() {});

//                       //Utils.toast("使用规则搜索 还没做呢 xx yy ");
//                     },
//                     icon: Icon(Icons.search))
//               ],
//             ),
//       body: _buildViewList(),
//     );
//   }

//   Widget _buildViewList() {
//     List<Widget> children = [];
//     if (showSearchField) {
//       return Container(
//         child: KeepAliveWidget(
//           wantKeepAlive: true,
//           child: _buildBodyView(xitemListDataSearch.first, 0),
//         ),
//       );
//     } else {
//       if (tabController_ != null) {
//         for (var i = 0; i < moreKeys.list.length; i++) {
//           children.add(
//             KeepAliveWidget(
//               wantKeepAlive: true,
//               child: _buildBodyView(xitemListData[i], i),
//             ),
//           );
//         }
//       }
//     }

//     return children.isNotEmpty
//         ? TabBarView(controller: tabController_, children: children)
//         : Container();
//   }

//   Widget _buildBodyView(XitemList items, int index) {
//     if (!_bodyKey.containsKey(index)) _bodyKey[index] = GlobalKey();
//     return StateView(
//       key: _bodyKey[index],
//       builder: (context) {
//         switch (widget.viewStyle) {
//           case 0:
//             return buildDiscoverResultList(items, index);
//           case 1:
//             return buildDiscoverResultList(items, index,
//                 builderItem: (v) => UiSearch2Item(item: v));
//             break;
//           case 2:
//             return buildDiscoverResultGrid(items, index);
//           case 3:
//             return buildDiscoverResultGrid(items, index,
//                 crossAxisCount: 2,
//                 builderItem: (v) => UIDiscoverItem(searchItem: v));
//           case 4:
//             return buildDiscoverResultGrid(items, index,
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.45,
//                 builderItem: (v) => UIDiscoverItem(searchItem: v));
//           default:
//             return buildDiscoverResultGrid(items, index);
//         }
//       },
//     );
//   }

//   Widget buildDiscoverResultGrid(XitemList items, int tabindex,
//       {Widget Function(SearchItem searchItem) builderItem,
//       double childAspectRatio,
//       int crossAxisCount}) {
//     if (showSearchField) {
//       if (items.load && items.discoverItems.length == 0) {
//         return Stack(
//           children: [
//             Center(
//               child: LoadMoreView(
//                 msg: "正在加载...",
//                 color: Colors.red,
//                 timeout: 10000,
//               ),
//             ),
//           ],
//         );
//       }
//     } else {
//       if (items.load && items.discoverItems.length == 0) {
//         return Stack(
//           children: [
//             _buildBanner(moreKeys.list[tabindex], tabindex, 0),
//             Center(
//               child: LoadMoreView(
//                 msg: "正在加载...",
//                 color: Colors.red,
//                 timeout: 10000,
//               ),
//             ),
//           ],
//         );
//       }
//     }

//     final _size = MediaQuery.of(context).size;
//     Widget banner = _buildBanner(moreKeys.list[tabindex], tabindex, 1);

//     // Widget listview = GridView.builder(
//     //   controller: xitemListData[tabindex].scrollController_,
//     //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//     //     crossAxisCount: (_size.width < _size.height
//     //         ? (crossAxisCount ?? 3)
//     //         : ((crossAxisCount ?? 3) * (_size.width / _size.height)).toInt()),
//     //     childAspectRatio: childAspectRatio ?? 0.65,
//     //     mainAxisSpacing: 0,
//     //     crossAxisSpacing: 0,
//     //   ),
//     //   padding: const EdgeInsets.all(6.0),
//     //   itemCount: xitemListData[tabindex].discoverItems.length + 1,
//     //   itemBuilder: (BuildContext context, int index) {
//     //     // if (index == 0) {
//     //     //   return _buildBanner(moreKeys.list[tabindex], tabindex);
//     //     // }
//     //     if (index == xitemListData[tabindex].discoverItems.length) {
//     //       if (xitemListData[tabindex].more)
//     //         return LoadMoreView(
//     //             msg: '加载中...', axis: Axis.vertical, timeout: 20000);
//     //       return Container();
//     //     }
//     //     SearchItem searchItem = xitemListData[tabindex].discoverItems[index];
//     //     if (SearchItemManager.isFavorite(
//     //         searchItem.originTag, searchItem.url)) {
//     //       searchItem = SearchItemManager.searchItem.firstWhere((item) =>
//     //           item.originTag == searchItem.originTag &&
//     //           item.url == searchItem.url);
//     //     }
//     //     return InkWell(
//     //       child: builderItem == null
//     //           ? Padding(
//     //               padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
//     //               child: UIDiscoverItem(searchItem: searchItem),
//     //             )
//     //           : builderItem(searchItem),
//     //       onTap: () => Navigator.of(context).push(
//     //         MaterialPageRoute(
//     //             builder: (context) => ChapterPage(searchItem: searchItem)),
//     //       ),
//     //     );
//     //   },
//     // );

//     Widget _listView = RefreshIndicator(
//       child: CustomScrollView(
//         controller: items.scrollController_,
//         slivers: [
//           banner,
//           SliverGrid(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               childAspectRatio: childAspectRatio ?? 0.65,
//               crossAxisSpacing: 0,
//               mainAxisSpacing: 0,
//               crossAxisCount: (_size.width < _size.height
//                   ? (crossAxisCount ?? 3)
//                   : ((crossAxisCount ?? 3) * (_size.width / _size.height))
//                       .toInt()),
//             ),
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 if (index == items.discoverItems.length) {
//                   if (items.more)
//                     return LoadMoreView(
//                         msg: '加载中...', axis: Axis.vertical, timeout: 20000);
//                   return Container();
//                 }
//                 SearchItem searchItem = items.discoverItems[index];
//                 if (SearchItemManager.isFavorite(
//                     searchItem.originTag, searchItem.url)) {
//                   searchItem = SearchItemManager.searchItem.firstWhere((item) =>
//                       item.originTag == searchItem.originTag &&
//                       item.url == searchItem.url);
//                 }
//                 return InkWell(
//                   child: builderItem == null
//                       ? Padding(
//                           padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
//                           child: UIDiscoverItem(searchItem: searchItem),
//                         )
//                       : builderItem(searchItem),
//                   onTap: () => Navigator.of(context).push(
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             ChapterPage(searchItem: searchItem)),
//                   ),
//                 );
//               },
//               childCount: items.discoverItems.length + 1,
//             ),
//           )
//         ],
//       ),
//       onRefresh: () async => await onRefresh(items),
//     );

//     return Stack(
//       children: [
//         _listView,
//       ],
//     );
//   }

//   Widget buildDiscoverResultList(XitemList items, int tabindex,
//       {Widget Function(SearchItem searchItem) builderItem}) {
//     if (showSearchField) {
//       if (items.load && items.discoverItems.length == 0) {
//         return Stack(
//           children: [
//             Center(
//               child: LoadMoreView(
//                 msg: "正在加载...",
//                 color: Colors.red,
//                 timeout: 10000,
//               ),
//             ),
//           ],
//         );
//       }
//     } else {
//       if (items.load && items.discoverItems.length == 0) {
//         return Stack(
//           children: [
//             _buildBanner(moreKeys.list[tabindex], tabindex, 0),
//             Center(
//               child: LoadMoreView(
//                 msg: "正在加载...",
//                 color: Colors.red,
//                 timeout: 10000,
//               ),
//             ),
//           ],
//         );
//       }
//     }

//     // Widget _listView = RefreshIndicator(
//     //   child: ListView.builder(
//     //     controller: xitemListData[tabindex].scrollController_,
//     //     itemCount: xitemListData[tabindex].discoverItems.length + 1,
//     //     itemBuilder: (BuildContext context, int index) {
//     //       if (index == 0) {
//     //         //return Container();
//     //         return _buildBanner(moreKeys.list[tabindex], tabindex, 0);
//     //       }
//     //       if (index == xitemListData[tabindex].discoverItems.length) {
//     //         if (xitemListData[tabindex].more)
//     //           return LoadMoreView(msg: "正在加载...");
//     //         return Container();
//     //       }
//     //       SearchItem searchItem = xitemListData[tabindex].discoverItems[index];
//     //       if (SearchItemManager.isFavorite(
//     //           searchItem.originTag, searchItem.url)) {
//     //         searchItem = SearchItemManager.searchItem.firstWhere((item) =>
//     //             item.url == searchItem.url &&
//     //             item.originTag == searchItem.originTag);
//     //       }
//     //       return InkWell(
//     //         child: builderItem != null
//     //             ? builderItem(searchItem)
//     //             : UiSearchItem(item: searchItem),
//     //         onTap: () => Navigator.of(context).push(
//     //           MaterialPageRoute(
//     //               builder: (context) => ChapterPage(searchItem: searchItem)),
//     //         ),
//     //       );
//     //     },
//     //   ),
//     //   onRefresh: () async => await onRefresh(tabindex),
//     // );
//     Widget banner = _buildBanner(moreKeys.list[tabindex], tabindex, 1);
//     Widget listview = SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           //print("index:$index");
//           if (index == items.discoverItems.length) {
//             print("items.more:${items.more}");
//             //return LoadMoreView(msg: "正在加载...");
//             if (items.more) return LoadMoreView(msg: "正在加载...");
//             return Container();
//           }
//           SearchItem searchItem = items.discoverItems[index];
//           if (SearchItemManager.isFavorite(
//               searchItem.originTag, searchItem.url)) {
//             searchItem = SearchItemManager.searchItem.firstWhere((item) =>
//                 item.url == searchItem.url &&
//                 item.originTag == searchItem.originTag);
//           }
//           return InkWell(
//             child: builderItem != null
//                 ? builderItem(searchItem)
//                 : UiSearchItem(item: searchItem),
//             onTap: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                   builder: (context) => ChapterPage(searchItem: searchItem)),
//             ),
//           );
//         },
//         childCount: items.discoverItems.length + 1,
//       ),
//     );
//     List<Widget> list = [];
//     if (showSearchField) {
//       list = [
//         listview,
//       ];
//     } else {
//       list = [
//         banner,
//         listview,
//       ];
//     }

//     Widget _listView = RefreshIndicator(
//       child: CustomScrollView(
//         controller: items.scrollController_,
//         // itemCount: xitemListData[tabindex].discoverItems.length + 1,
//         slivers: list,
//       ),
//       onRefresh: () async => await onRefresh(items),
//     );

//     return Stack(
//       children: [
//         _listView,
//       ],
//     );
//   }

//   // Widget buildDiscoverResultList(int tabindex,
//   //     {Widget Function(SearchItem searchItem) builderItem}) {
//   //   return RefreshIndicator(
//   //     child: Stack(
//   //       children: [
//   //         if (xitemListData[tabindex].load) LandingPage(),
//   //         ListView.builder(
//   //           scrollDirection: Axis.vertical,
//   //           controller: xitemListData[tabindex].scrollController_,
//   //           itemCount: xitemListData[tabindex].discoverItems.length + 1,
//   //           itemBuilder: (context, index) {
//   //             if (index == 0) {
//   //               return _buildBanner(moreKeys.list[index], index);
//   //             }
//   //             if (index == xitemListData[tabindex].discoverItems.length) {
//   //               if (xitemListData[tabindex].more) {
//   //                 return LoadMoreView(msg: "正在加载...");
//   //               }
//   //             }
//   //             return InkWell(
//   //                 onTap: () => Utils.startPageWait(
//   //                     context,
//   //                     ChapterPage(
//   //                       searchItem:
//   //                           xitemListData[tabindex].discoverItems[index - 1],
//   //                     )),
//   //                 child: builderItem != null
//   //                     ? builderItem(
//   //                         xitemListData[tabindex].discoverItems[index - 1])
//   //                     : UiSearchItem(
//   //                         item: xitemListData[tabindex]
//   //                             .discoverItems[index - 1]));
//   //           },
//   //         ),
//   //       ],
//   //     ),
//   //     onRefresh: () async => await onRefresh(tabindex),
//   //   );
//   // }

//   bool iswrap = true;
//   Widget _buildBanner(ListFilters listfilters, int index, int type) {
//     if (moreKeys == null) return Container();

//     final nomal = TextStyle(
//       color: Colors.black,
//       fontSize: 13,
//       fontWeight: FontWeight.normal,
//     );
//     final primary = TextStyle(
//         color: Colors.orange[900], fontSize: 13, fontWeight: FontWeight.w900);

//     final nomalButton = ButtonStyle(
//       backgroundColor: MaterialStateProperty.all(const Color(0x00000000)),
//       padding: MaterialStateProperty.all(
//         const EdgeInsets.only(
//           right: 8,
//           left: 8,
//         ),
//       ),
//       minimumSize: MaterialStateProperty.all(const Size(45, 10)),
//       shape: MaterialStateProperty.all(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5),
//         ),
//       ),
//     );

//     final primaryButton = ButtonStyle(
//       padding: MaterialStateProperty.all(
//         const EdgeInsets.only(
//           right: 8,
//           left: 8,
//         ),
//       ),
//       minimumSize: MaterialStateProperty.all(const Size(45, 25)),
//       backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
//       shape: MaterialStateProperty.all(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5),
//         ),
//       ),
//     );
//     Widget _getlist(rule) => iswrap
//         ? Wrap(runSpacing: Platform.isWindows ? 13 : -8, children: [
//             for (var i = 0; i < rule.items.length; i++)
//               TextButton(
//                 style: rule.value == rule.items[i].value
//                     ? primaryButton
//                     : nomalButton,
//                 onPressed: () {
//                   rule.value = rule.items[i].value;
//                   xitemListData[index].load = true;
//                   xitemListData[index].discoverItems.clear();
//                   parseRule(listfilters, xitemListData[index], true, true, 1);
//                 },
//                 child: Text(
//                   rule.items[i].title,
//                   style: rule.value == rule.items[i].value ? primary : nomal,
//                 ),
//               ),
//             SizedBox(
//               height: Platform.isWindows ? 30 : 0,
//             )
//           ])
//         : ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: rule.items.length,
//             itemBuilder: (BuildContext context, int index_) {
//               final option = rule.items[index_];
//               return TextButton(
//                 style: rule.value == option.value ? primaryButton : nomalButton,
//                 onPressed: () {
//                   rule.value = option.value;
//                   parseRule(listfilters, xitemListData[index], true, true, 1);
//                 },
//                 child: Text(
//                   option.title,
//                   style: rule.value == option.value ? primary : nomal,
//                 ),
//               );
//             },
//           );

//     Widget _banner = Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: Platform.isWindows ? 10 : 0,
//         ),
//         for (var rule in listfilters.requestFilters)
//           SizedBox(
//             height: iswrap ? null : 35,
//             child: _getlist(rule),
//           ),
//       ],
//     );

//     return type == 0
//         ? Container(child: _banner)
//         : SliverToBoxAdapter(child: _banner);
//   }

//   // Widget _buildStickyBar() {
//   //   if (_discoverRule == null)
//   //     return SliverToBoxAdapter(child: Text("加载结果中。。。"));
//   //   return SliverPersistentHeader(
//   //     pinned: true, //是否固定在顶部
//   //     floating: true,
//   //     delegate: _SliverAppBarDelegate(
//   //       minHeight: 35, //收起的高度
//   //       maxHeight: 40, //展开的最大高度
//   //       child: ListView(
//   //         scrollDirection: Axis.horizontal,
//   //         children: [
//   //           for (var rule in _discoverRule.rules
//   //               .where((element) => element.option.isNotEmpty))
//   //             Card(
//   //               child: Center(
//   //                 child: Text(
//   //                   " ${rule.name} : ${rule.option} ",
//   //                 ),
//   //               ),
//   //             )
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate({
//     @required this.minHeight,
//     @required this.maxHeight,
//     @required this.child,
//   });

//   final double minHeight;
//   final double maxHeight;
//   final Widget child;

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return SizedBox.expand(child: child);
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }
