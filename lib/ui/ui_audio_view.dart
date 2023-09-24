import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/ui/widgets/animation_rotate_view.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../page/audio_page_refactor.dart';

class AudioView extends StatefulWidget {
  final BuildContext context;

  const AudioView({this.context, Key key}) : super(key: key);

  @override
  State<AudioView> createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  double _offsetX = null;
  double _offsetY = null;

  @override
  Widget build(BuildContext context) {
    if (audioHandler == null) return Container();
    return Stack(
      children: [
        Positioned(
          left: _offsetX,
          top: _offsetY,
          right: _offsetX == null ? 30 : null,
          bottom: _offsetX == null ? 100 : null,
          child: GestureDetector(
            onPanStart: (details) {
              if (_offsetX == null || _offsetY == null) {
                _offsetX = details.globalPosition.dx;
                _offsetY = details.globalPosition.dy;
              }
            },
            onPanUpdate: (details) {
              setState(() {
                _offsetX += details.delta.dx;
                _offsetY += details.delta.dy;
              });
            },
            child: _buildAudioView(widget.context),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // MyAudioService.audioHandler.setUpdateStateCallBack(updateState);
  }

  @override
  void dispose() {
    // MyAudioService.audioHandler.removaUpdateStateCallBack();
    super.dispose();
  }

  Widget _buildAudioView(BuildContext context) {
    // if (!MyAudioService.audioHandler.playing ?? false) return SizedBox();

    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState.map((state) => state).distinct(),
      initialData: null,
      builder: (context, snapshot) {
        // final playbackState = snapshot.data;
        if (audioHandler.chapter == null || audioHandler.close) {
          return Container();
        }
        final _view = Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(50), right: Radius.circular(50)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimationRotateView(
                child: Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepOrange),
                    image: audioHandler.emptyCover
                        ? null
                        : DecorationImage(
                            image: NetworkImage(
                              audioHandler.cover,
                              headers: audioHandler.headers,
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: audioHandler.emptyCover
                      ? Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.audiotrack, color: Colors.white, size: 24),
                        )
                      : null,
                ),
              ),
              IconButton(
                color: Colors.white.withOpacity(0.5),
                onPressed: audioHandler.playOrPause,
                icon: audioHandler.playing ? Icon(Icons.pause) : Icon(Icons.play_arrow),
              ),
              IconButton(
                color: Colors.white.withOpacity(0.5),
                onPressed: audioHandler.skipToNext,
                icon: Icon(Icons.skip_next_rounded),
              ),
              IconButton(
                color: Colors.white.withOpacity(0.5),
                onPressed: () {
                  audioHandler.close = true;
                  audioHandler.stop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
        );

        return InkWell(
          child: Tooltip(
            child: _view,
            message: '正在播放: ' + audioHandler.chapter?.name ?? '',
          ),
          onTap: () {
            Utils.startPageWait(context, AudioPage(searchItem: audioHandler.searchItem));
          },
        );
      },
    );
  }
}
