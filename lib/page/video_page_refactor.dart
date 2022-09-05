import 'dart:convert';

import 'dart:io';

import 'package:dlna/dlna.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/fonticons_icons.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/menu/menu_item.dart';
import 'package:eso/menu/menu_videoPlayer.dart';
import 'package:eso/model/audio_service_handler.dart';
import 'package:eso/page/chapter_page.dart';
import 'package:eso/page/source/editor/highlight_code_editor_theme.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';

import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:win32/win32.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';
import 'package:dart_vlc/dart_vlc.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../global.dart';
import '../model/audio_service.dart';
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

class VideoPage extends StatelessWidget {
  final SearchItem searchItem;
  const VideoPage({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black87,
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
            final roads =
                _parseChapers(searchItem.chapters, searchItem.durChapterIndex);
            final nomalText = TextStyle(color: Colors.black);
            final primaryText = TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
            );

            final currentRoad = context
                .select((VideoPageProvider provider) => provider.currentRoad);
            final vertical = context.select((VideoPageProvider provider) =>
                provider.screenAxis == Axis.vertical);

            final speed = context
                .select((VideoPageProvider provider) => provider.currentSpeed);
            final refreshFav = context
                .select((VideoPageProvider provider) => provider.refreshFav);

            Widget playWidget = Stack(
              children: [
                _buildPlayer(!isLoading && !Global.isDesktop, context),
                if (isLoading)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: _buildLoading(context),
                    ),
                  ),
                // if (!isLoading && showController)
                //   Positioned(
                //     //left: -15,
                //     right: 50,
                //     top: (vertical
                //             ? 140
                //             : MediaQuery.of(context).size.height / 2) -
                //         MediaQuery.of(context).padding.top / 2,
                //     //width: 100,
                //     child: Container(
                //       //height: 20,
                //       decoration: BoxDecoration(
                //         color: Colors.green.withOpacity(0.3),
                //         borderRadius: BorderRadius.all(Radius.circular(50)),
                //         // boxShadow: [
                //         //   BoxShadow(
                //         //     color: Colors.white.withOpacity(0.5),
                //         //     //offset: Offset(-20, -20),
                //         //     blurRadius: 10,
                //         //     spreadRadius: 10,
                //         //   )
                //         // ],
                //       ),
                //       child: Menu<double>(
                //         tooltip: "倍速",
                //         icon: Icons.slow_motion_video_outlined,
                //         iconSize: 30,
                //         color: Colors.white,
                //         items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                //             .map((value) => MenuItem<double>(
                //                   value: value,
                //                   text: "$value",
                //                   textColor: (speed - value).abs() < 0.1
                //                       ? primaryColor
                //                       : null,
                //                 ))
                //             .toList(),
                //         onSelect: (double value) async {
                //           provider.changeSpeed(value);
                //         },
                //       ),

                //     ),
                //   ),
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
                      height: 50,
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
            bool darkMode = Utils.isDarkMode(context);

            // Widget playRoad(item) => Padding(
            //       padding: EdgeInsets.only(left: 10),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             item.name,
            //             style: TextStyle(
            //                 color: Colors.black, fontWeight: FontWeight.bold),
            //           ),
            //           Wrap(
            //             spacing: 5.0,
            //             children: [
            //               for (var i = 0; i < item.length; i++)
            //                 OutlinedButton(
            //                   style: OutlinedButton.styleFrom(
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(5.0),
            //                     ),
            //                     side: BorderSide(
            //                         width: 0.5, color: Colors.purple),
            //                   ),
            //                   onPressed: () =>
            //                       provider.loadChapter(item.startIndex + i),
            //                   child: Text(
            //                       searchItem.chapters[item.startIndex + i].name,
            //                       style: searchItem.durChapterIndex ==
            //                               item.startIndex + i
            //                           ? primaryText
            //                           : nomalText),
            //                 )
            //               //item.length
            //             ],
            //           )
            //         ],
            //       ),
            //     );
            // List<Widget> buildRoads = roads.isEmpty
            //     ? [playRoad(ChapterRoad("默认线路", 0, searchItem.chapters.length))]
            //     : roads.map((e) => playRoad(e)).toList();

            final _iconTheme = Theme.of(context).primaryIconTheme;
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
                                        title: Text(
                                          searchItem.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                          ),
                                        ),
                                        subtitle: Text(
                                            "\n作者：${searchItem.author}\n\n标签：${searchItem.tags.join(' · ')}\n\n${searchItem.description}"),
                                      ),
                                    );
                                  },
                                );
                              }),
                          subtitle: Text(searchItem.tags.join(' · ')),
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
                                                  crossAxisCount: 2,
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
                        // Wrap(children: [
                        //   for (var i = 0; i < roads[currentRoad].length; i++)
                        //     TextButton(
                        //       style: ButtonStyle(),
                        //       onPressed: () {},
                        //       child: Text(searchItem
                        //           .chapters[roads[currentRoad].startIndex + i]
                        //           .name),
                        //     ),
                        // ])

                        // Container(
                        //   width: double.infinity,
                        //   child: ListView.builder(
                        //     scrollDirection: Axis.horizontal,
                        //     itemCount: 1,
                        //     itemBuilder: (context, index) {
                        //       return TextButton(
                        //         onPressed: () {},
                        //         child: Text(searchItem
                        //             .chapters[roads[currentRoad].startIndex + index]
                        //             .name),
                        //       );
                        //     },
                        //   ),
                        // ),
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
                        height: 35,
                        child: ListView.builder(
                          // gridDelegate:
                          //     SliverGridDelegateWithFixedCrossAxisCount(
                          //         crossAxisCount: 1, childAspectRatio: 0.5),
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
                            // return ActionChip(
                            //   labelPadding:
                            //       EdgeInsets.only(left: 15, right: 15),
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(1.0),
                            //   ),
                            //   backgroundColor: searchItem.durChapterIndex ==
                            //           (roads.isEmpty
                            //               ? index
                            //               : roads[currentRoad].startIndex +
                            //                   index)
                            //       ? darkMode
                            //           ? Colors.blueAccent.withOpacity(0.05)
                            //           : Colors.deepOrangeAccent.withOpacity(0.1)
                            //       : Colors.grey.withOpacity(0.05),
                            //   label: Text(
                            //     searchItem
                            //         .chapters[roads.isEmpty
                            //             ? index
                            //             : roads[currentRoad].startIndex + index]
                            //         .name,
                            //     style: searchItem.durChapterIndex ==
                            //             (roads.isEmpty
                            //                 ? index
                            //                 : roads[currentRoad].startIndex +
                            //                     index)
                            //         ? TextStyle(
                            //             color: Colors.deepOrange,
                            //           )
                            //         : null,
                            //   ),
                            //   onPressed: () {
                            //     provider.loadChapter(
                            //       roads.isEmpty
                            //           ? index
                            //           : roads[currentRoad].startIndex + index,
                            //     );
                            //   },
                            // );
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            );

            //final sr = provider.controller?.value?.aspectRatio ?? 0.0;
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
                        height: 280,
                        //color: Colors.green,
                        child: playWidget,
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Theme.of(context).dialogBackgroundColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 35,
                                color: Theme.of(context).dialogBackgroundColor,
                                padding: EdgeInsets.only(top: 10, left: 10),
                                child: Stack(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "视频信息",
                                      style: TextStyle(
                                        //color: Colors.pink,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              playList,
                            ],
                          ),
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
    if (showPlayer) {
      final controller =
          context.select((VideoPageProvider provider) => provider.controller);
      final aspectRatio =
          context.select((VideoPageProvider provider) => provider.aspectRatio);
      final ar = provider.getAspectRatio();
      print("ar:${ar}");

      return GestureDetector(
        child: Container(
          // 增加color才能使全屏手势生效
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: aspectRatio == VideoAspectRatio.full ||
                  provider.getAspectRatio() == 0
              ? VideoPlayer(controller)
              : AspectRatio(
                  aspectRatio: ar,
                  child: VideoPlayer(controller),
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
    final url = context.select(
        (VideoPageProvider provider) => provider.controller?.dataSource ?? "");

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
        if (!vertical)
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
        if (!vertical)
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

        // Container(
        //   height: 20,
        //   child: Menu<double>(
        //     tooltip: "倍速",
        //     icon: Icons.slow_motion_video_outlined,
        //     color: Colors.white,
        //     items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
        //         .map((value) => MenuItem<double>(
        //               value: value,
        //               text: "$value",
        //               textColor:
        //                   (speed - value).abs() < 0.1 ? primaryColor : null,
        //             ))
        //         .toList(),
        //     onSelect: (double value) async {
        //       provider.changeSpeed(value);
        //     },
        //   ),
        // ),
        // if (!vertical)
        //   IconButton(
        //     color: Colors.white,
        //     iconSize: 20,
        //     padding: EdgeInsets.zero,
        //     icon: Icon(Icons.airplay),
        //     onPressed: () => provider.openDLNA(context),
        //     tooltip: "DLNA投屏",
        //   ),
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
        final primaryColor = Theme.of(context).primaryColor;
        final isLoading = provider.isLoading;

        final value =
            //provider.isLoading ? 0 : provider.position.inSeconds.toDouble();
            isLoading
                ? 0
                : provider.controller.value.position.inSeconds.toDouble();
        print("isLoading:${isLoading},value:${value}");
        final vertical = context.select((VideoPageProvider provider) =>
            provider.screenAxis == Axis.vertical);
        Widget _buidlSlider = isLoading
            ? LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    VideoProgressColors().playedColor),
                backgroundColor: VideoProgressColors().backgroundColor,
              )
            : FlutterSlider(
                values: [value > 0 ? value : 0],
                min: 0,
                max: provider.duration.inSeconds.toDouble(),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  provider.setHintText(
                      "跳转至  " +
                          Utils.formatDuration(Duration(
                              seconds: (lowerValue as double).toInt())),
                      true);
                  provider
                      .seek(Duration(seconds: (lowerValue as double).toInt()))
                      .then((_) {
                    if (Platform.isIOS) {
                      Future.delayed(Duration(milliseconds: 1500), () {
                        print("provider.playSpeed:${provider.playSpeed}");
                        provider.controller
                            .setPlaybackSpeed(provider.playSpeed);
                      });
                    }
                  });
                },
                handlerHeight: 12,
                handlerWidth: 12,
                handler: FlutterSliderHandler(
                  child: Container(
                    width: 12,
                    height: 12,
                    alignment: Alignment.center,
                    child: Icon(Icons.radio_button_checked,
                        color: Colors.red, size: 12),
                  ),
                ),
                touchSize: 20,
                trackBar: FlutterSliderTrackBar(
                  inactiveTrackBarHeight: 1.5,
                  activeTrackBarHeight: 1.5,
                  inactiveTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white54,
                  ),
                  activeTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.deepOrange,
                  ),
                ),
                tooltip: FlutterSliderTooltip(disabled: true),
              );

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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

            if (!isLoading && !vertical)
              IconButton(
                color: Colors.white,
                iconSize: 30,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.skip_next),
                onPressed: () =>
                    provider.parseContent(searchItem.durChapterIndex + 1),
                tooltip: "下一集",
              ),

            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Text(
                  provider.isLoading
                      ? "00:00 / 00:00" //"--:-- / --:--"
                      : "${provider.positionString}",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
            if (!isLoading)
              SizedBox(
                width: 5,
              ),

            Expanded(child: _buidlSlider),
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Text(
                  provider.isLoading
                      ? "00:00 / 00:00" //"--:-- / --:--"
                      : "${provider.durationString}",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
            if (!isLoading && !vertical)
              Menu<double>(
                tooltip: "倍速",
                icon: Icons.slow_motion_video_outlined,
                iconSize: 20,
                color: Colors.white,
                items: [
                  0.25,
                  0.5,
                  1.0,
                  1.25,
                  1.5,
                  1.75,
                  2.0,
                  3.0,
                ]
                    .map((value) => MenuItem<double>(
                          value: value,
                          text: "$value",
                          textColor: (provider.playSpeed - value).abs() < 0.1
                              ? primaryColor
                              : null,
                        ))
                    .toList(),
                onSelect: (double value) async {
                  provider.changeSpeed(value);
                },
              ),

            if (!isLoading)
              IconButton(
                color: Colors.white,
                iconSize: 20,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.screen_rotation),
                onPressed: provider.screenRotation,
                tooltip: "旋转",
              ),

            // Padding(
            //   padding: const EdgeInsets.only(right: 6),
            //   child: Text(
            //     provider.isLoading
            //         ? "00:00 / 00:00" //"--:-- / --:--"
            //         : "${provider.positionString} / ${provider.durationString}",
            //     style: TextStyle(fontSize: 10, color: Colors.white),
            //     textAlign: TextAlign.end,
            //   ),
            // ),
            // SizedBox(
            //   height: vertical ? 35 : null,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       // IconButton(
            //       //   color:
            //       //       provider.allowPlaybackground ? Colors.red : Colors.grey,
            //       //   iconSize: 20,
            //       //   padding: EdgeInsets.zero,
            //       //   icon: Icon(Icons.switch_video),
            //       //   onPressed: () => provider.allowPlaybackground =
            //       //       !provider.allowPlaybackground,
            //       //   tooltip: "后台播放",
            //       // ),
            //       if (provider.screenAxis == Axis.horizontal)
            //         IconButton(
            //           color: Colors.white,
            //           iconSize: 20,
            //           padding: EdgeInsets.zero,
            //           icon: Icon(Icons.airplay),
            //           onPressed: () => provider.openDLNA(context),
            //           tooltip: "DLNA投屏",
            //         ),
            //       IconButton(
            //         color: Colors.white,
            //         iconSize: 25,
            //         padding: EdgeInsets.zero,
            //         icon: Icon(Icons.skip_previous),
            //         onPressed: () =>
            //             provider.parseContent(searchItem.durChapterIndex - 1),
            //         tooltip: "上一集",
            //       ),
            //       IconButton(
            //         color: Colors.white,
            //         iconSize: 25,
            //         padding: EdgeInsets.zero,
            //         icon: Icon(!provider.isLoading && provider.isPlaying
            //             ? Icons.pause
            //             : Icons.play_arrow),
            //         onPressed: provider.playOrPause,
            //         tooltip:
            //             !provider.isLoading && provider.isPlaying ? "暂停" : "播放",
            //       ),
            //       IconButton(
            //         color: Colors.white,
            //         iconSize: 25,
            //         padding: EdgeInsets.zero,
            //         icon: Icon(Icons.skip_next),
            //         onPressed: () =>
            //             provider.parseContent(searchItem.durChapterIndex + 1),
            //         tooltip: "下一集",
            //       ),
            //       if (provider.screenAxis == Axis.horizontal)
            //         IconButton(
            //           color: Colors.white,
            //           iconSize: 20,
            //           padding: EdgeInsets.zero,
            //           icon: Icon(Icons.zoom_out_map),
            //           onPressed: provider.zoom,
            //           tooltip: "缩放",
            //         ),
            //       IconButton(
            //         color: Colors.white,
            //         iconSize: 20,
            //         padding: EdgeInsets.zero,
            //         icon: Icon(Icons.screen_rotation),
            //         onPressed: provider.screenRotation,
            //         tooltip: "旋转",
            //       ),
            //     ],
            //   ),
            // )
          ],
        );
      },
    );
  }
}

