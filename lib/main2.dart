// import 'dart:io';

// import 'package:device_info/device_info.dart';
// import 'package:flutter/material.dart';
// import 'package:audio_service/audio_service.dart';
// import 'package:just_audio/just_audio.dart';

// class MyAudioHandler extends BaseAudioHandler with SeekHandler {
// // with QueueHandler, // mix in default queue callback implementations
// // mix in default seek callback implementations

//   final _player = AudioPlayer();
//   MyAudioHandler() {
//     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
//   }

//   static final _item = MediaItem(
//     id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
//     album: "Science Friday",
//     title: "A Salute To Head-Scratching Science",
//     artist: "Science Friday and WNYC Studios",
//     duration: const Duration(milliseconds: 5739820),
//     artUri: Uri.parse(
//         'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
//   );

//   PlaybackState _transformEvent(PlaybackEvent event) {
//     return PlaybackState(
//       controls: [
//         if (_player.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.skipToPrevious,
//         MediaControl.skipToNext,
//       ],
//       systemActions: const {
//         MediaAction.seek,
//       },
//       androidCompactActionIndices: const [0, 1, 2],
//       processingState: const {
//         ProcessingState.idle: AudioProcessingState.idle,
//         ProcessingState.loading: AudioProcessingState.loading,
//         ProcessingState.buffering: AudioProcessingState.buffering,
//         ProcessingState.ready: AudioProcessingState.ready,
//         ProcessingState.completed: AudioProcessingState.completed,
//       }[_player.processingState],
//       playing: _player.playing,
//       updatePosition: _player.position,
//       bufferedPosition: _player.bufferedPosition,
//       speed: _player.speed,
//       // queueIndex: event.currentIndex,
//     );
//   }

//   int get currentIndex => 0;

//   Future<void> loadAndPlay(String url) async {
//     await _player.stop();
//     await _player.setUrl(url, initialPosition: Duration.zero, preload: false);
//     play();
//   }

//   Future<void> playOrPause() async {
//     if (_player.playing)
//       return pause();
//     else
//       play();
//   }

//   @override
//   Future<void> play() => _player.play();

//   @override
//   Future<void> pause() => _player.pause();

//   @override
//   Future<void> seek(Duration position) => _player.seek(position);

//   @override
//   Future<void> stop() => _player.stop();
// }

// MyAudioHandler _audioHandler;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (Platform.isAndroid) {
//     final p = DeviceInfoPlugin();
//     final info = await p.androidInfo;
//     if (!info.isPhysicalDevice || info.supportedAbis.first.contains("x86")) {
//       _audioHandler = MyAudioHandler();
//     }
//   }
//   if (_audioHandler == null) {
//     _audioHandler = await AudioService.init(
//       builder: () => MyAudioHandler(),
//       config: AudioServiceConfig(
//         androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
//         androidNotificationChannelName: 'Music playback',
//       ),
//     );
//   }
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Material App',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Material App Bar'),
//         ),
//         body: Center(
//           child: Container(
//             child: Text('Hello World'),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             _audioHandler.loadAndPlay(
//                 "http://downsc.chinaz.net/Files/DownLoad/sound1/201906/11582.mp3");
//           },
//           child: Icon(Icons.plus_one),
//         ),
//       ),
//     );
//   }
// }
