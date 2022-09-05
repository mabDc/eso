// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:ui';
// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_lyric/lyrics_reader.dart';
// // import 'package:audioplayers/audioplayers.dart';
// // import 'package:just_audio/just_audio.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/model/audio_service.dart';
// import 'package:eso/profile.dart';
// import 'package:eso/ui/ui_chapter_select.dart';
// import 'package:eso/ui/widgets/animation_rotate_view.dart';
// import 'package:eso/utils.dart';
// import 'package:eso/utils/flutter_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';
// import 'package:outline_material_icons/outline_material_icons.dart';
// import 'package:rxdart/rxdart.dart';
// // import '../lyric/lyric.dart';
// // import '../lyric/lyric_widget.dart';
// // import '../lyric/lyric_controller.dart';
// import 'package:provider/provider.dart';

// import 'package:audio_session/audio_session.dart';
// import 'package:share_plus/share_plus.dart';
// import '../fonticons_icons.dart';
// import '../global.dart';

// enum meidaRepeatMode {
//   REPEAT_FAVORITE,
//   REPEAT_ALL,
//   REPEAT_ONE,
//   REPEAT_NONE,
// }

// class esoAudioPlayer {
//   static AudioPlayer player = AudioPlayer();
// }

// class AudioPage extends StatefulWidget {
//   final SearchItem searchItem;

//   const AudioPage({
//     this.searchItem,
//     Key key,
//   }) : super(key: key);

//   @override
//   _AudioPageState createState() => _AudioPageState();
// }

// class _AudioPageState extends State<AudioPage> {
//   Widget _audioPage;
//   SearchItem searchItem;
//   LyricsModelBuilder lyricModel;
//   meidaRepeatMode repeatMode;
//   bool showLyric = false;
//   Duration playPosition = Duration.zero;
//   Duration playDuration = Duration.zero;
//   Duration timerStop = Duration.zero;
//   bool showChapter = false;
//   double playSpeed = 1.0;
//   int durChapterIndex = -1;

//   final lyricUI = UINetease();
//   @override
//   void initState() {
//     super.initState();
//     lyricModel = LyricsModelBuilder.create();
//     repeatMode = meidaRepeatMode.REPEAT_ALL;
//     searchItem = widget.searchItem;
//     showChapter = false;
//     _init();
//   }

//   Future<void> _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//     // Listen to errors during playback.
//     esoAudioPlayer.player.playbackEventStream.listen((event) {},
//         onError: (Object e, StackTrace stackTrace) {
//       print('A stream error occurred: $e');
//     });
//     playChapter(searchItem.durChapterIndex, searchItem: searchItem);
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
//     lyricModel.reset();

//     // _lyricController?.dispose();
//     super.dispose();
//   }

//   Widget _buildPage() {
//     final chapter = searchItem.chapters[searchItem.durChapterIndex];

