// import 'dart:ui';

// // import 'package:audioplayers/audioplayers.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/model/audio_page_controller.dart';
// import 'package:eso/model/audio_service.dart';
// import 'package:eso/eso_theme.dart';
// import 'package:eso/ui/ui_chapter_select.dart';
// import 'package:eso/ui/widgets/animation_rotate_view.dart';
// import 'package:eso/utils.dart';
// import 'package:eso/utils/flutter_slider.dart';
// import 'package:flutter/material.dart';
// import '../lyric/lyric.dart';
// import '../lyric/lyric_widget.dart';
// import '../lyric/lyric_controller.dart';
// import 'package:provider/provider.dart';
// import 'dart:math';

// import '../fonticons_icons.dart';
// import '../global.dart';
// import 'hidden/linyuan_page.dart';

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
//   LyricController _lyricController;
//   bool _showSelect = false;
//   @override
//   void initState() {
//     _lyricController = LyricController(vsync: this)
//       ..addListener(() {
//         if (_showSelect != _lyricController.isDragging) {
//           setState(() {
//             _showSelect = _lyricController.isDragging;
//           });
//         }
//       });
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
//     _lyricController?.dispose();
//     super.dispose();
//   }

//   Widget _buildPage() {
//     return ChangeNotifierProvider<AudioPageController>.value(
//       value: AudioPageController(searchItem: searchItem),
//       child: Consumer<AudioPageController>(
//         builder: (BuildContext context, AudioPageController provider, _) {
//           __provider = provider;
//           final chapter = searchItem.chapters[searchItem.durChapterIndex];
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
//                       child: Image.network(
//                         Utils.empty(chapter.cover) ? defaultImage : chapter.cover,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                       child: Container(color: Colors.black.withAlpha(80)),
//                     ),
//                     SafeArea(
//                       child: Column(
//                         children: <Widget>[
//                           _buildAppBar(provider, chapter.name, chapter.time),
//                           if (provider.showLyric)
//                             if (provider.lyrics == null ||
//                                 provider.positionDuration == null)
//                               Expanded(
//                                 child: InkWell(
//                                   onTap: provider.toggleLyric,
//                                   child: LyricWidget(
//                                     size: Size(double.infinity, double.infinity),
//                                     controller: _lyricController,
//                                     lyricStyle: TextStyle(color: Colors.white),
//                                     lyrics: <Lyric>[
//                                       Lyric(
//                                         '加载中...',
//                                         startTime: Duration.zero,
//                                         endTime: Duration.zero,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             else
//                               () {
//                                 _lyricController.progress = provider.positionDuration;
//                                 return Expanded(
//                                   child: Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Center(
//                                         child: LyricWidget(
//                                           size: Size(double.infinity, double.infinity),
//                                           controller: _lyricController,
//                                           lyrics: provider.lyrics,
//                                           lyricStyle: TextStyle(
//                                               color: Colors.white, fontSize: 16),
//                                           currLyricStyle:
//                                               TextStyle(color: Colors.red, fontSize: 18),
//                                         ),
//                                       ),
//                                       Container(
//                                         alignment: Alignment.bottomCenter,
//                                         child: IconButton(
//                                             icon: Icon(
//                                               Icons.close_outlined,
//                                               color: Colors.white,
//                                               size: 30,
//                                             ),
//                                             tooltip: '关闭歌词',
//                                             onPressed: provider.toggleLyric),
//                                       ),
//                                       Offstage(
//                                         offstage: !_showSelect,
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             //点击选择器后移动歌词到滑动位置;
//                                             _lyricController.draggingComplete();
//                                             provider.seekSeconds(_lyricController
//                                                 .draggingProgress.inSeconds);
//                                           },
//                                           child: Row(
//                                             children: <Widget>[
//                                               Icon(
//                                                 Icons.play_circle_outline,
//                                                 color: Colors.green,
//                                                 size: 30,
//                                               ),
//                                               Expanded(
//                                                 child: Divider(
//                                                   color: Colors.red,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
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
//                                                   image:
//                                                       NetworkImage(chapter.cover ?? ''),
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                         ),
//                                         child: Utils.empty(chapter.cover)
//                                             ? Icon(Icons.audiotrack,
//                                                 color: Colors.white30, size: 200)
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
//                           _buildBottomController(provider),
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
//                                 fontFamily: ESOTheme.staticFontFamily,
//                                 height: 1.75,
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(chapter.name, style: TextStyle(fontSize: 15)),
//                                   Text(Utils.link(searchItem.origin, searchItem.name,
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
//                                 color: Colors.white10, width: Global.borderSize),
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

