import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dlna/dlna.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/menu/menu_item.dart';
import 'package:eso/menu/menu_desktop.dart';
import 'package:eso/menu/menu_videoPlayer.dart';
import 'package:eso/model/audio_page_controller.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/page/chapter_page.dart';
import 'package:eso/page/source/editor/highlight_code_editor_theme.dart';
import 'package:eso/ui/raw_keyboard_event.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:eso/utils/size_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:wakelock/wakelock.dart';
import 'package:dart_vlc/dart_vlc.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../global.dart';

import '../utils.dart';
import '../utils/dlna_util.dart';
import 'content_page_manager.dart';

List<ChapterRoad> _parseChapers(
    List<ChapterItem> chapters, int durChapterIndex) {
  //currentRoad = 0;
  final roads = <ChapterRoad>[];
  if (chapters.isEmpty || !chapters.first.name.startsWith('@线路')) return roads;
  var roadName = chapters.first.name.substring(3);
  var startIndex = 1;
  for (var i = 1, len = chapters.length; i < len; i++) {
    if (chapters[i].name.startsWith('@线路')) {
      if (durChapterIndex >= startIndex && durChapterIndex < i) {
        //currentRoad = roads.length;
      }
      // 上一个线路
      roads.add(ChapterRoad(roadName, startIndex, i - startIndex));
      roadName = chapters[i].name.substring(3);
      startIndex = i + 1;
    }
  }
  // 最后一个线路
  roads.add(ChapterRoad(roadName, startIndex, chapters.length - startIndex));
  return roads;
}

class VideoPageDesktop extends StatelessWidget {
  final SearchItem searchItem;
  const VideoPageDesktop({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //       "${searchItem.name} - ${searchItem.durChapter} - ${searchItem.origin}"),
        // ),
        backgroundColor: Colors.black,
        body: ChangeNotifierProvider<VideoPageProvider>(
          create: (context) => VideoPageProvider(
              searchItem: searchItem, contentProvider: contentProvider),
          builder: (BuildContext context, child) {
            final provider =
                Provider.of<VideoPageProvider>(context, listen: false);
            final isLoading = context
                .select((VideoPageProvider provider) => provider.isLoading);
            final showController = context.select(
                (VideoPageProvider provider) => provider.showController);
            final hint =
                context.select((VideoPageProvider provider) => provider.hint);
            final showChapter = context
                .select((VideoPageProvider provider) => provider.showChapter);
            final islpSpeed = context
                .select((VideoPageProvider provider) => provider.islpSpeed);
            final currentRoad = context
                .select((VideoPageProvider provider) => provider.currentRoad);
            final refreshFav = context
                .select((VideoPageProvider provider) => provider.refreshFav);
            bool darkMode = Utils.isDarkMode(context);
            final roads = _parseChapers(
                searchItem.chapters, provider.searchItem.durChapterIndex);
            final nomalText = TextStyle(color: Colors.black);
            final primaryText = TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
            );
            final vertical = context.select((VideoPageProvider provider) =>
                provider.screenAxis == Axis.vertical);

            Widget playWidget = Stack(
              children: [
                _buildPlayer(!isLoading, context),
                if (isLoading)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: _buildLoading(context),
                    ),
                  ),
                if (islpSpeed)
                  Positioned(
                    left: 30,
                    top: 100,
                    width: 100,
                    child: Container(
                      width: 0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: IconText(
                        "2X快进中",
                        iconSize: 20,
                        icon: Icon(
                          Icons.fast_forward_rounded,
                          //size: 20,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                if (isLoading)
                  Positioned(
                    left: 30,
                    bottom: 30,
                    right: 30,
                    child: _buildLoadingText(context),
                  ),
                if (showController)
                  Container(
                    // margin: EdgeInsets.only(
                    //     top: MediaQuery.of(context).padding.top),
                    padding: EdgeInsets.fromLTRB(
                        10,
                        vertical ? 10 : MediaQuery.of(context).padding.top + 10,
                        10,
                        vertical ? 10 : MediaQuery.of(context).padding.top),
                    color: Color(0x20000000),
                    child: _buildTopBar(context),
                  ),
                if (showController)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: vertical ? 100 : 120,
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      color: Color(0x20000000),
                      child: _buildBottomBar(context),
                    ),
                  ),
                if (showChapter)
                  UIChapterSelect(
                    loadChapter: (index) => provider.loadChapter(index),
                    searchItem: searchItem,
                    color: Colors.black45,
                    fontColor: Colors.white70,
                    border: BorderSide(
                        color: Colors.white12, width: Global.borderSize),
                    heightScale: 0.6,
                  ),
                if (hint != null)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0x20000000),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: hint,
                    ),
                  ),
              ],
            );
            // bool darkMode = Utils.isDarkMode(context);