//     return Scaffold(
//       body: GestureDetector(
//         child: Container(
//           height: double.infinity,
//           width: double.infinity,
//           child: Stack(
//             children: <Widget>[
//               Container(
//                 height: double.infinity,
//                 width: double.infinity,
//                 child: Utils.empty(chapter.cover)
//                     ? Image.asset(
//                         defaultImage,
//                         fit: BoxFit.cover,
//                       )
//                     : Image.network(
//                         chapter.cover.contains("@headers")
//                             ? chapter.cover.split("@headers")[0]
//                             : chapter.cover,
//                         headers: chapter.cover.contains("@headers")
//                             ? (jsonDecode(chapter.cover.split("@headers")[1])
//                                     as Map)
//                                 .map((k, v) => MapEntry('$k', '$v'))
//                             : null,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, object, stack) {
//                           return Image.asset(
//                             defaultImage,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//               ),
//               BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                 child: Container(color: Colors.black.withAlpha(30)),
//               ),
//               SafeArea(
//                 child: Column(
//                   children: <Widget>[
//                     _buildAppBar(chapter.name, chapter.time),
//                     if (showLyric)
//                       if (lyricModel == null)
//                         Expanded(
//                           child: InkWell(
//                             onTap: toggleLyric,
//                             child: LyricsReader(
//                               model: lyricModel.getModel(),
//                               size: Size(double.infinity, double.infinity),
//                               lyricUi: lyricUI,
//                               playing: esoAudioPlayer.player.playing,
//                               emptyBuilder: () => Center(
//                                 child: Text(
//                                   "No lyrics",
//                                   style: lyricUI.getOtherMainTextStyle(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                       else
//                         () {
//                           print("object");
//                           return Expanded(
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Center(
//                                   child: LyricsReader(
//                                     // padding: EdgeInsets.symmetric(
//                                     //     horizontal: 40.0),
//                                     onTap: () {
//                                       toggleLyric();
//                                     },
//                                     model: lyricModel.getModel(),
//                                     position: playPosition.inMilliseconds,
//                                     size:
//                                         Size(double.infinity, double.infinity),
//                                     lyricUi: lyricUI,
//                                     playing: esoAudioPlayer.player.playing,
//                                     emptyBuilder: () => Center(
//                                       child: Text(
//                                         "No lyrics",
//                                         style: lyricUI.getOtherMainTextStyle(),
//                                       ),
//                                     ),
//                                     selectLineBuilder: (progress, confirm) {
//                                       return Row(
//                                         children: [
//                                           IconButton(
//                                               onPressed: () {
//                                                 // print(
//                                                 //     "progress:${progress}");
//                                                 confirm.call();
//                                                 esoAudioPlayer.player.seek(
//                                                     Duration(
//                                                         milliseconds:
//                                                             progress));
//                                               },
//                                               icon: Icon(Icons.play_arrow,
//                                                   color: Colors.green)),
//                                           Expanded(
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                   color: Colors.green),
//                                               height: 1,
//                                               width: double.infinity,
//                                             ),
//                                           ),
//                                           Text(
//                                             Duration(milliseconds: progress)
//                                                 .toString(),
//                                             style:
//                                                 TextStyle(color: Colors.green),
//                                           )
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }()
//                     else
//                       Expanded(
//                         child: Tooltip(
//                           message: '点击切换显示歌词',
//                           child: Center(
//                               child: SizedBox(
//                             width: 300,
//                             height: 300,
//                             child: AnimationRotateView(
//                               child: InkWell(
//                                 onTap: () {
//                                   toggleLyric();
//                                   print("showLyric:${showLyric}");
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Utils.empty(chapter.cover)
//                                         ? Colors.black26
//                                         : null,
//                                     image: Utils.empty(chapter.cover)
//                                         ? null
//                                         : DecorationImage(
//                                             image: NetworkImage(
//                                               chapter.cover.contains("@headers")
//                                                   ? chapter.cover
//                                                       .split("@headers")[0]
//                                                   : chapter.cover,
//                                               headers: chapter.cover
//                                                       .contains("@headers")
//                                                   ? (jsonDecode(chapter.cover
//                                                               .split(
//                                                                   "@headers")[
//                                                           1]) as Map)
//                                                       .map((k, v) =>
//                                                           MapEntry('$k', '$v'))
//                                                   : null,
//                                             ),
//                                             fit: BoxFit.contain,
//                                           ),
//                                   ),
//                                   child: Utils.empty(chapter.cover)
//                                       ? Icon(Icons.audiotrack,
//                                           color: Colors.white30, size: 200)
//                                       : null,
//                                 ),
//                               ),
//                             ),
//                           )),
//                         ),
//                       ),
//                     SizedBox(height: 50),
//                     _buildProgressBar(),
//                     SizedBox(height: 10),
//                     _buildBottomPlayController(),
//                     SizedBox(height: 25),
//                     _buildBottomOtherController(),
//                     SizedBox(height: 25),
//                   ],
//                 ),
//               ),
//               if (!showLyric)
//                 SafeArea(
//                   child: Center(
//                     child: Container(
//                       height: 300,
//                       alignment: Alignment.bottomCenter,
//                       child: DefaultTextStyle(
//                         style: TextStyle(
//                           color: Colors.white54,
//                           fontSize: 12,
//                           fontFamily: Profile.staticFontFamily,
//                           height: 1.75,
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(chapter.name, style: TextStyle(fontSize: 15)),
//                             Text(Utils.link(searchItem.origin, searchItem.name,
//                                     divider: ' | ')
//                                 .link(searchItem.chapter)
//                                 .value),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               showChapter
//                   ? UIChapterSelect(
//                       searchItem: searchItem,
//                       color: Colors.black38,
//                       fontColor: Colors.white70,
//                       border: BorderSide(
//                           color: Colors.white10, width: Global.borderSize),
//                       heightScale: 0.5,
//                       loadChapter: loadChapter)
//                   : Container(),
//             ],
//           ),
//         ),
//         onTap: () {
//           if (showChapter == true) showChapter = false;
//           setState(() {});
//         },
//       ),
//     );
//   }

//   Widget _buildAppBar(String name, String author) {
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
//           onPressed: share,
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
//           esoAudioPlayer.player.positionStream,
//           esoAudioPlayer.player.bufferedPositionStream,
//           esoAudioPlayer.player.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));

