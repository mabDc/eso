// import 'dart:convert';

// import 'package:audio_service/audio_service.dart';
// import 'package:eso/model/audio_service_handler.dart';
// import 'package:eso/page/audio_page.dart';
// import 'package:eso/ui/widgets/animation_rotate_view.dart';
// import 'package:eso/utils.dart';
// import 'package:flutter/material.dart';

// class UIAudioView extends StatefulWidget {
//   final BuildContext context;

//   const UIAudioView({this.context, Key key}) : super(key: key);

//   @override
//   State<UIAudioView> createState() => _UIAudioViewState();
// }

// class _UIAudioViewState extends State<UIAudioView> {
//   double _offsetX = 0.0;
//   double _offsetY = 50.0;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: _offsetX,
//       top: _offsetY,
//       child: GestureDetector(
//         onPanStart: (details) {
//           _offsetX = details.globalPosition.dx;
//           _offsetY = details.globalPosition.dy;
//         },
//         onPanUpdate: (details) {
//           setState(() {
//             print("etails.globalPosition${details.globalPosition}");
//             _offsetX = details.globalPosition.dx;
//             _offsetY = details.globalPosition.dy;
//           });
//         },
//         child: _buildAudioView(widget.context),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     // MyAudioService.audioHandler.setUpdateStateCallBack(updateState);
//   }

//   @override
//   void dispose() {
//     // MyAudioService.audioHandler.removaUpdateStateCallBack();
//     super.dispose();
//   }

//   Widget _buildAudioView(BuildContext context) {
//     // if (!MyAudioService.audioHandler.playing ?? false) return SizedBox();

//     return Material(
//       child: StreamBuilder<PlaybackState>(
//           builder: (context, snapshot) {
//             final playbackState = snapshot.data;
//             final chapter = MyAudioService.audioHandler.curChapter;
//             if (chapter == null || MyAudioService.audioHandler.close == true) {
//               return SizedBox();
//             }

//             final _view = Container(
//               width: 100,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.8),
//                 borderRadius: BorderRadius.horizontal(
//                     left: Radius.circular(50), right: Radius.circular(50)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   AnimationRotateView(
//                     child: Container(
//                       height: 50,
//                       width: 50,
//                       alignment: Alignment.centerLeft,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.deepOrange),
//                         image: Utils.empty(chapter?.cover)
//                             ? null
//                             : DecorationImage(
//                                 image: NetworkImage(
//                                   chapter.cover.contains("@headers")
//                                       ? chapter.cover.split("@headers")[0]
//                                       : chapter.cover,
//                                   headers: chapter.cover.contains("@headers")
//                                       ? (jsonDecode(chapter.cover.split("@headers")[1])
//                                               as Map)
//                                           .map((k, v) => MapEntry('$k', '$v'))
//                                       : null,
//                                 ),
//                                 fit: BoxFit.cover,
//                               ),
//                       ),
//                       child: Utils.empty(chapter?.cover)
//                           ? Padding(
//                               padding: EdgeInsets.all(10),
//                               child:
//                                   Icon(Icons.audiotrack, color: Colors.white, size: 24),
//                             )
//                           : null,
//                     ),
//                   ),
//                   IconButton(
//                     color: Colors.white.withOpacity(0.5),
//                     onPressed: () {
//                       MyAudioService.audioHandler.playOrPause();
//                       setState(() {});
//                     },
//                     icon: MyAudioService.audioHandler.playing
//                         ? Icon(Icons.pause)
//                         : Icon(Icons.play_arrow),
//                   ),
//                   // IconButton(
//                   //   color: Colors.white.withOpacity(0.5),
//                   //   onPressed: () {
//                   //     MyAudioService.audioHandler.close = true;
//                   //     MyAudioService.audioHandler.stop();

//                   //     setState(() {});
//                   //   },
//                   //   icon: Icon(Icons.close),
//                   // ),
//                 ],
//               ),
//             );

//             return InkWell(
//               child: chapter != null
//                   ? Tooltip(
//                       child: _view,
//                       message: '正在播放: ' + chapter.name ?? '',
//                     )
//                   : _view,
//               onTap: chapter == null
//                   ? null
//                   : () {
//                       Utils.startPageWait(context,
//                           AudioPage(searchItem: MyAudioService.audioHandler.searchItem));
//                     },
//             );
//           },
//           stream: MyAudioService.audioHandler.playbackState,
//           initialData: null),
//     );
//   }
// }
