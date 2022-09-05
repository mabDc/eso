// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:eso/model/audio_service%20copy.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_lyric/lyrics_reader.dart';
// // import 'package:audioplayers/audioplayers.dart';
// // import 'package:just_audio/just_audio.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/model/audio_page_controller_bak.dart';
// import 'package:eso/model/audio_service.dart';
// import 'package:eso/profile.dart';
// import 'package:eso/ui/ui_chapter_select.dart';
// import 'package:eso/ui/widgets/animation_rotate_view.dart';
// import 'package:eso/utils.dart';
// import 'package:eso/utils/flutter_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:outline_material_icons/outline_material_icons.dart';
// import 'package:rxdart/rxdart.dart';
// // import '../lyric/lyric.dart';
// // import '../lyric/lyric_widget.dart';
// // import '../lyric/lyric_controller.dart';
// import 'package:provider/provider.dart';
// import 'dart:math';

// import '../fonticons_icons.dart';
// import '../global.dart';

// class AudioPage extends StatefulWidget {
//   final SearchItem searchItem;

//   const AudioPage({
//     this.searchItem,
//     Key key,
//   }) : super(key: key);

//   @override
//   _AudioPageState createState() => _AudioPageState();
// }

// class _AudioPageState extends State<AudioPage> with TickerProviderStateMixin {
//   Widget _audioPage;
//   AudioPageController __provider;
//   SearchItem searchItem;
//   // LyricController _lyricController;
//   bool _showSelect = false;
//   final lyricUI = UINetease();
//   @override
//   void initState() {
//     // _lyricController = LyricController(vsync: this)
//     //   ..addListener(() {
//     //     if (_showSelect != _lyricController.isDragging) {
//     //       setState(() {
//     //         _showSelect = _lyricController.isDragging;
//     //       });
//     //     }
//     //   });
//     searchItem = widget.searchItem;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_audioPage == null) {
//       _audioPage = _buildPage();
//     }
//     return _audioPage;
//   }

//   @override
//   void dispose() {
//     __provider?.dispose();
//     // _lyricController?.dispose();
//     super.dispose();
//   }

//   Widget _buildPage() {
//     return ChangeNotifierProvider<AudioPageController>.value(
//       value: AudioPageController(searchItem: searchItem),
//       child: Consumer<AudioPageController>(
//         builder: (BuildContext context, AudioPageController provider, _) {
//           __provider = provider;

//           final chapter =
//               searchItem.chapters[provider.searchItem.durChapterIndex];

//           return Scaffold(
//             body: GestureDetector(
//               child: Container(
//                 height: double.infinity,
//                 width: double.infinity,
//                 child: Stack(
//                   children: <Widget>[
//                     Container(
//                       height: double.infinity,
//                       width: double.infinity,
//                       child: Utils.empty(chapter.cover)
//                           ? Image.asset(
//                               defaultImage,
//                               fit: BoxFit.cover,
//                             )
//                           : Image.network(
//                               chapter.cover.contains("@headers")
//                                   ? chapter.cover.split("@headers")[0]
//                                   : chapter.cover,
//                               headers: chapter.cover.contains("@headers")
//                                   ? (jsonDecode(chapter.cover
//                                           .split("@headers")[1]) as Map)
//                                       .map((k, v) => MapEntry('$k', '$v'))
//                                   : null,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, object, stack) {
//                                 return Image.asset(
//                                   defaultImage,
//                                   fit: BoxFit.cover,
//                                 );
//                               },
//                             ),
//                     ),
//                     BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                       child: Container(color: Colors.black.withAlpha(30)),
//                     ),
//                     SafeArea(
//                       child: Column(
//                         children: <Widget>[
//                           _buildAppBar(provider, chapter.name, chapter.time),
//                           if (provider.showLyric)
//                             if (provider.lyricModel == null ||
//                                 provider.positionDuration == null)
//                               Expanded(
//                                 child: InkWell(
//                                   onTap: provider.toggleLyric,
//                                   child: LyricsReader(
//                                     model: provider.lyricModel.getModel(),
//                                     size:
//                                         Size(double.infinity, double.infinity),
//                                     lyricUi: lyricUI,
//                                     playing: provider.isPlay,
//                                     emptyBuilder: () => Center(
//                                       child: Text(
//                                         "No lyrics",
//                                         style: lyricUI.getOtherMainTextStyle(),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             else
//                               () {
//                                 return Expanded(
//                                   child: Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Center(
//                                         child: LyricsReader(
//                                           // padding: EdgeInsets.symmetric(
//                                           //     horizontal: 40.0),
//                                           onTap: () {
//                                             provider.toggleLyric();
//                                           },
//                                           model: provider.lyricModel.getModel(),
//                                           position: provider
//                                               .positionDuration.inMilliseconds,
//                                           size: Size(
//                                               double.infinity, double.infinity),
//                                           lyricUi: lyricUI,
//                                           playing: provider.isPlay,
//                                           emptyBuilder: () => Center(
//                                             child: Text(
//                                               "No lyrics",
//                                               style: lyricUI
//                                                   .getOtherMainTextStyle(),
//                                             ),
//                                           ),
//                                           selectLineBuilder:
//                                               (progress, confirm) {
//                                             return Row(
//                                               children: [
//                                                 IconButton(
//                                                     onPressed: () {
//                                                       // print(
//                                                       //     "progress:${progress}");
//                                                       confirm.call();

