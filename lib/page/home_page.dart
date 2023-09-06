import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/page/history_page.dart';
import 'package:eso/page/search_page.dart';
import 'package:eso/page/setting/about_page.dart';
import 'package:eso/ui/ui_audio_view.dart';
import 'package:eso/ui/widgets/animation_rotate_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import '../main.dart';
import '../model/page_switch.dart';
import '../eso_theme.dart';
import '../utils.dart';
import 'discover_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLargeScreen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 播放下一个收藏
  // void playNextAudio(SearchItem lastItem, [bool reNext]) async {
  //   final _searchList = SearchItemManager.getSearchItemByType(API.AUDIO, SortType.CREATE);
  //   if (_searchList == null || _searchList.isEmpty) return;
  //   var index = _searchList.indexOf(lastItem) + 1;
  //   if (index < 0) index = 0;
  //   if (index >= _searchList.length) {
  //     if (reNext == true) return;
  //     index = 0;
  //   }
  //   final item = _searchList[index];
  //   if (item.chapters.isEmpty) {
  //     // if (SearchItemManager.isFavorite(item.originTag, item.url))
  //     //   item.chapters = SearchItemManager.getChapter(item.id);
  //     if (item.chapters.isEmpty) {
  //       // 如果还是为空，则尝试加载下一个
  //       playNextAudio(item, true);
  //       return;
  //     }
  //   }
  //   AudioService().playChapter(0, searchItem: item);
  // }

  @override
  Widget build(BuildContext context) {
    final profile = ESOTheme();
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }
      return ChangeNotifierProvider(
        create: (BuildContext context) => PageSwitch(Global.currentHomePage),
        child: Consumer<PageSwitch>(
          builder: (BuildContext context, PageSwitch pageSwitch, Widget widget) {
            Global.currentHomePage = pageSwitch.currentIndex;
            pageSwitch.updatePageController();
            final _pageView = PageView(
              controller: pageSwitch.pageController,
              children: <Widget>[
                FavoritePage(),
                DiscoverPage(),
                if (isLargeScreen || profile.bottomCount == 4) HistoryPage(),
                if (isLargeScreen || profile.bottomCount == 4) AboutPage(),
              ],
              onPageChanged: (index) => pageSwitch.changePage(index, false),
              physics: NeverScrollableScrollPhysics(), //禁止主页左右滑动
            );
            return Container(
              // decoration: globalDecoration,
              color: Theme.of(context).canvasColor,
              child: Scaffold(
                body: Stack(
                  children: [
                    _pageView,
                    AudioView(),
                    // StatefulBuilder(builder: (context, state) {
                    //   return _buildAudioView(context);
                    // }),
                  ],
                ),
                bottomNavigationBar: BottomAppBar(
                  // color: Theme.of(context).canvasColor,
                  shape: CircularNotchedRectangle(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => pageSwitch.changePage(0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(FIcons.heart,
                                          color: getColor(pageSwitch, context, 0)),
                                      Text("收藏",
                                          style: TextStyle(
                                              color: getColor(pageSwitch, context, 0)))
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => pageSwitch.changePage(1),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(FIcons.compass,
                                          color: getColor(pageSwitch, context, 1)),
                                      Text("发现",
                                          style: TextStyle(
                                              color: getColor(pageSwitch, context, 1)))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (ESOTheme().searchPostion == ESOTheme.searchDocker &&
                            (isLargeScreen || ESOTheme().bottomCount == 4))
                          Spacer(),
                        if (isLargeScreen || ESOTheme().bottomCount == 4)
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => pageSwitch.changePage(2),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.history,
                                            color: getColor(pageSwitch, context, 2)),
                                        Text("历史",
                                            style: TextStyle(
                                                color: getColor(pageSwitch, context, 2)))
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => pageSwitch.changePage(3),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.info_outline_rounded,
                                            color: getColor(pageSwitch, context, 3)),
                                        Text("关于",
                                            style: TextStyle(
                                                color: getColor(pageSwitch, context, 3)))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                floatingActionButton: profile.searchPostion == ESOTheme.searchAction
                    ? null
                    : FloatingActionButton(
                        elevation: 1,
                        tooltip: "搜索",
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: () => Utils.startPageWait(context, SearchPage())
                            .whenComplete(() => pageSwitch.refreshList()),
                        child: Icon(FIcons.search, color: Theme.of(context).canvasColor),
                      ),
                floatingActionButtonLocation:
                    profile.searchPostion == ESOTheme.searchAction
                        ? null
                        : profile.searchPostion == ESOTheme.searchFloat
                            ? FloatingActionButtonLocation.endFloat
                            : FloatingActionButtonLocation.centerDocked,
              ),
            );
          },
        ),
      );
    });
  }

  Color getColor(PageSwitch pageSwitch, BuildContext context, int value) {
    return pageSwitch.currentIndex == value
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyText1.color;
  }

  // Widget _buildAudioView(BuildContext context) {
  //   if (!AudioService.isPlaying) return SizedBox();
  //   final chapter = AudioService().curChapter;
  //   final Widget _view = Container(
  //     width: 40,
  //     height: 40,
  //     decoration: BoxDecoration(
  //         color: Theme.of(context).primaryColor.withOpacity(0.2),
  //         borderRadius: BorderRadius.circular(50),
  //         border: Border.all(
  //             color: Theme.of(context).primaryColorLight.withOpacity(0.8), width: 0.5)),
  //     child: AnimationRotateView(
  //       child: Container(
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           image: Utils.empty(chapter?.cover)
  //               ? null
  //               : DecorationImage(
  //                   image: NetworkImage(chapter.cover ?? ''),
  //                   fit: BoxFit.cover,
  //                 ),
  //         ),
  //         child: Utils.empty(chapter?.cover)
  //             ? Icon(Icons.audiotrack, color: Colors.black12, size: 24)
  //             : Container(
  //                 width: 8,
  //                 height: 8,
  //                 decoration: BoxDecoration(
  //                     color: Theme.of(context).canvasColor,
  //                     borderRadius: BorderRadius.circular(8),
  //                     border: Border.all(
  //                         color: Theme.of(context).primaryColorLight.withOpacity(0.8),
  //                         width: 0.35)),
  //               ),
  //       ),
  //     ),
  //   );
  //   return Positioned(
  //     right: 16,
  //     bottom: MediaQuery.of(context).padding.bottom + 16,
  //     child: InkWell(
  //       child: chapter != null
  //           ? Tooltip(
  //               child: _view,
  //               message: '正在播放: ' + chapter.name ?? '',
  //             )
  //           : _view,
  //       onTap: chapter == null
  //           ? null
  //           : () {
  //               Utils.startPageWait(
  //                   context, AudioPage(searchItem: AudioService().searchItem));
  //             },
  //     ),
  //   );
  // }
}