//   Widget _buildProgressBar() {
//     return Row(
//       children: <Widget>[
//         Expanded(
//           child: StreamBuilder<PositionData>(
//             stream: _positionDataStream,
//             builder: (context, snapshot) {
//               final positionData = snapshot.data;

//               print("positionData:${positionData}");
//               return SeekBar(
//                 duration: positionData?.duration ?? Duration.zero,
//                 position: positionData?.position ?? Duration.zero,
//                 bufferedPosition:
//                     positionData?.bufferedPosition ?? Duration.zero,
//                 onChangeEnd: (duration) {
//                   esoAudioPlayer.player.seek(duration);
//                 },
//                 //onChanged: provider.seek,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomOtherController() {
//     final _repeatMode = repeatMode;
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
//           onPressed: () {
//             switchRepeatMode();
//           },
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
//                             color: timerStop == timeDuration[index]
//                                 ? Colors.red
//                                 : null,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13),
//                       ),
//                       onPressed: () {
//                         esoAudioPlayer.player.seek(timeDuration[index]);

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
//                             color:
//                                 playSpeed == _speed[index] ? Colors.red : null,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13),
//                       ),
//                       onPressed: () {
//                         esoAudioPlayer.player.setSpeed(speed);

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
//         IconButton(
//           icon: Icon(
//             Icons.menu,
//             color: Colors.white,
//           ),
//           iconSize: 26,
//           tooltip: "播放列表",
//           onPressed: () => this.setState(() {
//             showChapter = !showChapter;
//           }),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomPlayController() {
//     return StreamBuilder<PlayerState>(
//       stream: esoAudioPlayer.player.playerStateStream,
//       builder: (context, snapshot) {
//         final playerState = snapshot.data;
//         final processingState = playerState?.processingState;
//         final playing = playerState?.playing;
//         final playloading = processingState == ProcessingState.loading ||
//             processingState == ProcessingState.buffering ||
//             playerState == null;
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             IconButton(
//               icon: Icon(
//                 OMIcons.replay10,
//                 color: Colors.white,
//                 size: 26,
//               ),
//               onPressed: replay10s,
//               tooltip: '退后10s',
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.fast_rewind_sharp,
//                 color: Colors.white,
//                 size: 26,
//               ),
//               onPressed: playPrev,
//               tooltip: '上一曲',
//             ),
//             Stack(
//               children: [
//                 if (playloading)
//                   Container(
//                     margin: const EdgeInsets.all(8.0),
//                     width: 35.0,
//                     height: 35.0,
//                     child: const CircularProgressIndicator(),
//                   ),
//                 IconButton(
//                   icon: Icon(
//                     (playing ?? false)
//                         ? OMIcons.pauseCircleFilled
//                         : OMIcons.playCircleFilled,
//                     color: Colors.white,
//                     size: 35,
//                   ),
//                   onPressed: () async {
//                     if (!playloading) {
//                       if (playing) {
//                         esoAudioPlayer.player.pause();
//                       } else {
//                         esoAudioPlayer.player.play();
//                       }
//                     }
//                   },
//                   tooltip: (playing ?? false) ? '暂停' : '播放',
//                 ),
//               ],
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.fast_forward_sharp,
//                 color: Colors.white,
//                 size: 26,
//               ),
//               onPressed: playNext,
//               tooltip: '下一曲',
//             ),
//             IconButton(
//               icon: Icon(
//                 OMIcons.forward10,
//                 color: Colors.white,
//                 size: 26,
//               ),
//               onPressed: forward10s,
//               tooltip: '前进10s',
//             ),
//           ],
//         );
//       },
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

//   void share() {
//     Share.share("${searchItem.durChapter}\n${playUrl}");
//   }

//   void toggleLyric() {
//     showLyric = !showLyric;
//     print("showLyric:${showLyric}");

//     setState(() {});
//   }

//   String playUrl = "";

//   void switchRepeatMode() {
//     if (repeatMode == meidaRepeatMode.REPEAT_FAVORITE) {
//       repeatMode = meidaRepeatMode.REPEAT_ALL;
//     } else if (repeatMode == meidaRepeatMode.REPEAT_ALL) {
//       repeatMode = meidaRepeatMode.REPEAT_ONE;
//     } else if (repeatMode == meidaRepeatMode.REPEAT_ONE) {
//       repeatMode = meidaRepeatMode.REPEAT_NONE;
//     } else if (repeatMode == meidaRepeatMode.REPEAT_NONE) {
//       repeatMode = meidaRepeatMode.REPEAT_FAVORITE;
//     }
//     setState(() {});
//   }

//   Future<void> play() async {
//     switch (esoAudioPlayer.player.processingState) {
//       case ProcessingState.completed:
//         return replay();
//         break;
//       // case PlayerState.PAUSED:
//       //   return _player.resume();
//       default:
//         return await esoAudioPlayer.player.play();
//     }
//   }

//   Future<void> playChapter(int chapterIndex,
//       {SearchItem searchItem, bool tryNext = false}) async {
//     if (searchItem == null) {
//       if (chapterIndex < 0 || chapterIndex >= searchItem.chapters.length)
//         return;
//       if (playUrl != null && searchItem.durChapterIndex == chapterIndex) {
//         print("replay");
//         replay();
//         return;
//       }
//     } else if (searchItem == null ||
//         (searchItem.chapterUrl != searchItem.chapterUrl)) {
//       print("_searchItem != searchItem");
//       searchItem = searchItem;
//     } else if (durChapterIndex == chapterIndex) {
//       print(
//           "if _durChapterIndex:${durChapterIndex} == chapterIndex:${chapterIndex}");
//       play();
//       return;
//     }

//     try {
//       // print("_player.pause();");
//       esoAudioPlayer.player.pause();
//       //await esoAudioPlayer.player.seek(Duration.zero);
//     } catch (e) {}

//     //esoAudioPlayer.player.stop();
//     durChapterIndex = chapterIndex;
//     print(
//         "_durChapterIndex:${durChapterIndex} == chapterIndex:${chapterIndex}");

//     if (searchItem.chapters == null || searchItem.chapters.isEmpty) return;
//     final content = await APIManager.getContent(
//         searchItem.originTag, searchItem.chapters[chapterIndex].url);
//     if (content == null || content.length == 0) return;
//     playUrl = content[0];
//     lyricModel?.reset();

//     print("content:${content}");

//     for (final c in content.skip(1)) {
//       if (c.startsWith('@cover')) {
//         searchItem.chapters[chapterIndex].cover = c.substring(6);
//       }
//       if (c.startsWith('@lrc')) {
//         lyricModel = lyricModel.bindLyricToMain(c.substring(4));
//       }
//     }
//     if (searchItem.chapters[chapterIndex].cover.isEmpty) {
//       searchItem.chapters[chapterIndex].cover = searchItem.cover;
//     }
//     print("cover:${searchItem.chapters[chapterIndex].cover}");

//     searchItem.durChapterIndex = chapterIndex;
//     searchItem.durChapter = searchItem.chapters[chapterIndex].name;
//     searchItem.durContentIndex = 1;
//     searchItem.lastReadTime = DateTime.now().millisecondsSinceEpoch;
//     await SearchItemManager.saveSearchItem();
//     HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
//     await HistoryItemManager.saveHistoryItem();
//     print(playUrl);
//     try {
//       if (playUrl.contains("@headers")) {
//         final u = playUrl.split("@headers");
//         final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//         print("url:${u[0]},headers:${h}");
//         String coverUrl = searchItem.chapters[chapterIndex].cover;
//         Map<String, String> coverHeaders = {};

//         if (searchItem.chapters[chapterIndex].cover.contains("@headers")) {
//           final cu = searchItem.chapters[chapterIndex].cover.split("@headers");
//           final ch =
//               (jsonDecode(cu[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//           coverUrl = cu[0];
//           coverHeaders = ch;
//         }
//         print("coverUrl:${coverUrl},coverHeaders:${coverHeaders}");
//         esoAudioPlayer.player.setAudioSource(
//           AudioSource.uri(
//             Uri.parse(u[0]),
//             headers: h,
//             tag: MediaItem(
//               id: u[0],
//               album: searchItem.chapter,
//               title: searchItem.durChapter,
//               artUri: Uri.parse(coverUrl),
//               artHeaders: coverHeaders,
//             ),
//           ),
//         );
//       } else {
//         await esoAudioPlayer.player
//             .setAudioSource(AudioSource.uri(Uri.parse(playUrl)));
//       }

//       await esoAudioPlayer.player.setSpeed(playSpeed);
//       //_player.load();
//       await esoAudioPlayer.player.play();
//     } catch (e) {
//       print(e);
//       if (tryNext == true) {
//         await Utils.sleep(3000);
//         if (esoAudioPlayer.player.playing) playNext();
//       }
//     }
//     setState(() {});
//   }

//   void replay() async {
//     await esoAudioPlayer.player.pause();
//     await esoAudioPlayer.player.seek(Duration.zero);
//     esoAudioPlayer.player.play();
//   }

//   void replay10s() async {
//     if (esoAudioPlayer.player.playing) {
//       await esoAudioPlayer.player.seek(
//         Duration(seconds: esoAudioPlayer.player.position.inSeconds - 10),
//       );
//     }
//   }

//   void forward10s() async {
//     if (esoAudioPlayer.player.playing) {
//       await esoAudioPlayer.player.seek(
//         Duration(seconds: esoAudioPlayer.player.position.inSeconds + 10),
//       );
//     }
//   }

//   void playNext([bool allFavorite = false]) {
//     if (searchItem.durChapterIndex == (searchItem.chapters.length - 1)) {
//       if (allFavorite != true) {
//         playChapter(0);
//       }
//     } else {
//       playChapter(searchItem.durChapterIndex + 1);
//     }
//   }

//   void playPrev() => playChapter(searchItem.durChapterIndex == 0
//       ? searchItem.chapters.length - 1
//       : searchItem.durChapterIndex - 1);

//   void loadChapter(int index) {
//     showChapter = false;
//     playChapter(index);
//     setState(() {});
//   }
// }

// class SeekBar extends StatefulWidget {
//   final Duration duration;
//   final Duration position;
//   final Duration bufferedPosition;
//   final ValueChanged<Duration> onChanged;
//   final ValueChanged<Duration> onChangeEnd;

//   const SeekBar({
//     Key key,
//     @required this.duration,
//     @required this.position,
//     @required this.bufferedPosition,
//     this.onChanged,
//     this.onChangeEnd,
//   }) : super(key: key);

//   @override
//   SeekBarState createState() => SeekBarState();
// }

// class SeekBarState extends State<SeekBar> {
//   double _dragValue;
//   SliderThemeData _sliderThemeData;
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     _sliderThemeData = SliderTheme.of(context).copyWith(
//       trackHeight: 2.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             thumbShape: HiddenThumbComponentShape(),
//             activeTrackColor: Colors.blue.shade100,
//             inactiveTrackColor: Colors.grey.shade300,
//           ),
//           child: ExcludeSemantics(
//             child: Slider(
//               min: 0.0,
//               max: widget.duration.inMilliseconds.toDouble(),
//               value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
//                   widget.duration.inMilliseconds.toDouble()),
//               onChanged: (value) {
//                 setState(() {
//                   _dragValue = value;
//                 });
//                 if (widget.onChanged != null) {
//                   widget.onChanged(Duration(milliseconds: value.round()));
//                 }
//               },
//               onChangeEnd: (value) {
//                 if (widget.onChangeEnd != null) {
//                   widget.onChangeEnd(Duration(milliseconds: value.round()));
//                 }
//                 _dragValue = null;
//               },
//             ),
//           ),
//         ),
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             inactiveTrackColor: Colors.transparent,
//           ),
//           child: Slider(
//             min: 0.0,
//             max: widget.duration.inMilliseconds.toDouble(),
//             value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
//                 widget.duration.inMilliseconds.toDouble()),
//             onChanged: (value) {
//               setState(() {
//                 _dragValue = value;
//               });
//               if (widget.onChanged != null) {
//                 widget.onChanged(Duration(milliseconds: value.round()));
//               }
//             },
//             onChangeEnd: (value) {
//               if (widget.onChangeEnd != null) {
//                 widget.onChangeEnd(Duration(milliseconds: value.round()));
//               }
//               _dragValue = null;
//             },
//           ),
//         ),
//         Positioned(
//           right: 16.0,
//           bottom: 0.0,
//           child: Text(
//               RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                       .firstMatch("$_remaining")
//                       ?.group(1) ??
//                   '$_remaining',
//               style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Duration get _remaining => widget.duration - widget.position;
// }

// class HiddenThumbComponentShape extends SliderComponentShape {
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     @required Animation<double> activationAnimation,
//     @required Animation<double> enableAnimation,
//     @required bool isDiscrete,
//     @required TextPainter labelPainter,
//     @required RenderBox parentBox,
//     @required SliderThemeData sliderTheme,
//     @required TextDirection textDirection,
//     @required double value,
//     @required double textScaleFactor,
//     @required Size sizeWithOverflow,
//   }) {}
// }

// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;

//   PositionData(this.position, this.bufferedPosition, this.duration);
// }

// String getRepeatName(meidaRepeatMode value) {
//   switch (value) {
//     case meidaRepeatMode.REPEAT_FAVORITE:
//       return "跨源循环";
//     case meidaRepeatMode.REPEAT_ALL:
//       return "列表循环";
//     case meidaRepeatMode.REPEAT_ONE:
//       return "单曲循环";
//     case meidaRepeatMode.REPEAT_NONE:
//       return "不循环";
//   }
//   return null;
// }