            Widget playRoad(item) => Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 5.0,
                        children: [
                          for (var i = 0; i < item.length; i++)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                side: BorderSide(
                                    width: 0.5, color: Colors.purple),
                              ),
                              onPressed: () =>
                                  provider.loadChapter(item.startIndex + i),
                              child: Text(
                                  searchItem.chapters[item.startIndex + i].name,
                                  style: searchItem.durChapterIndex ==
                                          item.startIndex + i
                                      ? primaryText
                                      : nomalText),
                            )

                          //item.length
                        ],
                      )
                    ],
                  ),
                );

            List<Widget> buildRoads = roads.isEmpty
                ? [playRoad(ChapterRoad("默认线路", 0, searchItem.chapters.length))]
                : roads.map((e) => playRoad(e)).toList();

            final _textTheme = Theme.of(context).textTheme;

            Widget playList = Expanded(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          trailing: InkWell(
                              child: Text("简介 >"),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: double.infinity,
                                      // height:
                                      //     (MediaQuery.of(context).size.height /
                                      //             2) +
                                      //         100,
                                      child: ListTile(
                                        title: Text(searchItem.name),
                                        subtitle: Text(
                                            "${searchItem.author}\n${searchItem.tags.join()}\n${searchItem.description}"),
                                      ),
                                    );
                                  },
                                );
                              }),
                          subtitle: Text(searchItem.tags.join()),
                          title: Text(
                            searchItem.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  provider.toggleFavorite();
                                },
                                child: IconText(
                                  "收藏",
                                  direction: Axis.vertical,
                                  style: _textTheme.bodyText1,
                                  icon: SearchItemManager.isFavorite(
                                          searchItem.originTag, searchItem.url)
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        )
                                      : Icon(
                                          Icons.favorite_border,
                                          //color: Colors.black,
                                        ),
                                  iconSize: 25,
                                ),
                              ),
                              InkWell(
                                child: IconText(
                                  "切换线路",
                                  direction: Axis.vertical,
                                  style: _textTheme.bodyText1,
                                  icon: Icon(
                                    Icons.timeline,
                                    //color: _iconTheme.color,
                                  ),
                                  iconSize: 25,
                                ),
                                onTap: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (_) => CupertinoActionSheet(
                                      title: Text("请选择播放线路"),
                                      actions: List.generate(
                                        roads.length,
                                        (index) {
                                          final quality = roads[index];
                                          return CupertinoActionSheetAction(
                                            child: Text(
                                              "${quality.name} (${quality.length})",
                                              style: TextStyle(
                                                  color: currentRoad == index
                                                      ? Colors.red
                                                      : null,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                            onPressed: () {
                                              if (index != currentRoad) {
                                                final cur = roads[currentRoad];
                                                final to = roads[index];
                                                final curIndex =
                                                    searchItem.durChapterIndex -
                                                        cur.startIndex;
                                                int toRoad =
                                                    to.startIndex + curIndex;

                                                if (curIndex >
                                                    (to.length - 1)) {
                                                  toRoad = to.startIndex +
                                                      to.length -
                                                      1;

                                                  Utils.toast(
                                                      "当前线路与上条线路不匹配,已切换到当前最新剧集");
                                                  // Navigator.pop(_);
                                                  // return;
                                                }

                                                // print(
                                                //     "${to.startIndex + curIndex}");
                                                // print(
                                                //     "cur:${cur.startIndex},to:${to.startIndex},curIndex:${curIndex},durindex:${searchItem.durChapterIndex}");

                                                provider.chapterRoad = to;

                                                provider.toggleRoad(
                                                    index, toRoad);
                                              }
                                              // roads[index].length

                                              Navigator.pop(_);
                                              //provider.changeSpeed(quality);
                                            },
                                          );
                                        },
                                      ),
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () => Navigator.pop(_),
                                        child: Text("返回"),
                                        isDestructiveAction: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  List<double> _speeds = [
                                    0.25,
                                    0.5,
                                    1.0,
                                    1.25,
                                    1.5,
                                    1.75,
                                    2.0,
                                    3.0,
                                  ];

                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (_) => CupertinoActionSheet(
                                      title: Text("请选择播放速度"),
                                      actions: List.generate(
                                        _speeds.length,
                                        (index) {
                                          final quality = _speeds[index];
                                          return CupertinoActionSheetAction(
                                            child: Text(
                                              "${quality}X",
                                              style: TextStyle(
                                                  color: provider.playSpeed ==
                                                          quality
                                                      ? Colors.red
                                                      : null,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                            onPressed: () {
                                              provider.changeSpeed(quality);
                                              Navigator.pop(_);
                                              //provider.changeSpeed(quality);
                                            },
                                          );
                                        },
                                      ),
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () => Navigator.pop(_),
                                        child: Text("返回"),
                                        isDestructiveAction: true,
                                      ),
                                    ),
                                  );
                                },
                                child: IconText(
                                  "倍速播放",
                                  direction: Axis.vertical,
                                  style: _textTheme.bodyText1,
                                  icon: Icon(
                                    Icons.speed_sharp,
                                    //color: Colors.black,
                                  ),
                                  iconSize: 25,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Utils.toast("没写");
                                },
                                child: IconText(
                                  "分享",
                                  direction: Axis.vertical,
                                  style: _textTheme.bodyText1,
                                  iconSize: 25,
                                  icon: Icon(Icons.share),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "剧集",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Text("全部剧集"),
                                              trailing: InkWell(
                                                onTap: () =>
                                                    Navigator.pop(context),
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                              child: GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 3,
                                                ),
                                                itemCount: roads.isEmpty
                                                    ? searchItem.chapters.length
                                                    : roads[currentRoad].length,
                                                itemBuilder: (context, index) {
                                                  return ActionChip(
                                                    labelPadding:
                                                        EdgeInsets.only(
                                                      left: 50,
                                                      right: 50,
                                                      top: 5,
                                                      bottom: 5,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1.0),
                                                    ),
                                                    backgroundColor: searchItem
                                                                .durChapterIndex ==
                                                            (roads.isEmpty
                                                                ? index
                                                                : roads[currentRoad]
                                                                        .startIndex +
                                                                    index)
                                                        ? Colors
                                                            .deepOrangeAccent
                                                            .withOpacity(0.1)
                                                        : Colors.grey
                                                            .withOpacity(0.05),
                                                    label: Text(
                                                      searchItem
                                                          .chapters[roads
                                                                  .isEmpty
                                                              ? index
                                                              : roads[currentRoad]
                                                                      .startIndex +
                                                                  index]
                                                          .name,
                                                      style: searchItem
                                                                  .durChapterIndex ==
                                                              (roads.isEmpty
                                                                  ? index
                                                                  : roads[currentRoad]
                                                                          .startIndex +
                                                                      index)
                                                          ? TextStyle(
                                                              color: Colors
                                                                  .deepOrange,
                                                            )
                                                          : null,
                                                    ),
                                                    onPressed: () {
                                                      provider.loadChapter(
                                                        roads.isEmpty
                                                            ? index
                                                            : roads[currentRoad]
                                                                    .startIndex +
                                                                index,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                    "${roads.isEmpty ? "默认线路" : roads[currentRoad].name} 更至${roads.isEmpty ? searchItem.chapters.length : roads[currentRoad].length}集>"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 15),
                      child: Container(
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.red)),

                        width: double.infinity,
                        height: 50,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 0.5,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: roads.isEmpty
                              ? searchItem.chapters.length
                              : roads[currentRoad].length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  searchItem
                                      .chapters[roads.isEmpty
                                          ? index
                                          : roads[currentRoad].startIndex +
                                              index]
                                      .name,
                                  style: searchItem.durChapterIndex ==
                                          (roads.isEmpty
                                              ? index
                                              : roads[currentRoad].startIndex +
                                                  index)
                                      ? TextStyle(
                                          color: Colors.deepOrange,
                                        )
                                      : null,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: 20,
                                          color: Theme.of(context)
                                              .dialogBackgroundColor)),
                                  color: searchItem.durChapterIndex ==
                                          (roads.isEmpty
                                              ? index
                                              : roads[currentRoad].startIndex +
                                                  index)
                                      ? darkMode
                                          ? Colors.blueAccent.withOpacity(0.05)
                                          : Colors.deepOrangeAccent
                                              .withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.05),
                                ),
                              ),
                              onTap: () => provider.loadChapter(
                                roads.isEmpty
                                    ? index
                                    : roads[currentRoad].startIndex + index,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            );

            return !vertical
                ? playWidget
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        //color: Colors.black,
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Container(
                        height: 540,
                        //color: Colors.green,
                        child: playWidget,
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Color.fromARGB(248, 255, 255, 255),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  color: Colors.white,
                                  padding: EdgeInsets.only(top: 10, left: 10),
                                  child: Text(
                                    "章节列表",
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                playList,
                              ]),
                        ),
                      )
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildPlayer(bool showPlayer, BuildContext context) {
    final provider = Provider.of<VideoPageProvider>(context, listen: false);
    print("showPlayer:${showPlayer}");
    if (showPlayer) {
      final controller =
          context.select((VideoPageProvider provider) => provider.controller);
      // final aspectRatio =
      //     context.select((VideoPageProvider provider) => provider.aspectRatio);

      double ar = provider.getCurrentAspectRatio();
      if (ar == 0 || ar.isNaN) {
        SizeUtils.updateMediaData();
        ar = SizeUtils.screenWidthDp / SizeUtils.screenHeightDp;
      }
      print("getCurrentAspectRatio:${ar}");
      print("controller:${controller}");

      return GestureDetector(
        child: Container(
          // 增加color才能使全屏手势生效
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: controller == null
              ? null
              : VideoX(
                  player: controller,
                  aspectRatio: ar,
                ),
        ),
        onDoubleTap: provider.playOrPause,
        onTap: provider.toggleControllerBar,
        onLongPress: provider.onLongPress,
        onLongPressEnd: provider.onLongPressEnd,
        onHorizontalDragStart: provider.onHorizontalDragStart,
        onHorizontalDragUpdate: provider.onHorizontalDragUpdate,
        onHorizontalDragEnd: provider.onHorizontalDragEnd,
        onVerticalDragStart: provider.onVerticalDragStart,
        onVerticalDragUpdate: provider.onVerticalDragUpdate,
      );
    }
    return GestureDetector(
      child: Container(
        // 增加color才能使全屏手势生效
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      ),
      onTap: provider.toggleControllerBar,
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          width: 20,
          margin: EdgeInsets.only(bottom: 10),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xA0FFFFFF)),
            strokeWidth: 2,
          ),
        ),
        Text(
          context.select((VideoPageProvider provider) => provider.titleText),
          style: const TextStyle(
            color: const Color(0xD0FFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            height: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingText(BuildContext context) {
    context.select((VideoPageProvider provider) => provider.loadingText.length);
    const style = TextStyle(
      color: Color(0xB0FFFFFF),
      fontSize: 12,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: context
          .select((VideoPageProvider provider) => provider.loadingText)
          .map((s) => Text(
                s,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ))
          .toList(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final provider = Provider.of<VideoPageProvider>(context, listen: false);
    final vertical = context.select(
        (VideoPageProvider provider) => provider.screenAxis == Axis.vertical);
    final isLoading =
        context.select((VideoPageProvider provider) => provider.isLoading);

    final url =
        context.select((VideoPageProvider provider) => provider.videoUrl ?? "");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => vertical
                ? Navigator.of(context).pop()
                : provider.screenRotation(),
            color: Colors.white,
            tooltip: "返回",
          ),
        ),
        Expanded(
          child: Text(
            context.select((VideoPageProvider provider) => provider.titleText),
            style: TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // if (!vertical)
        Container(
          height: 20,
          child: IconButton(
            color: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.open_in_browser),
            onPressed: () => launch(
                searchItem.chapters[searchItem.durChapterIndex].contentUrl),
            tooltip: "查看原网页",
          ),
        ),
        // if (!vertical)
        Container(
          height: 20,
          child: IconButton(
            color: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.open_in_new),
            onPressed: provider.openInNew,
            tooltip: "使用其他播放器打开",
          ),
        ),

        if (!isLoading)
          Container(
            height: 20,
            child: IconButton(
              color: Colors.white,
              iconSize: 20,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.zoom_out_map),
              onPressed: provider.zoom,
              tooltip: "缩放",
            ),
          ),

        if (vertical)
          Container(
            height: 20,
            child: Menu<MenuVideoPlayer>(
              icon: Icons.more_horiz_outlined,
              color: Colors.white,
              items: videoPlayerMenus,
              onSelect: (value) {
                if (value == MenuVideoPlayer.openRaw) {
                  launch(searchItem
                      .chapters[searchItem.durChapterIndex].contentUrl);
                } else if (value == MenuVideoPlayer.copyUrl) {
                  Clipboard.setData(ClipboardData(text: url));
                } else if (value == MenuVideoPlayer.other_players) {
                  provider.openInNew();
                } else if (value == MenuVideoPlayer.dlna) {
                  provider.openDLNA(context);
                }
              },
            ),
          ),
        if (!vertical)
          Container(
            height: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.format_list_bulleted, size: 20),
              onPressed: () => provider.toggleChapterList(),
              color: Colors.white,
              tooltip: "节目列表",
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<VideoPageProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading;

        // final value = isLoading
        //     ? 0
        //     : provider.controller.position.value.inSeconds.toDouble();

        final vertical = context.select((VideoPageProvider provider) =>
            provider.screenAxis == Axis.vertical);
        final systemFullScreen = context
            .select((VideoPageProvider provider) => provider.systemFullScreen);

        Widget _buidlSlider = isLoading
            ? LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    VideoProgressColors().playedColor),
                backgroundColor: VideoProgressColors().backgroundColor,
              )
            : SeekBar(
                duration: provider.duration ?? Duration.zero,
                position: provider.position ?? Duration.zero,
                bufferedPosition: provider.bufferedPosition ?? Duration.zero,
                // onChangeEnd: (duration) {

                //   provider.controller?.seekTo(duration);
                // },
                onChanged: provider.seekTo,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buidlSlider,
            // Expanded(child: _buidlSlider),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isLoading)
                  IconButton(
                    iconSize: 25,
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    onPressed: () {
                      List<double> Speeds = [
                        0.5,
                        0.75,
                        1.0,
                        1.25,
                        1.5,
                        1.75,
                        2.0
                      ];
                      final primaryColor = Theme.of(context).primaryColor;
                      // final speed = context
                      //     .select((VideoPageProvider provider) => provider.currentSpeed);
                      showCupertinoModalPopup(
                        context: context,
                        builder: (_) => CupertinoActionSheet(
                          actions: List.generate(
                            Speeds.length,
                            (index) {
                              final quality = Speeds[index];
                              return CupertinoActionSheetAction(
                                child: Text(
                                  "${quality}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: quality == provider.currentSpeed
                                          ? Colors.red
                                          : primaryColor),
                                ),
                                onPressed: () {
                                  provider.changeSpeed(quality);
                                  Navigator.pop(_);
                                },
                              );
                            },
                          ),
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(_),
                            child: Text("返回"),
                            isDestructiveAction: true,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.speed),
                  ),
                SizedBox(
                  width: 50,
                ),
                if (!isLoading)
                  IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.fast_rewind),
                    onPressed: () =>
                        provider.parseContent(searchItem.durChapterIndex + 1),
                    tooltip: "上一集",
                  ),
                SizedBox(
                  width: 50,
                ),
                if (!isLoading)
                  IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    padding: EdgeInsets.zero,
                    icon: Icon(!provider.isLoading && provider.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: provider.playOrPause,
                    tooltip:
                        !provider.isLoading && provider.isPlaying ? "暂停" : "播放",
                  ),
                SizedBox(
                  width: 50,
                ),
                if (!isLoading)
                  IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.fast_forward),
                    onPressed: () =>
                        provider.parseContent(searchItem.durChapterIndex + 1),
                    tooltip: "下一集",
                  ),
                // if (!isLoading)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 13),
                //     child: Text(
                //       provider.isLoading
                //           ? "00:00 / 00:00" //"--:-- / --:--"
                //           : "${provider.positionString}",
                //       style: TextStyle(
                //           fontSize: 12,
                //           color: Colors.white,
                //           fontWeight: FontWeight.bold),
                //       textAlign: TextAlign.end,
                //     ),
                //   ),

                SizedBox(
                  width: 50,
                ),

                // if (!isLoading)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 13),
                //     child: Text(
                //       provider.isLoading
                //           ? "00:00 / 00:00" //"--:-- / --:--"
                //           : "${provider.durationString}",
                //       style: TextStyle(
                //           fontSize: 12,
                //           color: Colors.white,
                //           fontWeight: FontWeight.bold),
                //       textAlign: TextAlign.end,
                //     ),
                //   ),

                if (!isLoading)
                  IconButton(
                    color: Colors.white,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.screen_rotation),
                    onPressed: provider.screenRotation,
                    tooltip: vertical ? "窗口全屏" : "退出窗口全屏",
                  ),
                SizedBox(
                  width: 50,
                ),

                if (!isLoading)
                  IconButton(
                    color: Colors.white,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.fullscreen),
                    onPressed: provider.toggleSystemFullScreen,
                    tooltip: !systemFullScreen ? "系统全屏" : "退出全屏",
                  ),
              ],
            )
          ],
        );
      },
    );
  }
}

