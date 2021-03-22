// import 'dart:ui';

// import 'package:eso/database/search_item.dart';
// import 'package:eso/global.dart';
// import 'package:eso/model/novel_page_provider.dart';
// import 'package:eso/profile.dart';
// import 'package:eso/page/langding_page.dart';
// import 'package:eso/ui/ui_chapter_select.dart';
// import 'package:eso/ui/ui_novel_menu.dart';
// import 'package:eso/utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:text_composition/text_composition.dart';

// /// 文字阅读页面
// class NovelPage extends StatefulWidget {
//   final SearchItem searchItem;
//   const NovelPage({this.searchItem, Key key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _NovelPageState();
// }

// class _NovelPageState extends State<NovelPage> {

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profile = Provider.of<Profile>(context, listen: false);
//     return Container();
//     // return ChangeNotifierProvider<NovelPageProvider>(
//     //   create: (BuildContext context) => NovelPageProvider(
//     //     searchItem: widget.searchItem,
//     //     keepOn: profile.novelKeepOn,
//     //     profile: profile,
//     //   ),
//     //   builder: (context, child) => Scaffold(
//     //     body: Consumer2<NovelPageProvider, Profile>(
//     //       builder:
//     //           (BuildContext context, NovelPageProvider provider, Profile profile, _) {
//     //         if (provider.paragraphs == null) {
//     //           return LandingPage();
//     //         }
//     //         updateSystemChrome(provider.showMenu, profile);
//     //         final size = MediaQuery.of(context).size;
//     //         if (provider.didUpdateReadSetting(profile, size))
//     //           provider.buildTextComposition(profile);
//     //         return Stack(
//     //           children: <Widget>[
//     //             AnnotatedRegion<SystemUiOverlayStyle>(
//     //               value: Global.novelLightOrDark(),
//     //               child: Container(
//     //                 decoration: Utils.getNovelBackground(),
//     //                 child: TCPage(provider.textComposition),
//     //               ),
//     //             ),
//     //             if (provider.showChapter || provider.showMenu || provider.showSetting)
//     //               WillPopScope(
//     //                 onWillPop: () async {
//     //                   provider.showChapter = false;
//     //                   provider.showSetting = false;
//     //                   provider.showMenu = false;
//     //                   return false;
//     //                 },
//     //                 child: SizedBox(),
//     //               ),
//     //             if (provider.showMenu)
//     //               UINovelMenu(searchItem: widget.searchItem, profile: profile),
//     //             if (provider.showChapter)
//     //               UIChapterSelect(
//     //                 searchItem: widget.searchItem,
//     //                 loadChapter: provider.loadChapter,
//     //               ),
//     //             if (provider.isLoading)
//     //               Opacity(
//     //                 opacity: 0.8,
//     //                 child: Center(
//     //                   child: Container(
//     //                     decoration: BoxDecoration(
//     //                       borderRadius: BorderRadius.circular(20),
//     //                       color: Theme.of(context).canvasColor,
//     //                     ),
//     //                     padding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
//     //                     child: Column(
//     //                       mainAxisSize: MainAxisSize.min,
//     //                       children: [
//     //                         CupertinoActivityIndicator(),
//     //                         SizedBox(height: 20),
//     //                         Text(
//     //                           "加载中...",
//     //                           style: TextStyle(fontSize: 20),
//     //                         ),
//     //                       ],
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ),
//     //           ],
//     //         );
//     //       },
//     //     ),
//     //   ),
//     // );
//   }

//   bool lastShowMenu;

//   updateSystemChrome(bool showMenu, Profile profile) {
//     if (showMenu == lastShowMenu) return;
//     lastShowMenu = showMenu;
//     if (showMenu) {
//       SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//     } else if (!profile.showNovelStatus) {
//       SystemChrome.setEnabledSystemUIOverlays([]);
//     }
//   }
// }
