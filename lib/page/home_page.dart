// import 'dart:convert';

// import 'package:eso/api/api.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/model/audio_service_handler.dart';
// import 'package:eso/page/audio_page.dart';
// import 'package:eso/page/audio_view.dart';
// import 'package:eso/page/fast_cats.dart';
// import 'package:eso/page/history_page.dart';
// import 'package:eso/page/search_page.dart';
// import 'package:eso/page/setting/about_page.dart';
// import 'package:eso/page/testListView.dart';
// import 'package:eso/ui/widgets/animation_rotate_view.dart';
// import 'package:eso/ui/widgets/icon_text.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// import '../fonticons_icons.dart';
// import '../global.dart';
// import '../model/page_switch.dart';
// import '../profile.dart';
// import '../utils.dart';
// import 'discover_page.dart';
// import 'favorite_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   var isLargeScreen = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // 播放下一个收藏
//   void playNextAudio(SearchItem lastItem, [bool reNext]) async {
//     final _searchList =
//         SearchItemManager.getSearchItemByType(API.AUDIO, SortType.CREATE);
//     if (_searchList == null || _searchList.isEmpty) return;
//     var index = _searchList.indexOf(lastItem) + 1;
//     if (index < 0) index = 0;
//     if (index >= _searchList.length) {
//       if (reNext == true) return;
//       index = 0;
//     }
//     final item = _searchList[index];
//     if (item.chapters.isEmpty) {
//       if (SearchItemManager.isFavorite(item.originTag, item.url))
//         item.chapters = SearchItemManager.getChapter(item.id);
//       if (item.chapters.isEmpty) {
//         // 如果还是为空，则尝试加载下一个
//         playNextAudio(item, true);
//         return;
//       }
//     }

//     // AudioService().playChapter(0, searchItem: item);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profile = Profile();
//     return OrientationBuilder(builder: (context, orientation) {
//       if (MediaQuery.of(context).size.width > 600) {
//         isLargeScreen = true;
//       } else {
//         isLargeScreen = false;
//       }
//       return ChangeNotifierProvider(
//         create: (BuildContext context) => PageSwitch(Global.currentHomePage),
//         child: Consumer<PageSwitch>(
//           builder:
//               (BuildContext context, PageSwitch pageSwitch, Widget widget) {
//             Global.currentHomePage = pageSwitch.currentIndex;
//             pageSwitch.updatePageController();
//             final _pageView = PageView(
//               controller: pageSwitch.pageController,
//               children: <Widget>[
//                 FavoritePage(),
//                 DiscoverPage(),
//                 if (isLargeScreen || profile.bottomCount == 4) HistoryPage(),
//                 if (isLargeScreen || profile.bottomCount == 4) AboutPage(),
//               ],
//               onPageChanged: (index) => pageSwitch.changePage(index, false),
//               physics: NeverScrollableScrollPhysics(), //禁止主页左右滑动
//             );
//             return Scaffold(
//               body: Stack(
//                 children: [
//                   _pageView,
//                   // Positioned(
//                   //   left: 50,
//                   //   bottom: 100,
//                   //   child: TextButton(
//                   //     onPressed: () {
//                   //       Navigator.push(
//                   //           context,
//                   //           CupertinoPageRoute(
//                   //             builder: (context) => testListView(),
//                   //           ));
//                   //     },
//                   //     child: Text("测试列表"),
//                   //   ),
//                   // ),
//                   StatefulBuilder(builder: (context, state) {
//                     return AudioView(context: context);
//                   }),
//                 ],
//               ),
//               bottomNavigationBar: Consumer<Profile>(
//                 builder:
//                     (BuildContext context, Profile profile, Widget widget) {
//                   final _textTheme = Theme.of(context).textTheme;

//                   //bool isDark = Theme.of(context).brightness == Brightness.dark;
//                   return BottomAppBar(
//                     color: Theme.of(context).canvasColor,
//                     // color: Colors.white.withOpacity(0.9),