class VideoPageProvider with ChangeNotifier, WidgetsBindingObserver {
  int _currentRoad = 0;
  int get currentRoad => _currentRoad;

  bool _allowPlaybackground;
  bool get allowPlaybackground => _allowPlaybackground == true;

  set allowPlaybackground(bool value) {
    if (_allowPlaybackground != value) {
      _allowPlaybackground = value;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isPlaying = _controller?.playback?.isPlaying;
    switch (state) {
      case AppLifecycleState.paused:
        if (allowPlaybackground && isPlaying == true) {
          (() async {
            for (final _ in List.generate(10, (index) => index)) {
              await Future.delayed(Duration(milliseconds: 50));

              if (_controller?.playback?.isPlaying != true) {
                await _controller?.play();
              }
            }
          })();
        }
        break;
      default:
    }
  }

  final SearchItem searchItem;
  String _titleText;
  String get titleText => _titleText;
  List<String> _content;
  List<String> get content => _content;
  String _videoUrl;
  String get videoUrl => _videoUrl;
  bool _systemFullScreen = false;
  bool get systemFullScreen => _systemFullScreen;

  final loadingText = <String>[];
  bool _disposed;

  Player _controller;
  Player get controller => _controller;

  bool get isPlaying => _controller?.playback?.isPlaying ?? false;

  Duration _position = Duration.zero;
  Duration get position => _position;

  String get positionString => Utils.formatDuration(position);
  Duration get duration => _controller?.position?.duration;

  Duration get bufferedPosition => Duration.zero;

  String get durationString => Utils.formatDuration(duration);
  final ContentProvider contentProvider;
  Timer hotKeyTimer;
  static int key_status = 0;

  VideoPageProvider(
      {@required this.searchItem, @required this.contentProvider}) {
    WidgetsBinding.instance.addObserver(this);

    // hotKeyTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
    //   int status = GetAsyncKeyState(VK_SPACE);
    //   print("status:${status},${(status & 8000)},${status & 8000}");
    //   key_status = 0;
    //   if (status < 0) {
    //     if (key_status != 1) {
    //       key_status = 1;
    //       if (controller.playerStatus.playing) {
    //         controller.pause();
    //         print("暂停");
    //       } else {
    //         controller.play();
    //         print("播放");
    //       }
    //     }
    //   } else {
    //     key_status = 88;
    //   }
    //   //print("GetAsyncKeyState:${status},${status & 0x8000}");
    // });

    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }

    print("searchItem.durChapterIndex:${searchItem.durChapterIndex}");

    final roads =
        _parseChapers(searchItem.chapters, searchItem.durChapterIndex);

    for (var i = 0; i < roads.length; i++) {
      int _end = roads[i].startIndex + roads[i].length;
      if (searchItem.durChapterIndex >= roads[i].startIndex &&
          searchItem.durChapterIndex <= _end) {
        _chapterRoad = roads[i];
        _currentRoad = i;
      }
    }
    print("_currentRoad:${_currentRoad}");

    _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    _screenAxis = Axis.horizontal;
    _disposed = false;
    _showController = true;
    _aspectRatio = VideoAspectRatio.auto;
    //setVertical();
    setHorizontal();
    registerHotKeys();

    parseContent(null);
  }

