import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// placeholder 直接使用 widget
class FadeInImageEx extends StatelessWidget {

  const FadeInImageEx({
    Key key,
    @required this.placeholder,
    @required this.image,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 700),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
  }) : assert(placeholder != null),
       assert(image != null),
       assert(fadeOutDuration != null),
       assert(fadeOutCurve != null),
       assert(fadeInDuration != null),
       assert(fadeInCurve != null),
       assert(alignment != null),
       assert(repeat != null),
       assert(matchTextDirection != null),
       super(key: key);

  FadeInImageEx.memoryNetwork({
    Key key,
    @required this.placeholder,
    @required String image,
    double imageScale = 1.0,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 700),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    int imageCacheWidth,
    int imageCacheHeight,
  }) : assert(placeholder != null),
       assert(image != null),
       assert(imageScale != null),
       assert(fadeOutDuration != null),
       assert(fadeOutCurve != null),
       assert(fadeInDuration != null),
       assert(fadeInCurve != null),
       assert(alignment != null),
       assert(repeat != null),
       assert(matchTextDirection != null),
       image = ResizeImage.resizeIfNeeded(imageCacheWidth, imageCacheHeight, NetworkImage(image, scale: imageScale)),
       super(key: key);


  FadeInImageEx.assetNetwork({
    Key key,
    @required this.placeholder,
    @required String image,
    AssetBundle bundle,
    double imageScale = 1.0,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 700),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    int imageCacheWidth,
    int imageCacheHeight,
  }) : assert(placeholder != null),
       assert(image != null),
       assert(imageScale != null),
       assert(fadeOutDuration != null),
       assert(fadeOutCurve != null),
       assert(fadeInDuration != null),
       assert(fadeInCurve != null),
       assert(alignment != null),
       assert(repeat != null),
       assert(matchTextDirection != null),
       image = ResizeImage.resizeIfNeeded(imageCacheWidth, imageCacheHeight, NetworkImage(image, scale: imageScale)),
       super(key: key);

  final Widget placeholder;

  /// The target image that is displayed once it has loaded.
  final ImageProvider image;

  /// The duration of the fade-out animation for the [placeholder].
  final Duration fadeOutDuration;

  /// The curve of the fade-out animation for the [placeholder].
  final Curve fadeOutCurve;

  /// The duration of the fade-in animation for the [image].
  final Duration fadeInDuration;

  /// The curve of the fade-in animation for the [image].
  final Curve fadeInCurve;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder image does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder image does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double height;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  final AlignmentGeometry alignment;

  final ImageRepeat repeat;

  final bool matchTextDirection;

  final bool excludeFromSemantics;

  final String imageSemanticLabel;

  Image _image({
    @required ImageProvider image,
    ImageErrorWidgetBuilder errorBuilder,
    ImageFrameBuilder frameBuilder,
  }) {
    assert(image != null);
    return Image(
      image: image,
      errorBuilder: errorBuilder,
      frameBuilder: frameBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = _image(
      image: image,
      errorBuilder: (context, err, stack) => placeholder,
      frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded)
          return child;
        return _AnimatedFadeOutFadeIn(
          target: child,
          placeholder: placeholder,
          isTargetLoaded: frame != null,
          fadeInDuration: fadeInDuration,
          fadeOutDuration: fadeOutDuration,
          fadeInCurve: fadeInCurve,
          fadeOutCurve: fadeOutCurve,
        );
      },
    );

    if (!excludeFromSemantics) {
      result = Semantics(
        container: imageSemanticLabel != null,
        image: true,
        label: imageSemanticLabel ?? '',
        child: result,
      );
    }

    return result;
  }
}

class _AnimatedFadeOutFadeIn extends ImplicitlyAnimatedWidget {
  const _AnimatedFadeOutFadeIn({
    Key key,
    @required this.target,
    @required this.placeholder,
    @required this.isTargetLoaded,
    @required this.fadeOutDuration,
    @required this.fadeOutCurve,
    @required this.fadeInDuration,
    @required this.fadeInCurve,
  }) : assert(target != null),
       assert(placeholder != null),
       assert(isTargetLoaded != null),
       assert(fadeOutDuration != null),
       assert(fadeOutCurve != null),
       assert(fadeInDuration != null),
       assert(fadeInCurve != null),
       super(key: key, duration: fadeInDuration + fadeOutDuration);

  final Widget target;
  final Widget placeholder;
  final bool isTargetLoaded;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;

  @override
  _AnimatedFadeOutFadeInState createState() => _AnimatedFadeOutFadeInState();
}

class _AnimatedFadeOutFadeInState extends ImplicitlyAnimatedWidgetState<_AnimatedFadeOutFadeIn> {
  Tween<double> _targetOpacity;
  Tween<double> _placeholderOpacity;
  Animation<double> _targetOpacityAnimation;
  Animation<double> _placeholderOpacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _targetOpacity = visitor(
      _targetOpacity,
      widget.isTargetLoaded ? 1.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>;
    _placeholderOpacity = visitor(
      _placeholderOpacity,
      widget.isTargetLoaded ? 0.0 : 1.0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>;
  }

  @override
  void didUpdateTweens() {
    _placeholderOpacityAnimation = animation.drive(TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: _placeholderOpacity.chain(CurveTween(curve: widget.fadeOutCurve)),
        weight: widget.fadeOutDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: widget.fadeInDuration.inMilliseconds.toDouble(),
      ),
    ]))..addStatusListener((AnimationStatus status) {
      if (_placeholderOpacityAnimation.isCompleted) {
        // Need to rebuild to remove placeholder now that it is invisibile.
        setState(() {});
      }
    });

    _targetOpacityAnimation = animation.drive(TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: widget.fadeOutDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: _targetOpacity.chain(CurveTween(curve: widget.fadeInCurve)),
        weight: widget.fadeInDuration.inMilliseconds.toDouble(),
      ),
    ]));
    if (!widget.isTargetLoaded && _isValid(_placeholderOpacity) && _isValid(_targetOpacity)) {
      // Jump (don't fade) back to the placeholder image, so as to be ready
      // for the full animation when the new target image becomes ready.
      controller.value = controller.upperBound;
    }
  }

  bool _isValid(Tween<double> tween) {
    return tween.begin != null && tween.end != null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget target = FadeTransition(
      opacity: _targetOpacityAnimation,
      child: widget.target,
    );

    if (_placeholderOpacityAnimation.isCompleted) {
      return target;
    }

    return Stack(
      fit: StackFit.passthrough,
      alignment: AlignmentDirectional.center,
      // Text direction is irrelevant here since we're using center alignment,
      // but it allows the Stack to avoid a call to Directionality.of()
      textDirection: TextDirection.ltr,
      children: <Widget>[
        target,
        FadeTransition(
          opacity: _placeholderOpacityAnimation,
          child: widget.placeholder,
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>('targetOpacity', _targetOpacityAnimation));
    properties.add(DiagnosticsProperty<Animation<double>>('placeholderOpacity', _placeholderOpacityAnimation));
  }
}
