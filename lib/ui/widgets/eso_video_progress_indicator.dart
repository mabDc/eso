
import 'package:eso/utils.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ESOVideoProgressIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  ESOVideoProgressIndicator(
      this.controller, {
        VideoProgressColors colors,
        this.allowScrubbing,
        this.padding = const EdgeInsets.only(top: 5.0),
      }) : colors = colors ?? VideoProgressColors();

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  _VideoProgressIndicatorState createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<ESOVideoProgressIndicator> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller?.addListener(listener);
  }

  @override
  void deactivate() {
    controller?.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller != null && controller.value.initialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 12, left: 8, right: 8),
            child: LinearProgressIndicator(
              value: maxBuffering / duration,
              valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
              backgroundColor: colors.backgroundColor,
            ),
          ),
          FlutterSlider(
            values: [position == null ? 0 : position.toDouble()],
            min: 0,
            max: duration == null ? 0 : duration.toDouble(),
            handlerHeight: 12,
            handlerWidth: 12,
            handler: FlutterSliderHandler(
              child: Material(
                elevation: 4,
                color: Colors.transparent,
                child: Container(
                  width: 12,
                  height: 12,
                  alignment: Alignment.center,
                ),
              ),
            ),
            touchSize: 30,
            disabled: !widget.allowScrubbing,
            onDragCompleted: (handlerIndex, lowerValue, upperValue) =>
                controller.seekTo(Duration(
                    milliseconds: (lowerValue as double).toInt())),
            trackBar: FlutterSliderTrackBar(
              inactiveTrackBar: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white12,
              ),
              activeTrackBar: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white70,
              ),
            ),
            tooltip: FlutterSliderTooltip(
              disableAnimation: true,
              custom: (value) => Container(
                color: Colors.black26,
                padding: EdgeInsets.all(4),
                child: Text(
                  Utils.formatDuration(Duration(milliseconds: (value as double).toInt())),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              positionOffset: FlutterSliderTooltipPositionOffset(left: 0, right: 0),
            ),
          )
        ],
      );
    } else {
      progressIndicator = Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
        child: LinearProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
          backgroundColor: colors.backgroundColor,
        ),
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    return paddedProgressIndicator;
  }
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}