  bool _islpSpeed;
  bool get islpSpeed => _islpSpeed;
  bool _isLoading;
  bool get isLoading => _isLoading != false;

  void toggleSystemFullScreen() async {
    await setHorizontal();
    _systemFullScreen = !_systemFullScreen;
    await windowManager.setFullScreen(_systemFullScreen);
    notifyListeners();
  }

  void disposeController() async {
    if (_controller != null) {
      _controller.pause();
      try {
        final firstCtrl = videoStreamControllers[0];
        await firstCtrl?.close();
        videoStreamControllers.remove(firstCtrl);
        // videoStreamControllers[0] = null;
        final ctrl = _controller;
        _controller = null;
        if (ctrl != null) ctrl.stop();

        if (ctrl != null) {
          await Utils.sleep(300);
          ctrl.dispose();
        }
      } catch (e) {
        print("disposeController:${e.toString()}");
      }
    }
  }

  void parseContent(int chapterIndex) async {
    if (chapterIndex != null &&
        (_isLoading == true ||
            chapterIndex < 0 ||
            chapterIndex >= searchItem.chaptersCount ||
            chapterIndex == searchItem.durChapterIndex)) {
      return;
    }

    _islpSpeed = false;
    _isLoading = true;
    _hint = null;

    // _controller?.removeListener(_listener);

    loadingText.clear();
    if (chapterIndex != null) {
      searchItem.durChapterIndex = chapterIndex;
      searchItem.durChapter = searchItem.chapters[chapterIndex].name;
      searchItem.durContentIndex = 1;
      _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    }
    _videoUrl = "";
    _content = null;
    loadingText.add("开始解析...");

    notifyListeners();
    () async {
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      await SearchItemManager.saveSearchItem();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
      await HistoryItemManager.saveHistoryItem();
    }();
    if (_disposed) return;
    try {
      _content = await contentProvider.loadChapter(
          chapterIndex ?? searchItem.durChapterIndex, true, false);
      if (_content.isEmpty || _content.first.isEmpty) {
        _content = null;
        _isLoading = null;
        loadingText.add("错误 内容为空！");
        disposeController();
        _controller = null;
        notifyListeners();
        return;
      }

      if (_disposed) return;
      loadingText.add("播放地址 ${_content[0].split("").join("\u200B")}");
      loadingText.add("获取视频信息...");
      notifyListeners();
      disposeController();
      _controller = Player(
        id: 0,
      );
      Map<String, String> httpHeaders;

      if (_content[0].contains("@headers")) {
        final u = _content[0].split("@headers");
        httpHeaders =
            (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
        _videoUrl = u[0];
      } else {
        _videoUrl = _content[0];
      }
      String refer = '';
      String ua = 'dart/vlc';
      if (httpHeaders != null) {
        refer = httpHeaders["Referer"];
        ua = httpHeaders["User-Agent"];
      }

      _controller = Player(
        id: 0,
        commandlineArguments: [
          '--http-referrer=' + refer,
          '--http-reconnect',
          '--sout-livehttp-caching',
          '--network-caching=60000',
          '--file-caching=60000'
        ],
      );
      _controller.setUserAgent(ua);
      _controller.open(Media.network(_videoUrl));

      _controller.positionStream.listen(_listener);
      _aspectRatio = VideoAspectRatio.auto;

      notifyListeners();
      // AudioService.stop();

      // await _controller.initialize();

      _currentSpeed = 1.0;
      _controller.seek(Duration(milliseconds: searchItem.durContentIndex));
      _controller.play();

      Wakelock.toggle(enable: true);
      //DeviceDisplayBrightness.keepOn(enabled: true);

      // _controller.addListener(_listener);

      _controllerTime = DateTime.now();
      _isLoading = false;
      if (_disposed) _controller?.dispose();
    } catch (e, st) {
      loadingText.add("错误 $e");
      loadingText.addAll("$st".split("\n").take(6));
      _isLoading = null;
      notifyListeners();
      disposeController();
      _controller = null;
      // _content = null;
      return;
    }
  }

  DateTime _lastNotifyTime;
  _listener(PositionState ps) {
    _position = ps.position;

    try {
      print("showController:${showController}");
      if (_lastNotifyTime == null ||
          DateTime.now().difference(_lastNotifyTime).inMicroseconds > 1000) {
        _lastNotifyTime = DateTime.now();
        if (showController &&
            DateTime.now()
                    .difference(_controllerTime)
                    .compareTo(_controllerDelay) >=
                0) {
          hideController();
          _showChapter = false;
        }

        searchItem.durContentIndex =
            _controller.position.position.inMilliseconds;
        searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
        SearchItemManager.saveSearchItem();
        notifyListeners();
      }
      if (_controller.playback.isPlaying) {
        if ((_controller.position.duration.inSeconds -
                    _controller.position.position.inSeconds)
                .abs() <=
            1) {
          if (_chapterRoad == null) {
            final _end = searchItem.chapters.length;
            final _next = searchItem.durChapterIndex + 1;
            if (_next < _end) {
              parseContent(searchItem.durChapterIndex + 1);
              return;
            }
          } else {
            final _begin = _chapterRoad.startIndex;
            final _end = _begin + _chapterRoad.length;
            final _next = searchItem.durChapterIndex + 1;
            print("播放完毕,${_begin},${_end},${searchItem.durChapterIndex + 1}");
            if (_next < _end) {
              parseContent(searchItem.durChapterIndex + 1);
              return;
            }
          }
          Utils.toast("播放完毕");

          //notifyListeners();
        }
      }
    } catch (e) {}

    // print(
    //     "${_controller.value.position.inSeconds} - ${_controller.value.duration.inSeconds} ");
  }

  Future<void> registerHotKeys() async {
    if (HotKeyManager.instance.registeredHotKeyList.length == 0) {
      HotKey arrowUP = HotKey(
        KeyCode.arrowUp,
        scope: HotKeyScope.inapp,
      );
      HotKey arrowDown = HotKey(
        KeyCode.arrowDown,
        scope: HotKeyScope.inapp,
      );
      HotKey arrowRight = HotKey(
        KeyCode.arrowRight,
        scope: HotKeyScope.inapp,
      );
      HotKey arrowLeft = HotKey(
        KeyCode.arrowLeft,
        scope: HotKeyScope.inapp,
      );
      HotKey escape = HotKey(
        KeyCode.escape,
        scope: HotKeyScope.inapp,
      );
      HotKey enter = HotKey(
        KeyCode.enter,
        scope: HotKeyScope.inapp,
      );
      HotKey spaceBar = HotKey(
        KeyCode.space,
        scope: HotKeyScope.inapp,
      );
      HotKey dot = HotKey(
        KeyCode.numpadDecimal,
        scope: HotKeyScope.inapp,
      );
      await HotKeyManager.instance.register(
        arrowUP,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');

          // setVolume(volume.value + 0.05);
        },
      );
      await HotKeyManager.instance.register(
        arrowDown,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');
          // setVolume(volume.value - 0.05);
        },
      );
      await HotKeyManager.instance.register(
        arrowRight,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');
          // if ((_controller?.bufferingProgress ?? -1) == 0) {

          // }

          seekTo(Duration(seconds: _position.inSeconds + 10));
        },
      );
      await HotKeyManager.instance.register(
        arrowLeft,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');

          seekTo(Duration(seconds: _position.inSeconds - 10));
        },
      );

      await HotKeyManager.instance.register(
        escape,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');
          if (_systemFullScreen == true) {
            toggleSystemFullScreen();
          }
        },
      );
      await HotKeyManager.instance.register(
        enter,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');
          if (_systemFullScreen == false) {
            toggleSystemFullScreen();
          }
        },
      );
      await HotKeyManager.instance.register(
        spaceBar,
        keyDownHandler: (hotKey) {
          print('onKeyDown+${hotKey.toJson()}');

          if (isPlaying) {
            _pause();
          } else {
            _play();
          }
        },
      );
      // await HotKeyManager.instance.register(
      //   dot,
      //   keyDownHandler: (hotKey) {
      //     toggleVideoFit();
      //   },
      // );
    } else {
      print("hotkeys are registered ");
    }
    //await HotKeyManager.instance.unregister(_hotKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isIOS) {
      setVertical();
    }
    resetRotation();
    _disposed = true;
    // hotKeyTimer.cancel();
    if (Platform.isWindows) {
      HotKeyManager.instance.unregisterAll();
    }

    if (_controller != null) {
      searchItem.durContentIndex = _controller.position.position.inMilliseconds;

      //controller.removeListener(_listener);
      print("销毁controller");

      disposeController();

      //controller.removeWindowsListener();
    }
    () async {
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      await SearchItemManager.saveSearchItem();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
      await HistoryItemManager.saveHistoryItem();
    }();
    if (Platform.isIOS || Platform.isAndroid) {
      //DeviceDisplayBrightness.resetBrightness();
      //ScreenBrightness().resetScreenBrightness();
      Wakelock.toggle(enable: false);
      //DeviceDisplayBrightness.keepOn(enabled: false);
    }

    loadingText.clear();
    resetRotation();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    super.dispose();
  }

  void resetRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setHorizontal() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    if ((await windowManager.isFullScreen())) {
      await windowManager.setFullScreen(false);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    notifyListeners();
  }

  void setVertical() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if ((await windowManager.isFullScreen())) {
      await windowManager.setFullScreen(false);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    notifyListeners();
  }

  void openDLNA(BuildContext context) {
    if (_disposed || _content == null) return;
    _controllerTime = DateTime.now();
    DLNAUtil.instance.start(
      context,
      title: _titleText,
      url: _content[0],
      videoType: VideoObject.VIDEO_MP4,
      onPlay: playOrPause,
    );
  }

  void openInNew() {
    if (_disposed || _content == null) return;
    _controllerTime = DateTime.now();
    launch(_content[0]);
  }

  Widget _hint;
  Widget get hint => _hint;
  DateTime _hintTime;
  void autoHideHint() {
    _hintTime = DateTime.now();
    const _hintDelay = Duration(seconds: 2);
    Future.delayed(_hintDelay, () {
      if (DateTime.now().difference(_hintTime).compareTo(_hintDelay) >= 0) {
        _hint = null;
        if (_disposed) {
          return;
        }
        notifyListeners();
      }
    });
  }

  void setHintText(String text, [bool updateControllerTime = false]) {
    _hint = Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        height: 1.5,
      ),
    );
    if (updateControllerTime) {
      _controllerTime = DateTime.now();
    }
    notifyListeners();
    autoHideHint();
  }

  void _pause() async {
    Wakelock.toggle(enable: false);
    //DeviceDisplayBrightness.keepOn(enabled: false);

    await controller.pause();
    setHintText("已暂停");
  }

  static double _playSpeed = 1.0;
  double get playSpeed => _playSpeed;
  double _currentSpeed = 1.0;
  double get currentSpeed => _currentSpeed;

  void changeSpeed(double speed) async {
    if (speed == null) return;
    if (_controller == null) {
      setHintText("请先播放视频");
      return;
    }
    if ((currentSpeed - speed).abs() > 0.1) {
      _controller.setRate(speed);
      //await controller.setPlaybackSpeed(speed);

      _currentSpeed = speed;
      _playSpeed = speed;
      setHintText("播放速度 $speed");
      notifyListeners();
    }
  }

  void seekTo(Duration ps) async {
    _position = ps;
    await _controller?.seek(ps);
    notifyListeners();
  }

  void _play() async {
    setHintText("播放");
    Wakelock.toggle(enable: true);
    //DeviceDisplayBrightness.keepOn(enabled: true);
    await controller.play();
  }

  void playOrPause() {
    if (_isLoading == null) {
      parseContent(null);
    }
    if (_disposed || isLoading) return;
    _controllerTime = DateTime.now();
    if (isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  bool _showController;
  bool get showController => _showController != false;
  bool _showChapter;
  bool get showChapter => _showChapter ?? false;
  DateTime _controllerTime;
  final _controllerDelay = Duration(seconds: 4);

  void toggleControllerBar() {
    if (showChapter == true) {
      hideController();
      toggleChapterList();
      return;
    }

    if (showController) {
      hideController();
    } else {
      displayController();
    }
    notifyListeners();
  }

  void toggleChapterList() {
    if (showChapter) {
      _showChapter = false;
    } else {
      hideController();
      _showChapter = true;
    }
    notifyListeners();
  }

  void displayController() {
    print("displayController");
    _showController = true;
    if (_screenAxis == Axis.vertical) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }

    _controllerTime = DateTime.now();
    notifyListeners();
  }

  void hideController() {
    print("hideController");
    _showController = false;
    if (_screenAxis == Axis.horizontal) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
    notifyListeners();
  }

  VideoAspectRatio _aspectRatio;
  VideoAspectRatio get aspectRatio => _aspectRatio;

  double _getAspectRatio() {
    VideoDimensions vd = controller?.videoDimensions ?? VideoDimensions(0, 0);
    var ar = vd.width / vd.height;
    return ar;
  }

  /// 根据缩放方式计算当前缩放比例
  double getCurrentAspectRatio() {
    switch (_aspectRatio) {
      case VideoAspectRatio.auto:
        return _getAspectRatio();
      case VideoAspectRatio.a169:
        return 16 / 9;
      case VideoAspectRatio.a43:
        return 4 / 3;
      case VideoAspectRatio.a916:
        return 9 / 16;
      case VideoAspectRatio.a1610:
        return 16 / 10;
      case VideoAspectRatio.a32:
        return 3 / 2;
      case VideoAspectRatio.a2k:
        return 1.8962963;
      case VideoAspectRatio.a4k:
        return 2.386946387;
      case VideoAspectRatio.vcd:
        return 1.222222222;
      case VideoAspectRatio.a2512:
        return 2.0833333;
      case VideoAspectRatio.aHDTV:
        return 1.875;
      default:
        return 0;
    }
  }

  void zoom() {
    _controllerTime = DateTime.now();
    switch (_aspectRatio) {
      case VideoAspectRatio.auto:
        _aspectRatio = VideoAspectRatio.full;
        setHintText('充满');
        break;
      case VideoAspectRatio.full:
        _aspectRatio = VideoAspectRatio.a169;
        setHintText('16 : 9'); // 1.7777
        break;
      case VideoAspectRatio.a169:
        _aspectRatio = VideoAspectRatio.a43;
        setHintText('4 : 3'); // 1.3333
        break;
      case VideoAspectRatio.a43:
        _aspectRatio = VideoAspectRatio.a916;
        setHintText('9 : 16'); // 0.5625
        break;
      case VideoAspectRatio.a916:
        _aspectRatio = VideoAspectRatio.a1610;
        setHintText('16 : 10'); // 1.6
        break;
      case VideoAspectRatio.a1610:
        _aspectRatio = VideoAspectRatio.vcd;
        setHintText('11 : 9 (VCD)'); // 1.2222
        break;
      case VideoAspectRatio.vcd:
        _aspectRatio = VideoAspectRatio.a54;
        setHintText('5 : 4'); // 1.25
        break;
      case VideoAspectRatio.a54:
        _aspectRatio = VideoAspectRatio.a32;
        setHintText('3 : 2'); // 1.5
        break;
      case VideoAspectRatio.a32:
        _aspectRatio = VideoAspectRatio.a2k;
        setHintText('17 : 9 (2K/4K)'); // 1.8962963
        break;
      case VideoAspectRatio.a2k:
        _aspectRatio = VideoAspectRatio.a4k;
        setHintText('19 : 8 (4K-)'); // 2.3869464
        break;
      case VideoAspectRatio.a4k:
        _aspectRatio = VideoAspectRatio.a2512;
        setHintText('25 : 12'); // 2.083333
        break;
      case VideoAspectRatio.a2512:
        _aspectRatio = VideoAspectRatio.aHDTV;
        setHintText('15 : 8 (UHDTV)'); // 1.875
        break;
      case VideoAspectRatio.aHDTV:
        _aspectRatio = VideoAspectRatio.auto;
        setHintText('自动');
        break;
      default:
        break;
    }
  }

  void loadChapter(int index) {
    parseContent(index);
  }

  Axis _screenAxis;
  Axis get screenAxis => _screenAxis;
  void screenRotation() {
    _controllerTime = DateTime.now();
    if (_screenAxis == Axis.horizontal) {
      setHintText("纵向");
      _screenAxis = Axis.vertical;
      setVertical();
    } else {
      setHintText("横向");
      _screenAxis = Axis.horizontal;
      setHorizontal();
    }
  }

  /// 手势处理
  double _dragStartPosition;
  Duration _gesturePosition;
  bool _draging;

  void setHintTextWithIcon(num value, IconData icon) {
    _hint = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
            SizedBox(width: 10),
            Container(
              width: 100,
              child: LinearProgressIndicator(
                value: value,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0x8FFF2020)),
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
        Text(
          (value * 100).toStringAsFixed(0),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1.5,
          ),
        )
      ],
    );
    notifyListeners();
    autoHideHint();
  }

  void onHorizontalDragStart(DragStartDetails details) =>
      _dragStartPosition = details.globalPosition.dx;

  void onHorizontalDragEnd(DragEndDetails details) {
    _controller.seek(_gesturePosition);
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    final d = Duration(
        seconds: (details.globalPosition.dx - _dragStartPosition) ~/ 10);
    _gesturePosition = position + d;
    final prefix = d.compareTo(Duration.zero) < 0 ? "-" : "+";
    setHintText(
        "${Utils.formatDuration(_gesturePosition)} / $positionString\n[ $prefix ${Utils.formatDuration(d)} ]");
  }

  void onVerticalDragStart(DragStartDetails details) =>
      _dragStartPosition = details.globalPosition.dy;

  void onVerticalDragUpdate(DragUpdateDetails details) async {
    if (_draging == true) return;
    _draging = true;

    /// 手势调节正常运作核心代码就是这句了
    _dragStartPosition = details.globalPosition.dy;
    _draging = false;
  }

  void onLongPress() async {
    if (controller == null) {
      setHintText("请先播放视频");
      return;
    }
    if (!controller.playback.isPlaying) {
      return;
    }

    await HapticFeedback.lightImpact();
    double speed = 2.0;
    controller.setRate(speed);
    _playSpeed = speed;

    if ((currentSpeed - speed).abs() > 0.1) _islpSpeed = true;

    //_currentSpeed = speed;
    notifyListeners();
  }

  void onLongPressEnd(LongPressEndDetails details) async {
    if (controller == null) {
      setHintText("请先播放视频");
      return;
    }

    await controller.setRate(_currentSpeed);
    _playSpeed = _currentSpeed;
    _islpSpeed = false;
    notifyListeners();
  }

  int _refreshFav = 0;
  int get refreshFav => _refreshFav;
  void toggleFavorite() async {
    print("_isLoading:${_isLoading}");
    if (_isLoading) return;
    await SearchItemManager.toggleFavorite(searchItem);
    _refreshFav++;
    notifyListeners();
  }

  ChapterRoad _chapterRoad;
  ChapterRoad get chapterRoad => _chapterRoad;
  set chapterRoad(ChapterRoad value) {
    _chapterRoad = value;
    print("设置");
    notifyListeners();
  }

  void toggleRoad(int id, int index) {
    _currentRoad = id;
    //searchItem.durChapterIndex = index;
    parseContent(index);
    notifyListeners();
  }
}