//   Widget _buildAppBar(AudioPageController provider, String name, String author) {
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
//             bool isFav =
//                 SearchItemManager.isFavorite(searchItem.originTag, searchItem.url);
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
//           onPressed: () {
//             Utils.startPageWait(
//                 context,
//                 LaunchUrlWithWebview(
//                   title: Utils.link(searchItem.origin, searchItem.name, divider: ' | ')
//                       .link(searchItem.durChapter)
//                       .value,
//                   url: searchItem.chapters[searchItem.durChapterIndex].url,
//                 ));
//           },
//           icon: Icon(FIcons.book_open),
//           tooltip: "在浏览器打开",
//         ),
//         IconButton(
//           icon: Icon(FIcons.share_2),
//           tooltip: "分享",
//           onPressed: provider.share,
//         ),
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

//   Widget _buildProgressBar(AudioPageController provider) {
//     return Row(
//       children: <Widget>[
//         Container(
//           alignment: Alignment.centerRight,
//           child:
//               Text(provider.positionDurationText, style: TextStyle(color: Colors.white)),
//           width: 52,
//         ),
//         Expanded(
//           child: FlutterSlider(
//             values: [provider.postionSeconds.toDouble()],
//             max: provider.seconds.toDouble() < 1 ? 1 : provider.seconds.toDouble(),
//             min: 0,
//             onDragging: (handlerIndex, lowerValue, upperValue) =>
//                 provider.seekSeconds((lowerValue as double).toInt()),
//             handlerHeight: 12,
//             handlerWidth: 12,
//             handler: FlutterSliderHandler(
//               child: Container(
//                 width: 12,
//                 height: 12,
//                 alignment: Alignment.center,
//                 child: Icon(Icons.audiotrack, color: Colors.red, size: 8),
//               ),
//             ),
//             trackBar: FlutterSliderTrackBar(
//               inactiveTrackBar: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Colors.white54,
//               ),
//               activeTrackBar: BoxDecoration(
//                 borderRadius: BorderRadius.circular(4),
//                 color: Colors.white70,
//               ),
//             ),
//             tooltip: FlutterSliderTooltip(
//               disableAnimation: true,
//               custom: (value) => Container(
//                 color: Colors.black12,
//                 padding: EdgeInsets.all(4),
//                 child: Text(
//                   Utils.formatDuration(Duration(seconds: (value as double).toInt())),
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               positionOffset:
//                   FlutterSliderTooltipPositionOffset(left: -10, right: -10, top: -10),
//             ),
//           ),
//         ),
//         Container(
//           alignment: Alignment.centerLeft,
//           child: Text(provider.durationText, style: TextStyle(color: Colors.white)),
//           width: 52,
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomController(AudioPageController provider) {
//     final _repeatMode = provider.repeatMode;
//     return Container(
//       height: 50,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           IconButton(
//             icon: Icon(
//               _repeatMode == AudioService.REPEAT_FAVORITE
//                   ? Icons.restore
//                   : _repeatMode == AudioService.REPEAT_ALL
//                       ? Icons.repeat
//                       : _repeatMode == AudioService.REPEAT_ONE
//                           ? Icons.repeat_one
//                           : Icons.label_outline,
//               color: Colors.white,
//             ),
//             iconSize: 26,
//             tooltip: AudioService.getRepeatName(_repeatMode),
//             padding: EdgeInsets.zero,
//             onPressed: provider.switchRepeatMode,
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.skip_previous,
//               color: Colors.white,
//               size: 26,
//             ),
//             onPressed: provider.playPrev,
//             tooltip: '上一曲',
//           ),
//           IconButton(
//             padding: EdgeInsets.zero,
//             icon: Icon(
//               provider.isPlay
//                   ? Icons.pause_circle_outline
//                   : Icons.play_circle_outline,
//               color: Colors.white,
//               size: 46,
//             ),
//             onPressed: provider.playOrPause,
//             tooltip: provider.isPlay ? '暂停' : '播放',
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.skip_next,
//               color: Colors.white,
//               size: 26,
//             ),
//             onPressed: provider.playNext,
//             tooltip: '下一曲',
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.menu,
//               color: Colors.white,
//             ),
//             iconSize: 26,
//             tooltip: "播放列表",
//             onPressed: () => provider.showChapter = !provider.showChapter,
//           ),
//         ],
//       ),
//     );
//   }

//   final String defaultImage = _defaultBackgroundImage[
//       Random().nextInt(_defaultBackgroundImage.length * 3) %
//           _defaultBackgroundImage.length];

//   static const List<String> _defaultBackgroundImage = <String>[
//     "http://api.nmb.show/xiaojiejie1.php"
//   ];
// }