class VideoPageProvider with ChangeNotifier, WidgetsBindingObserver {
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
    final isPlaying = _controller?.value?.isPlaying;
    switch (state) {
      case AppLifecycleState.paused:
        if (allowPlaybackground && isPlaying == true) {
          (() async {
            for (final _ in List.generate(10, (index) => index)) {
              await Future.delayed(Duration(milliseconds: 50));

              if (_controller?.value?.isPlaying != true) {
                await _controller?.play();
              }
            }
          })();
        }
        break;
      default:
    }
  }

  ChapterRoad _chapterRoad;
  ChapterRoad get chapterRoad => _chapterRoad;
  set chapterRoad(ChapterRoad value) {
    _chapterRoad = value;
    print("设置");
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

  void toggleRoad(int id, int index) {
    _currentRoad = id;
    //searchItem.durChapterIndex = index;
    parseContent(index);
    notifyListeners();
  }

  int _currentRoad = 0;
  int get currentRoad => _currentRoad;

  final SearchItem searchItem;
  String _titleText;
  String get titleText => _titleText;
  List<String> _content;
  List<String> get content => _content;

  final loadingText = <String>[];
  bool _disposed;

  VideoPlayerController _controller;
  VideoPlayerController get controller => _controller;
  bool get isPlaying => _controller.value.isPlaying;
  Duration _position = Duration.zero;
  Duration get position => _position;
  String get positionString => Utils.formatDuration(_position);
  Duration get duration => _controller.value.duration;
  String get durationString => Utils.formatDuration(_controller.value.duration);
  final ContentProvider contentProvider;
  VideoPageProvider(
      {@required this.searchItem, @required this.contentProvider}) {
    WidgetsBinding.instance.addObserver(this);
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }

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

    // print(
    //     "_chapterRoad:${_chapterRoad.name}.${_chapterRoad.startIndex},${_currentRoad}");

    _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    _screenAxis = Axis.vertical;
    _disposed = false;
    _aspectRatio = VideoAspectRatio.auto;
    setVertical();
    //setHorizontal();
    parseContent(null);
  }

  bool _islpSpeed;
  bool get islpSpeed => _islpSpeed;
  bool _isLoading;
  bool get isLoading => _isLoading != false;

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
    _controller?.removeListener(_listener);
    loadingText.clear();
    if (chapterIndex != null) {
      searchItem.durChapterIndex = chapterIndex;
      searchItem.durChapter = searchItem.chapters[chapterIndex].name;
      searchItem.durContentIndex = 1;
      _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    }
    _content = null;
    loadingText.add("开始解析...");
    await controller?.pause();
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
        _controller?.dispose();
        _controller = null;
        notifyListeners();
        return;
      }

      if (_disposed) return;
      loadingText.add("播放地址 ${_content[0].split("").join("\u200B")}");
      loadingText.add("获取视频信息...");
      notifyListeners();
      (VideoPlayerController controller) {
        Future.delayed(Duration(microseconds: 120))
            .then((value) => controller?.dispose());
      }(_controller);
      _controller?.dispose();

      if (_disposed) return;
      if (_content[0].contains("@headers")) {
        final u = _content[0].split("@headers");
        final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
        _controller = VideoPlayerController.network(
          u[0],
          httpHeaders: h,
          videoPlayerOptions:
              VideoPlayerOptions(allowBackgroundPlayback: _allowPlaybackground),
        );
      } else {
        _controller = VideoPlayerController.network(
          _content[0],
          videoPlayerOptions:
              VideoPlayerOptions(allowBackgroundPlayback: _allowPlaybackground),
        );
      }
      // if (_aspectRatio == VideoAspectRatio.uninit) {
      //   _aspectRatio = VideoAspectRatio.auto;
      // }
      notifyListeners();
      MyAudioService.audioHandler.stop();
      // AudioService.stop();

      await _controller.initialize();
      _currentSpeed = 1.0;

      seek(Duration(milliseconds: searchItem.durContentIndex)).then((_) {
        if (Platform.isIOS) {
          Future.delayed(Duration(milliseconds: 1500), () async {
            print("playSpeed:${_playSpeed}");
            await changeSpeed(_playSpeed);
          });
        }
      });

      _controller.play();
      print("视频尺寸:${_controller.value.size},${_controller.value.aspectRatio}");

      Wakelock.toggle(enable: true);
      //DeviceDisplayBrightness.keepOn(enabled: true);
      _controller.addListener(_listener);
      _controllerTime = DateTime.now();
      _isLoading = false;
      if (_disposed) _controller?.dispose();
    } catch (e, st) {
      loadingText.add("错误 $e");
      loadingText.addAll("$st".split("\n").take(6));
      _isLoading = null;
      notifyListeners();
      _controller?.dispose();
      _controller = null;
      // _content = null;
      return;
    }
  }

  DateTime _lastNotifyTime;
  _listener() {
    _position = _controller.value.position;
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

      searchItem.durContentIndex = _controller.value.position.inMilliseconds;
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      SearchItemManager.saveSearchItem();
      notifyListeners();
    }
    if ((_controller.value.duration.inSeconds -
                _controller.value.position.inSeconds)
            .abs() <=
        1) {
      if (_chapterRoad == null) {
        final _end = searchItem.chapters.length;
        final _next = searchItem.durChapterIndex + 1;
        if (_next < _end) {
          parseContent(searchItem.durChapterIndex + 1);
        }
      } else {
        final _begin = _chapterRoad.startIndex;
        final _end = _begin + _chapterRoad.length;
        final _next = searchItem.durChapterIndex + 1;
        print("播放完毕,${_begin},${_end},${searchItem.durChapterIndex + 1}");
        if (_next < _end) {
          parseContent(searchItem.durChapterIndex + 1);
        }
      }

      // print("播放完毕,${_begin},${_end},${searchItem.durChapterIndex + 1}");
      // parseContent(searchItem.durChapterIndex + 1);
    }

    // print(
    //     "${_controller.value.position.inSeconds} - ${_controller.value.duration.inSeconds} ");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isIOS) {
      setVertical();
    }
    resetRotation();
    _disposed = true;
    if (controller != null) {
      searchItem.durContentIndex = _controller.value.position.inMilliseconds;
      controller.removeListener(_listener);
      controller.pause();
      controller.dispose();
    }
    () async {
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      await SearchItemManager.saveSearchItem();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
      await HistoryItemManager.saveHistoryItem();
    }();
    if (Platform.isIOS || Platform.isAndroid) {
      //DeviceDisplayBrightness.resetBrightness();
      ScreenBrightness().resetScreenBrightness();
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

  void setHorizontal() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    notifyListeners();
  }

  void setVertical() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    notifyListeners();
  }

  void openDLNA(BuildContext context) {
    if (_disposed || _content == null) return;
    _controllerTime = DateTime.now();
    String _url = _content[0];
    if (_content[0].contains("@headers")) {
      final u = _content[0].split("@headers");
      // final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
      _url = u[0];
    }
    DLNAUtil.instance.start(
      context,
      title: _titleText,
      url: _url,
      videoType: VideoObject.VIDEO_MP4,
      onPlay: playOrPause,
    );
  }

  void openInNew() {
    print("_disposed:${_disposed},_content:${_content}");

    if (_disposed || _content == null) return;
    _controllerTime = DateTime.now();
    String _url = _content[0];
    if (_content[0].contains("@headers")) {
      final u = _content[0].split("@headers");
      // final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
      _url = u[0];
    }

    launch(_url);
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

  Future<void> seek(Duration ps) async {
    _position = ps;
    await _controller.seekTo(ps);
  }

  static double _playSpeed = 1.0;
  double get playSpeed => _playSpeed;
  double _currentSpeed = 1.0;
  double get currentSpeed => _currentSpeed;

  void changeSpeed(double speed) async {
    if (speed == null) return;
    if (controller == null) {
      setHintText("请先播放视频");
      return;
    }
    if ((currentSpeed - speed).abs() > 0.1) {
      await controller.setPlaybackSpeed(speed);
      _currentSpeed = speed;
      _playSpeed = speed;
      setHintText("播放速度 $speed");
      notifyListeners();
    }
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
    _showController = true;
    if (_screenAxis == Axis.vertical) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }

    _controllerTime = DateTime.now();
  }

  void hideController() {
    _showController = false;
    if (_screenAxis == Axis.horizontal) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  VideoAspectRatio _aspectRatio = VideoAspectRatio.auto;

  VideoAspectRatio get aspectRatio => _aspectRatio;

  double _getAspectRatio() {
    var ar = _controller.value.aspectRatio ?? (16 / 9);
    if (ar == 1.0) {
      final s = _controller.value.size;
      if (s == null || s.width == 0 || s.height == 0) ar = 16 / 9;
    }
    return ar;
  }

  double getAspectRatio() {
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

  // void zoom() {
  //   // if (_disposed || isLoading) return;
  //   _controllerTime = DateTime.now();
  //   switch (_aspectRatio) {
  //     case VideoAspectRatio.auto:
  //       _aspectRatio = VideoAspectRatio.full;
  //       setHintText('充满');
  //       break;
  //     case VideoAspectRatio.full:
  //       _aspectRatio = VideoAspectRatio.a169;
  //       setHintText('16 : 9');
  //       break;
  //     case VideoAspectRatio.a169:
  //       _aspectRatio = VideoAspectRatio.a43;
  //       setHintText('4 : 3');
  //       break;
  //     case VideoAspectRatio.a43:
  //       _aspectRatio = VideoAspectRatio.a916;
  //       setHintText('9 : 16');
  //       break;
  //     case VideoAspectRatio.a916:
  //       _aspectRatio = VideoAspectRatio.auto;
  //       setHintText('自动');
  //       break;
  //     default:
  //       break;
  //   }
  // }

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
    seek(_gesturePosition).then((_) {
      if (Platform.isIOS) {
        Future.delayed(Duration(milliseconds: 1500), () {
          print("Horizontal:${_playSpeed}");
          controller.setPlaybackSpeed(_playSpeed);
        });
      }
    });
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
    double number = (_dragStartPosition - details.globalPosition.dy) / 100;
    if (details.globalPosition.dx <
        (_screenAxis == Axis.horizontal ? 400 : 200)) {
      IconData icon = OMIcons.brightnessLow;
      //var brightness = await DeviceDisplayBrightness.getBrightness();

      var brightness = await ScreenBrightness().current;

      print("brightness:${brightness}");
      if (brightness > 1) {
        brightness = 0.5;
      }
      brightness += number;
      if (brightness < 0) {
        brightness = 0.0;
      } else if (brightness > 1) {
        brightness = 1.0;
      }
      if (brightness <= 0.25) {
        icon = Icons.brightness_low;
      } else if (brightness < 0.5) {
        icon = Icons.brightness_medium;
      } else {
        icon = Icons.brightness_high;
      }
      setHintTextWithIcon(brightness, icon);
      try {
        print("brightness1:${brightness}");
        await ScreenBrightness().setScreenBrightness(brightness);

        //await DeviceDisplayBrightness.setBrightness(brightness);
      } catch (e) {
        print("错误: $e");
      }
    } else {
      IconData icon = OMIcons.volumeMute;
      var vol = _controller.value.volume + number;
      if (vol <= 0) {
        icon = OMIcons.volumeOff;
        vol = 0.0;
      } else if (vol < 0.2) {
        icon = OMIcons.volumeMute;
      } else if (vol < 0.7) {
        icon = OMIcons.volumeDown;
      } else {
        icon = OMIcons.volumeUp;
      }
      if (vol > 1) {
        vol = 1;
      }
      setHintTextWithIcon(vol, icon);
      await _controller.setVolume(vol);
    }

    /// 手势调节正常运作核心代码就是这句了
    _dragStartPosition = details.globalPosition.dy;
    _draging = false;
  }

  void onLongPress() async {
    if (controller == null) {
      setHintText("请先播放视频");
      return;
    }
    if (!controller.value.isPlaying) {
      return;
    }

    await HapticFeedback.lightImpact();
    double speed = 2.0;
    await controller.setPlaybackSpeed(speed);
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

    await controller.setPlaybackSpeed(_currentSpeed);
    _playSpeed = _currentSpeed;
    _islpSpeed = false;
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