enum VideoAspectRatio {
  /// 自动
  auto,

  /// 充满
  full,

  /// 4：3
  a43,

  /// 16：9
  a169,

  /// 9：16
  a916,

  /// 16: 10
  a1610,

  /// 1.2222
  vcd,

  /// 5 : 4
  a54,

  /// 3: 2
  a32,

  /// 1.8962963
  a2k,

  /// 超宽屏 2.38695
  a4k,

  /// 超宽屏 2.08333
  a2512,

  /// 1.875
  aHDTV,
}

class VideoX extends StatefulWidget {
  /// The [Player] whose [Video] output should be shown.
  final Player player;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  /// Scale.
  final double scale, aspectRatio;

  /// Filter quality.
  final FilterQuality filterQuality;

  const VideoX({
    @required this.player,
    this.aspectRatio = 1.0,
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.scale = 1.0,
    this.filterQuality = FilterQuality.low,
    Key key,
  }) : super(key: key);

  @override
  State createState() => _VideoStateTexture();
}

abstract class _VideoStateBase extends State<VideoX>
    with AutomaticKeepAliveClientMixin {
  int get playerId => widget.player.id;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return present();
  }

  Widget present();
}

/// Texture based Video playback.
class _VideoStateTexture extends _VideoStateBase {
  StreamSubscription _videoDimensionsSubscription;
  double _videoWidth;
  double _videoHeight;