//                                                       provider.seekDuration(
//                                                           Duration(
//                                                               milliseconds:
//                                                                   progress));
//                                                     },
//                                                     icon: Icon(Icons.play_arrow,
//                                                         color: Colors.green)),
//                                                 Expanded(
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                         color: Colors.green),
//                                                     height: 1,
//                                                     width: double.infinity,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   Duration(
//                                                           milliseconds:
//                                                               progress)
//                                                       .toString(),
//                                                   style: TextStyle(
//                                                       color: Colors.green),
//                                                 )
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       // Container(
//                                       //   alignment: Alignment.bottomCenter,
//                                       //   child: IconButton(
//                                       //       icon: Icon(
//                                       //         Icons.close_outlined,
//                                       //         color: Colors.white,
//                                       //         size: 30,
//                                       //       ),
//                                       //       tooltip: '关闭歌词',
//                                       //       onPressed: provider.toggleLyric),
//                                       // ),
//                                     ],
//                                   ),
//                                 );
//                               }()
//                           else
//                             Expanded(
//                               child: Tooltip(
//                                 message: '点击切换显示歌词',
//                                 child: Center(
//                                     child: SizedBox(
//                                   width: 300,
//                                   height: 300,
//                                   child: AnimationRotateView(
//                                     child: InkWell(
//                                       onTap: provider.toggleLyric,
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Utils.empty(chapter.cover)
//                                               ? Colors.black26
//                                               : null,
//                                           image: Utils.empty(chapter.cover)
//                                               ? null
//                                               : DecorationImage(
//                                                   image: NetworkImage(
//                                                     chapter.cover.contains(
//                                                             "@headers")
//                                                         ? chapter.cover.split(
//                                                             "@headers")[0]
//                                                         : chapter.cover,
//                                                     headers: chapter.cover
//                                                             .contains(
//                                                                 "@headers")
//                                                         ? (jsonDecode(chapter
//                                                                     .cover
//                                                                     .split(
//                                                                         "@headers")[
//                                                                 1]) as Map)
//                                                             .map((k, v) =>
//                                                                 MapEntry(
//                                                                     '$k', '$v'))
//                                                         : null,
//                                                   ),
//                                                   fit: BoxFit.contain,
//                                                 ),
//                                         ),
//                                         child: Utils.empty(chapter.cover)
//                                             ? Icon(Icons.audiotrack,
//                                                 color: Colors.white30,
//                                                 size: 200)
//                                             : null,
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                               ),
//                             ),
//                           SizedBox(height: 50),
//                           _buildProgressBar(provider),
//                           SizedBox(height: 10),
//                           _buildBottomPlayController(provider),
//                           SizedBox(height: 25),
//                           _buildBottomOtherController(provider),
//                           SizedBox(height: 25),
//                         ],
//                       ),
//                     ),
//                     if (!provider.showLyric)
//                       SafeArea(
//                         child: Center(
//                           child: Container(
//                             height: 300,
//                             alignment: Alignment.bottomCenter,
//                             child: DefaultTextStyle(
//                               style: TextStyle(
//                                 color: Colors.white54,
//                                 fontSize: 12,
//                                 fontFamily: Profile.staticFontFamily,
//                                 height: 1.75,
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(chapter.name,
//                                       style: TextStyle(fontSize: 15)),
//                                   Text(Utils.link(
//                                           searchItem.origin, searchItem.name,
//                                           divider: ' | ')
//                                       .link(searchItem.chapter)
//                                       .value),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     provider.showChapter
//                         ? UIChapterSelect(
//                             searchItem: searchItem,
//                             color: Colors.black38,
//                             fontColor: Colors.white70,
//                             border: BorderSide(
//                                 color: Colors.white10,
//                                 width: Global.borderSize),
//                             heightScale: 0.5,
//                             loadChapter: provider.loadChapter)
//                         : Container(),
//                   ],
//                 ),
//               ),
//               onTap: () {
//                 if (provider.showChapter == true) provider.showChapter = false;
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAppBar(
//       AudioPageController provider, String name, String author) {
//     final _iconTheme = Theme.of(context).primaryIconTheme;
//     final _textTheme = Theme.of(context).primaryTextTheme;
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0.0,
//       brightness: Brightness.dark,
//       iconTheme: _iconTheme.copyWith(color: Colors.white70),
//       textTheme: _textTheme.copyWith(
//           headline6: _textTheme.headline6.copyWith(color: Colors.white70)),
//       actionsIconTheme: _iconTheme.copyWith(color: Colors.white70),
//       actions: [
//         StatefulBuilder(
//           builder: (context, _state) {
//             bool isFav = SearchItemManager.isFavorite(
//                 searchItem.originTag, searchItem.url);
//             return IconButton(
//               icon: isFav ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
//               iconSize: 21,
//               tooltip: isFav ? "取消收藏" : "加入收藏",
//               onPressed: () async {
//                 await SearchItemManager.toggleFavorite(searchItem);
//                 _state(() => null);
//               },
//             );
//           },
//         ),
//         IconButton(
//           icon: Icon(FIcons.share_2),
//           tooltip: "分享",
//           onPressed: provider.share,
//         )
//       ],
//       titleSpacing: 0,
//       title: author == null || author.isEmpty
//           ? Text(
//               '$name',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.white70,
//               ),
//             )
//           : Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text(
//                   '$name',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 Text(
//                   '$author',
//                   maxLines: 1,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration, PositionData>(
//           AudioService().player.positionStream,
//           AudioService().player.bufferedPositionStream,
//           AudioService().player.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));

//   Widget _buildProgressBar(AudioPageController provider) {
//     return Row(
//       children: <Widget>[
//         // Container(
//         //   alignment: Alignment.centerRight,
//         //   child: Text(provider.positionDurationText,
//         //       style: TextStyle(color: Colors.white)),
//         //   width: 52,
//         // ),
//         Expanded(
//           child: StreamBuilder<PositionData>(
//             stream: _positionDataStream,
//             builder: (context, snapshot) {
//               final positionData = snapshot.data;
//               return SeekBar(
//                 duration: positionData?.duration ?? Duration.zero,
//                 position: positionData?.position ?? Duration.zero,
//                 bufferedPosition:
//                     positionData?.bufferedPosition ?? Duration.zero,
//                 onChangeEnd: (duration) {
//                   provider.seekDuration(duration);
//                 },
//                 //onChanged: provider.seek,
//               );
//             },
//           ),

//           // child: FlutterSlider(
//           //   values: [provider.postionSeconds.toDouble()],
//           //   max: provider.seconds.toDouble(),
//           //   min: 0,
//           //   onDragging: (handlerIndex, lowerValue, upperValue) =>
//           //       provider.seekSeconds((lowerValue as double).toInt()),
//           //   handlerHeight: 12,
//           //   handlerWidth: 12,
//           //   handler: FlutterSliderHandler(
//           //     child: Container(
//           //       width: 12,
//           //       height: 12,
//           //       alignment: Alignment.center,
//           //       child: Icon(Icons.audiotrack, color: Colors.red, size: 8),
//           //     ),
//           //   ),
//           //   trackBar: FlutterSliderTrackBar(
//           //     inactiveTrackBar: BoxDecoration(
//           //       borderRadius: BorderRadius.circular(20),
//           //       color: Colors.white54,
//           //     ),
//           //     activeTrackBar: BoxDecoration(
//           //       borderRadius: BorderRadius.circular(4),
//           //       color: Colors.white70,
//           //     ),
//           //   ),
//           //   tooltip: FlutterSliderTooltip(
//           //     disableAnimation: true,
//           //     custom: (value) => Container(
//           //       color: Colors.black12,
//           //       padding: EdgeInsets.all(4),
//           //       child: Text(
//           //         Utils.formatDuration(
//           //             Duration(seconds: (value as double).toInt())),
//           //         style: TextStyle(color: Colors.white),
//           //       ),
//           //     ),
//           //     positionOffset: FlutterSliderTooltipPositionOffset(
//           //         left: -10, right: -10, top: -10),
//           //   ),
//           // ),
//         ),
//         // Container(
//         //   alignment: Alignment.centerLeft,
//         //   child: Text(provider.durationText,
//         //       style: TextStyle(color: Colors.white)),
//         //   width: 52,
//         // ),
//       ],
//     );
//   }

//   Widget _buildBottomOtherController(AudioPageController provider) {
//     final _repeatMode = provider.repeatMode;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         IconButton(
//           icon: Icon(
//             _repeatMode == meidaRepeatMode.REPEAT_FAVORITE
//                 ? Icons.restore
//                 : _repeatMode == meidaRepeatMode.REPEAT_ALL
//                     ? Icons.repeat
//                     : _repeatMode == meidaRepeatMode.REPEAT_ONE
//                         ? Icons.repeat_one
//                         : Icons.label_outline,
//             color: Colors.white,
//           ),
//           iconSize: 26,
//           tooltip: getRepeatName(_repeatMode),
//           padding: EdgeInsets.zero,
//           onPressed: provider.switchRepeatMode,
//         ),
//         IconButton(
//           icon: Icon(
//             OMIcons.accessAlarms,
//             color: Colors.white,
//           ),
//           iconSize: 26,
//           tooltip: "定时",
//           onPressed: () {
//             List<String> timeString = [
//               "不开启",
//               "10分钟后",
//               "20分钟后",
//               "30分钟后",
//               "60分钟后",
//               "90分钟后",
//             ];
//             List<Duration> timeDuration = [
//               Duration.zero,
//               Duration(minutes: 10),
//               Duration(minutes: 20),
//               Duration(minutes: 30),
//               Duration(minutes: 40),
//               Duration(minutes: 50),
//             ];

//             // final primaryColor = Theme.of(context).bottomAppBarColor;

//             showCupertinoModalPopup(
//               context: context,
//               builder: (_) => CupertinoActionSheet(
//                 actions: List.generate(
//                   timeString.length,
//                   (index) {
//                     final quality = timeString[index];
//                     return CupertinoActionSheetAction(
//                       child: Text(
//                         "${quality}",
//                         style: TextStyle(
//                             color: provider.timerStop == timeDuration[index]
//                                 ? Colors.red
//                                 : null,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13),
//                       ),
//                       onPressed: () {
//                         provider.setStopDuration(timeDuration[index]);
//                         Navigator.pop(_);
//                         //provider.changeSpeed(quality);
//                       },
//                     );
//                   },
//                 ),
//                 cancelButton: CupertinoActionSheetAction(
//                   onPressed: () => Navigator.pop(_),
//                   child: Text("返回"),
//                   isDestructiveAction: true,
//                 ),
//               ),
//             );

//             //Timer.periodic(Duration(milliseconds: 1000), (timer) {});
//           },
//         ),

//         IconButton(
//           icon: Icon(
//             Icons.speed_outlined,
//             color: Colors.white,
//           ),
//           iconSize: 26,
//           tooltip: "倍速播放",
//           onPressed: () {
//             List<double> _speed = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

//             showCupertinoModalPopup(
//               context: context,
//               builder: (_) => CupertinoActionSheet(
//                 title: Text(
//                   "播放速度",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 actions: List.generate(
//                   _speed.length,
//                   (index) {
//                     final speed = _speed[index];
//                     return CupertinoActionSheetAction(
//                       child: Text(
//                         "${speed}",
//                         style: TextStyle(
//                             color: provider.playSpeed == _speed[index]
//                                 ? Colors.red
//                                 : null,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13),
//                       ),
//                       onPressed: () {
//                         provider.setSpeed(speed);

//                         Navigator.pop(_);
//                         //provider.changeSpeed(quality);
//                       },
//                     );
//                   },
//                 ),
//                 cancelButton: CupertinoActionSheetAction(
//                   onPressed: () => Navigator.pop(_),
//                   child: Text("返回"),
//                   isDestructiveAction: true,
//                 ),
//               ),
//             );
//           },
//         ),

//         // PopupMenuButton(
//         //   icon: Icon(
//         //     Icons.speed_outlined,
//         //     color: Colors.white,
//         //   ),
//         //   iconSize: 26,
//         //   tooltip: "倍速播放",
//         //   onSelected: (double speed) {
//         //     provider.setSpeed(speed);
//         //   },
//         //   itemBuilder: (BuildContext context) {
//         //     return <PopupMenuItem<double>>[
//         //       for (final double speed in [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0])
//         //         PopupMenuItem<double>(
//         //           value: speed,
//         //           child: Text(
//         //             '${speed}',
//         //             style: TextStyle(
//         //                 color: provider.playSpeed == speed
//         //                     ? Colors.blueAccent
//         //                     : Colors.black,
//         //                 fontWeight: FontWeight.bold),
//         //           ),
//         //         )
//         //     ];
//         //   },
//         // ),

//         IconButton(
//           icon: Icon(
//             Icons.menu,
//             color: Colors.white,
//           ),
//           iconSize: 26,
//           tooltip: "播放列表",
//           onPressed: () => provider.showChapter = !provider.showChapter,
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomPlayController(AudioPageController provider) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         IconButton(
//           icon: Icon(
//             OMIcons.replay10,
//             color: Colors.white,
//             size: 26,
//           ),
//           onPressed: provider.replay10s,
//           tooltip: '退后10s',
//         ),
//         IconButton(
//           icon: Icon(
//             Icons.fast_rewind_sharp,
//             color: Colors.white,
//             size: 26,
//           ),
//           onPressed: provider.playPrev,
//           tooltip: '上一曲',
//         ),
//         IconButton(
//           icon: Icon(
//             (provider.state != null ? provider.isPlay : false)
//                 ? OMIcons.pauseCircleFilled
//                 : OMIcons.playCircleFilled,
//             color: Colors.white,
//             size: 35,
//           ),
//           onPressed: provider.playOrPause,
//           tooltip: provider.isPlay ?? false ? '暂停' : '播放',
//         ),
//         IconButton(
//           icon: Icon(
//             Icons.fast_forward_sharp,
//             color: Colors.white,
//             size: 26,
//           ),
//           onPressed: provider.playNext,
//           tooltip: '下一曲',
//         ),
//         IconButton(
//           icon: Icon(
//             OMIcons.forward10,
//             color: Colors.white,
//             size: 26,
//           ),
//           onPressed: provider.forward10s,
//           tooltip: '前进10s',
//         ),
//       ],
//     );
//   }

//   final String defaultImage = _defaultBackgroundImage[
//       Random().nextInt(_defaultBackgroundImage.length * 3) %
//           _defaultBackgroundImage.length];

//   static const List<String> _defaultBackgroundImage = <String>[
//     'lib/assets/audioCover/cover1.jpeg',
//     'lib/assets/audioCover/cover2.jpeg',
//     'lib/assets/audioCover/cover3.jpeg',
//     'lib/assets/audioCover/cover4.jpeg',
//   ];
// }