//                     shape: CircularNotchedRectangle(),
//                     // elevation: 5,
//                     child: Padding(
//                       padding: EdgeInsets.only(bottom: 10, top: 10),
//                       child: Row(
//                         children: <Widget>[
//                           Expanded(
//                             flex: 3,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     // highlightColor: Colors.transparent,
//                                     // radius: 0.0,
//                                     onTap: () => pageSwitch.changePage(0),
//                                     child: IconText(
//                                       "收藏",
//                                       icon: Icon(CupertinoIcons.heart),
//                                       iconSize: 20,
//                                       direction: Axis.vertical,
//                                       style: _textTheme
//                                           .copyWith(
//                                               bodyText1: TextStyle(
//                                             fontSize: 12,
//                                             color: getColor(
//                                                 pageSwitch, context, 0),
//                                           ))
//                                           .bodyText1,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     // highlightColor: Colors.transparent,
//                                     // radius: 0.0,
//                                     onTap: () => pageSwitch.changePage(1),
//                                     child: IconText(
//                                       "发现",
//                                       icon: Icon(CupertinoIcons.compass),
//                                       direction: Axis.vertical,
//                                       iconSize: 20,
//                                       style: _textTheme
//                                           .copyWith(
//                                               bodyText1: TextStyle(
//                                             color: getColor(
//                                                 pageSwitch, context, 1),
//                                           ))
//                                           .bodyText1,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (profile.searchPostion == Profile.searchDocker &&
//                               (isLargeScreen || profile.bottomCount == 4))
//                             Spacer(),
//                           if (isLargeScreen || profile.bottomCount == 4)
//                             Expanded(
//                               flex: 3,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       // highlightColor: Colors.transparent,
//                                       // radius: 0.0,
//                                       onTap: () => pageSwitch.changePage(2),
//                                       child: IconText(
//                                         "历史",
//                                         icon: Icon(CupertinoIcons.paperplane),
//                                         iconSize: 20,
//                                         direction: Axis.vertical,
//                                         style: _textTheme
//                                             .copyWith(
//                                                 bodyText1: TextStyle(
//                                               color: getColor(
//                                                   pageSwitch, context, 2),
//                                             ))
//                                             .bodyText1,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: GestureDetector(
//                                       // highlightColor: Colors.transparent,
//                                       // radius: 0.0,
//                                       onTap: () => pageSwitch.changePage(3),
//                                       child: IconText(
//                                         "关于",
//                                         icon: Icon(CupertinoIcons.gear),
//                                         direction: Axis.vertical,
//                                         iconSize: 20,
//                                         style: _textTheme
//                                             .copyWith(
//                                                 bodyText1: TextStyle(
//                                               color: getColor(
//                                                   pageSwitch, context, 3),
//                                             ))
//                                             .bodyText1,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               floatingActionButton:
//                   profile.searchPostion == Profile.searchAction
//                       ? null
//                       : FloatingActionButton(
//                           elevation: 1,
//                           tooltip: "搜索",
//                           backgroundColor: Theme.of(context).primaryColor,
//                           onPressed: () =>
//                               Utils.startPageWait(context, SearchPage())
//                                   .whenComplete(() => pageSwitch.refreshList()),
//                           child: Icon(FIcons.search,
//                               color: Theme.of(context).canvasColor),
//                         ),
//               floatingActionButtonLocation:
//                   profile.searchPostion == Profile.searchAction
//                       ? null
//                       : profile.searchPostion == Profile.searchFloat
//                           ? FloatingActionButtonLocation.endFloat
//                           : FloatingActionButtonLocation.centerDocked,
//             );
//           },
//         ),
//       );
//     });
//   }

//   Color getColor(PageSwitch pageSwitch, BuildContext context, int value) {
//     return pageSwitch.currentIndex == value
//         ? Theme.of(context).primaryColor
//         : Theme.of(context).textTheme.bodyText1.color;
//   }
// }
