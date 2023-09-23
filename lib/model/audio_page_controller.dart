// import 'dart:async';

// import 'package:eso/database/search_item.dart';
// import 'package:eso/model/audio_service.dart';
// import 'package:eso/utils.dart';
// import 'package:flutter/material.dart';
// import '../lyric/lyric.dart';
// import 'package:share_plus/share_plus.dart';

// class AudioPageController with ChangeNotifier {
//   AudioService _audioService;
//   Timer _timer;
//   bool get isPlay => _audioService.playing;
//   Duration get positionDuration => _audioService.positionDuration;
//   int get seconds => _audioService.duration.inSeconds;
//   int get postionSeconds => _audioService.positionDuration.inSeconds;
//   String get durationText => _getTimeString(seconds);
//   String get positionDurationText => _getTimeString(postionSeconds);
//   int get repeatMode => _audioService.repeatMode;

//   bool _showChapter;
//   bool get showChapter => _showChapter;
//   set showChapter(bool value) {
//     if (_showChapter != value) {
//       _showChapter = value;
//       notifyListeners();
//     }
//   }

//   List<Lyric> get lyrics => _audioService?.lyrics;
//   bool _showLyric;
//   bool get showLyric => _showLyric;
//   void toggleLyric() {
//     _showLyric = !_showLyric;
//     notifyListeners();
//   }

//   AudioPageController({@required SearchItem searchItem}) {
//     // init
//     _audioService = AudioService();
//     _showLyric = false;
//     _showChapter = false;
//     _timer = Timer.periodic(Duration(milliseconds: 200), (_) {
//       notifyListeners();
//     });
//     // searchItem
//     // if (searchItem.chapters?.length == 0 &&
//     //     SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
//     //   searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
//     // }
//     _audioService.playChapter(searchItem.durChapterIndex, searchItem: searchItem);
//     _audioService.close = false;
//   }

//   void share() async {
//     Share.share("${_audioService.durChapter}\n${_audioService.url}");
//     // await FlutterShare.share(
//     //   title: '亦搜 eso',
//     //   text: '${_audioService.durChapter}\n${_audioService.url}',
//     //   //linkUrl: '${content?.first ?? ''}',
//     //   chooserTitle: '选择分享的应用',
//     // );
//   }

//   /// all -> all secends
//   String _getTimeString(int all) {
//     return Utils.formatDuration(Duration(seconds: all));
//   }

//   void switchRepeatMode() {
//     _audioService.switchRepeatMode();
//     notifyListeners();
//   }

//   void loadChapter(int index) {
//     _showChapter = false;
//     notifyListeners();
//     _audioService.playChapter(index);
//   }

//   void playPrev() {
//     _audioService.playPrev();
//   }

//   void playOrPause() async {
//     await _audioService.playOrPause();
//     notifyListeners();
//   }

//   void playNext() {
//     _audioService.playNext();
//   }

//   void seekSeconds(int seconds) async {
//     await _audioService.seek(Duration(seconds: seconds));
//     notifyListeners();
//   }

//   void update() {
//     notifyListeners();
//   }

//   @override
//   void dispose() async {
//     _timer?.cancel();
//     super.dispose();
//   }
// }