  @override
  void initState() {
    super.initState();
    _videoWidth = widget.player.videoDimensions.width.toDouble();
    _videoHeight = widget.player.videoDimensions.height.toDouble();
    _videoDimensionsSubscription =
        widget.player.videoDimensionsStream.listen((dimensions) {
      if (_videoWidth != dimensions.width.toDouble() &&
          _videoHeight != dimensions.height.toDouble()) {
        setState(() {
          _videoWidth = dimensions.width.toDouble();
          _videoHeight = dimensions.height.toDouble();
        });
      }
    });

    if (mounted) setState(() {});
  }

  @override
  Widget present() {
    return ValueListenableBuilder<int>(
        valueListenable: widget.player.textureId,
        builder: (context, textureId, _) {
          if (textureId == null ||
              _videoWidth == null ||
              _videoHeight == null) {
            return const SizedBox();
          }

          return AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: SizedBox.expand(
              child: ClipRect(
                  child: FittedBox(
                      alignment: widget.alignment,
                      fit: widget.fit,
                      child: SizedBox(
                          width: _videoWidth,
                          height: _videoHeight,
                          child: Texture(
                            textureId: textureId,
                            filterQuality: widget.filterQuality,
                          )))),
            ),
          );
        });
  }

  @override
  Future<void> dispose() async {
    _videoDimensionsSubscription.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
