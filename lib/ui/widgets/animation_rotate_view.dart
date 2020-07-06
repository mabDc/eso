import 'dart:async';

import 'package:eso/evnts/audio_state_event.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

/// 旋转动画组件
class AnimationRotateView extends StatefulWidget {
  final Widget child;
  final bool followAudio;
  const AnimationRotateView({Key key, this.child, this.followAudio = true}): super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationRotateViewState();
}

class _AnimationRotateViewState extends State<AnimationRotateView> with SingleTickerProviderStateMixin {
  AnimationController controller;
  StreamSubscription _stream;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 30), vsync: this);
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
        controller.forward();
      }
    });
    if (widget.followAudio) {
      _stream = eventBus.on<AudioStateEvent>().listen((event) {
        if (!AudioService.isPlaying) {
          controller.stop();
        } else {
          controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _stream?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.center,
      turns: controller,
      child: widget.child,
    );
  }
}