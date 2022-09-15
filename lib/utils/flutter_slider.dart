/// A material design slider and range slider with horizontal and vertical axis, rtl support and lots of options and customizations for flutter

/*
* *
* * Written by Ali Azmoude <ali.azmoude@gmail.com>
* *
* *
* *
* * When I wrote this, only God and I understood what I was doing.
* * Now, God only knows "Karl Weierstrass"
* */

import 'package:flutter/material.dart';
import 'dart:math';

class FlutterSlider extends StatefulWidget {
  final Key key;
  final Axis axis;
  final double handlerWidth;
  final double handlerHeight;
  final FlutterSliderHandler handler;
  final FlutterSliderHandler rightHandler;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue) onDragStarted;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue)
      onDragCompleted;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue) onDragging;
  final double min;
  final double max;
  final List<double> values;
  final List<FlutterSliderFixedValue> fixedValues;
  final bool rangeSlider;
  final bool rtl;
  final bool jump;
  final bool selectByTap;
  final List<FlutterSliderIgnoreSteps> ignoreSteps;
  final bool disabled;
  final double touchSize;
  final bool visibleTouchArea;
  final double minimumDistance;
  final double maximumDistance;
  final FlutterSliderHandlerAnimation handlerAnimation;
  final FlutterSliderTooltip tooltip;
  final FlutterSliderTrackBar trackBar;
  final FlutterSliderStep step;
  final FlutterSliderHatchMark hatchMark;
  final bool centeredOrigin;
  final bool lockHandlers;
  final double lockDistance;
  final BoxDecoration decoration;
  final BoxDecoration foregroundDecoration;

  FlutterSlider(
      {this.key,
      this.min,
      this.max,
      @required this.values,
      this.fixedValues,
      this.axis = Axis.horizontal,
      this.handler,
      this.rightHandler,
      this.handlerHeight,
      this.handlerWidth,
      this.onDragStarted,
      this.onDragCompleted,
      this.onDragging,
      this.rangeSlider = false,
      this.rtl = false,
      this.jump = false,
      this.ignoreSteps = const [],
      this.disabled = false,
      this.touchSize,
      this.visibleTouchArea = false,
      this.minimumDistance = 0,
      this.maximumDistance = 0,
      this.tooltip,
      this.trackBar = const FlutterSliderTrackBar(),
      this.handlerAnimation = const FlutterSliderHandlerAnimation(),
      this.selectByTap = true,
      this.step = const FlutterSliderStep(),
      this.hatchMark,
      this.centeredOrigin = false,
      this.lockHandlers = false,
      this.lockDistance,
      this.decoration,
      this.foregroundDecoration})
      : assert(touchSize == null ||
            (touchSize != null && (touchSize >= 5 && touchSize <= 50))),
        assert(values != null),
        assert(step != null),
        assert(ignoreSteps != null &&
            ((ignoreSteps.length > 0 && step.rangeList == null) ||
                (ignoreSteps.length == 0))),
        assert(minimumDistance != null &&
            maximumDistance != null &&
            ((step.rangeList != null && minimumDistance == 0 && maximumDistance == 0) ||
                (minimumDistance > 0 && step.rangeList == null) ||
                (maximumDistance > 0 && step.rangeList == null) ||
                (step.rangeList == null))),
        assert((centeredOrigin != null && centeredOrigin == false) ||
            (centeredOrigin != null &&
                centeredOrigin == true &&
                rangeSlider == false &&
                lockHandlers == false &&
                minimumDistance == 0 &&
                maximumDistance == 0)),
        assert((lockHandlers != null && lockHandlers == false) ||
            ((centeredOrigin == null || centeredOrigin == false) &&
                (ignoreSteps.length == 0) &&
                (fixedValues == null || fixedValues.length == 0) &&
                rangeSlider == true &&
                values.length > 1 &&
                lockHandlers != null &&
                lockHandlers == true &&
                lockDistance != null &&
                step.step != null &&
                step.rangeList == null &&
                lockDistance >= step.step /* && values[1] - values[0] == lockDistance*/)),
        assert(fixedValues != null || (min != null && max != null && min <= max),
            "Min and Max are required if fixedValues is null"),
        assert(rangeSlider == false || (rangeSlider == true && values.length > 1),
            "Range slider needs two values"),
//        assert( fixedValues == null || (fixedValues != null && values[0] >= 0 && values[0] <= 100), "When using fixedValues, you should set values within the range of fixedValues" ),
//        assert( fixedValues == null || (fixedValues != null && values.length > 1 && values[1] >= values[0] && values[1] <= 100), "When using fixedValues, you should set values within the range of fixedValues" ),
        assert(handlerAnimation != null),
        super(key: key);

  @override
  _FlutterSliderState createState() => _FlutterSliderState();
}

class _FlutterSliderState extends State<FlutterSlider> with TickerProviderStateMixin {
  bool __isInitCall = true;

  double _touchSize;

  Widget leftHandler;
  Widget rightHandler;

  double _leftHandlerXPosition = 0;
  double _rightHandlerXPosition = 0;
  double _leftHandlerYPosition = 0;
  double _rightHandlerYPosition = 0;

  double _lowerValue = 0;
  double _upperValue = 0;
  dynamic _outputLowerValue = 0;
  dynamic _outputUpperValue = 0;

  double _realMin;
  double _realMax;

  double _divisions;
  double _handlersPadding = 0;

  GlobalKey leftHandlerKey = GlobalKey();
  GlobalKey rightHandlerKey = GlobalKey();
  GlobalKey containerKey = GlobalKey();
  GlobalKey leftTooltipKey = GlobalKey();
  GlobalKey rightTooltipKey = GlobalKey();

  double _handlersWidth;
  double _handlersHeight;

  double _constraintMaxWidth;
  double _constraintMaxHeight;

  double _containerWidthWithoutPadding;
  double _containerHeightWithoutPadding;

  double _containerLeft = 0;
  double _containerTop = 0;

  FlutterSliderTooltip _tooltipData;

  List<Function> _positionedItems;

  double _rightTooltipOpacity = 0;
  double _leftTooltipOpacity = 0;

  AnimationController _rightTooltipAnimationController;
  Animation<Offset> _rightTooltipAnimation;
  AnimationController _leftTooltipAnimationController;
  Animation<Offset> _leftTooltipAnimation;

  AnimationController _leftHandlerScaleAnimationController;
  Animation<double> _leftHandlerScaleAnimation;
  AnimationController _rightHandlerScaleAnimationController;
  Animation<double> _rightHandlerScaleAnimation;

  double _containerHeight;
  double _containerWidth;

  int _decimalScale = 0;

  double xDragTmp = 0;
  double yDragTmp = 0;

  double xDragStart;
  double yDragStart;

  double _widgetStep;
  double _widgetMin;
  double _widgetMax;
  List<FlutterSliderIgnoreSteps> _ignoreSteps = [];
  List<FlutterSliderFixedValue> _fixedValues = [];

  List<Positioned> _points = [];

  bool __dragging = false;

  double __dAxis,
      __rAxis,
      __axisDragTmp,
      __axisPosTmp,
      __containerSizeWithoutPadding,
      __rightHandlerPosition,
      __leftHandlerPosition,
      __containerSizeWithoutHalfPadding;

  Orientation oldOrientation;

  double __lockedHandlersDragOffset = 0;
  double _distanceFromRightHandler, _distanceFromLeftHandler;
  double _handlersDistance = 0;

  bool _slidingByActiveTrackBar = false;
  bool _leftTapAndSlide = false;
  bool _rightTapAndSlide = false;
  bool _trackBarSlideOnDragStartedCalled = false;

  @override
  void initState() {
    initMethod();

    super.initState();
  }

  @override
  void didUpdateWidget(FlutterSlider oldWidget) {
    __isInitCall = false;

    initMethod();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _rightTooltipAnimationController.dispose();
    _leftTooltipAnimationController.dispose();
    _leftHandlerScaleAnimationController.dispose();
    _rightHandlerScaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        oldOrientation ??= MediaQuery.of(context).orientation;

        return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          _constraintMaxWidth = constraints.maxWidth;
          _constraintMaxHeight = constraints.maxHeight;

          _containerWidthWithoutPadding = _constraintMaxWidth - _handlersWidth;
          _containerHeightWithoutPadding = _constraintMaxHeight - _handlersHeight;

          double sliderProperSize = _findProperSliderSize();
          if (widget.axis == Axis.vertical) {
            double layoutWidth = constraints.maxWidth;
            if (layoutWidth == double.infinity) {
              layoutWidth = 0;
            }
            __containerSizeWithoutPadding = _containerHeightWithoutPadding;
            _containerWidth = [(sliderProperSize * 2), layoutWidth].reduce(max);
            _containerHeight = constraints.maxHeight;
          } else {
            double layoutHeight = constraints.maxHeight;
            if (layoutHeight == double.infinity) {
              layoutHeight = 0;
            }
            _containerWidth = constraints.maxWidth;
            _containerHeight = [(sliderProperSize * 2), layoutHeight].reduce(max);
            __containerSizeWithoutPadding = _containerWidthWithoutPadding;
          }

          if (MediaQuery.of(context).orientation != oldOrientation) {
            _leftHandlerXPosition = 0;
            _rightHandlerXPosition = 0;
            _leftHandlerYPosition = 0;
            _rightHandlerYPosition = 0;

            _renderBoxInitialization();

            _arrangeHandlersPosition();

            _drawHatchMark();

            oldOrientation = MediaQuery.of(context).orientation;
          }

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
//                  ..._points,
              Container(
                key: containerKey,
                height: _containerHeight,
                width: _containerWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: drawHandlers(),
                ),
                foregroundDecoration: widget.foregroundDecoration,
                decoration: widget.decoration,
              ),
            ],
          );
        });
      },
    );
  }

  double _findProperSliderSize() {
    List<double> sizes = [
      widget.trackBar.activeTrackBarHeight,
      widget.trackBar.inactiveTrackBarHeight
    ];
    if (widget.axis == Axis.horizontal) {
      sizes.add(_handlersHeight);
    } else {
      sizes.add(_handlersWidth);
    }

    return sizes.reduce(max);
  }

  void initMethod() {
    _widgetMax = widget.max;
    _widgetMin = widget.min;

    _touchSize = widget.touchSize ?? 15;

    // validate inputs
    _validations();

    // to display min of the range correctly.
    // if we use fakes, then min is always 0
    // so calculations works well, but when we want to display
    // result numbers to user, we add ( _widgetMin ) to the final numbers

    //    if(widget.axis == Axis.vertical) {
    //      animationStart = Offset(0.20, 0);
    //      animationFinish = Offset(-0.52, 0);
    //    }

    if (__isInitCall) {
      _leftHandlerScaleAnimationController =
          AnimationController(duration: widget.handlerAnimation.duration, vsync: this);
      _rightHandlerScaleAnimationController =
          AnimationController(duration: widget.handlerAnimation.duration, vsync: this);
    }

    _leftHandlerScaleAnimation = Tween(begin: 1.0, end: widget.handlerAnimation.scale)
        .animate(CurvedAnimation(
            parent: _leftHandlerScaleAnimationController,
            reverseCurve: widget.handlerAnimation.reverseCurve,
            curve: widget.handlerAnimation.curve));
    _rightHandlerScaleAnimation = Tween(begin: 1.0, end: widget.handlerAnimation.scale)
        .animate(CurvedAnimation(
            parent: _rightHandlerScaleAnimationController,
            reverseCurve: widget.handlerAnimation.reverseCurve,
            curve: widget.handlerAnimation.curve));

    _setParameters();
    _setValues();

    if (widget.rangeSlider == true &&
        widget.maximumDistance != null &&
        widget.maximumDistance > 0 &&
        (_upperValue - _lowerValue) > widget.maximumDistance) {
      throw 'lower and upper distance is more than maximum distance';
    }
    if (widget.rangeSlider == true &&
        widget.minimumDistance != null &&
        widget.minimumDistance > 0 &&
        (_upperValue - _lowerValue) < widget.minimumDistance) {
      throw 'lower and upper distance is less than minimum distance';
    }

    Offset animationStart = Offset(0, 0);
    if (widget.tooltip != null &&
        widget.tooltip.disableAnimation != null &&
        widget.tooltip.disableAnimation) {
      animationStart = Offset(0, -1);
    }

    Offset animationFinish;
    switch (_tooltipData.direction) {
      case FlutterSliderTooltipDirection.top:
        animationFinish = Offset(0, -1);
        break;
      case FlutterSliderTooltipDirection.left:
        animationFinish = Offset(-1, 0);
        break;
      case FlutterSliderTooltipDirection.right:
        animationFinish = Offset(1, 0);
        break;
    }

    if (__isInitCall) {
      _rightTooltipOpacity = (_tooltipData.alwaysShowTooltip == true) ? 1 : 0;
      _leftTooltipOpacity = (_tooltipData.alwaysShowTooltip == true) ? 1 : 0;

      _leftTooltipAnimationController =
          AnimationController(duration: Duration(milliseconds: 200), vsync: this);
      _rightTooltipAnimationController =
          AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    } else {
      if (_tooltipData.alwaysShowTooltip) {
        _rightTooltipOpacity = _leftTooltipOpacity = 1;
      }
    }

    _leftTooltipAnimation = Tween<Offset>(begin: animationStart, end: animationFinish)
        .animate(CurvedAnimation(
            parent: _leftTooltipAnimationController, curve: Curves.fastOutSlowIn));

    _rightTooltipAnimation = Tween<Offset>(begin: animationStart, end: animationFinish)
        .animate(CurvedAnimation(
            parent: _rightTooltipAnimationController, curve: Curves.fastOutSlowIn));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renderBoxInitialization();

      _arrangeHandlersPosition();

      _drawHatchMark();

      setState(() {});
    });
  }

  void _drawHatchMark() {
    if (widget.hatchMark == null || widget.hatchMark.disabled) return;
    _points = [];

    double maxTrackBarHeight = [
      widget.trackBar.inactiveTrackBarHeight,
      widget.trackBar.activeTrackBarHeight
    ].reduce(max);

    FlutterSliderHatchMark hatchMark = FlutterSliderHatchMark();
    hatchMark.disabled = widget.hatchMark.disabled ?? false;
    hatchMark.density = widget.hatchMark.density ?? 1;
    hatchMark.linesDistanceFromTrackBar = widget.hatchMark.linesDistanceFromTrackBar ?? 0;
    hatchMark.labelsDistanceFromTrackBar =
        widget.hatchMark.labelsDistanceFromTrackBar ?? 0;
    hatchMark.smallLine = widget.hatchMark.smallLine ??
        FlutterSliderSizedBox(
            height: 5, width: 1, decoration: BoxDecoration(color: Colors.black45));
    hatchMark.bigLine = widget.hatchMark.bigLine ??
        FlutterSliderSizedBox(
            height: 9, width: 2, decoration: BoxDecoration(color: Colors.black45));
    hatchMark.labelBox =
        widget.hatchMark.labelBox ?? FlutterSliderSizedBox(height: 50, width: 50);
    hatchMark.labels = widget.hatchMark.labels ?? null;
    hatchMark.linesAlignment =
        widget.hatchMark.linesAlignment ?? FlutterSliderHatchMarkAlignment.right;
    hatchMark.displayLines = widget.hatchMark.displayLines ?? false;

    if (hatchMark.displayLines) {
      double percent = 100 * hatchMark.density;
      double barWidth, barHeight, distance;
      double linesTop, linesLeft, linesRight, linesBottom;

      if (widget.axis == Axis.horizontal) {
//      top = hatchMark.linesDistanceFromTrackBar - 2.25;
        distance = ((_constraintMaxWidth - _handlersWidth) / percent);
      } else {
//      left = hatchMark.linesDistanceFromTrackBar - 3.62;
        distance = ((_constraintMaxHeight - _handlersHeight) / percent);
      }

      Alignment linesAlignment;
      if (widget.axis == Axis.horizontal) {
        if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left) {
          linesAlignment = Alignment.bottomCenter;
        } else {
          linesAlignment = Alignment.topCenter;
        }
      } else {
        if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left) {
          linesAlignment = Alignment.centerRight;
        } else {
          linesAlignment = Alignment.centerLeft;
        }
      }

      Widget barLine;
      for (int p = 0; p <= percent; p++) {
        FlutterSliderSizedBox barLineBox = hatchMark.smallLine;

        if (p % 5 - 1 == -1) {
          barLineBox = hatchMark.bigLine;
        }

        if (widget.axis == Axis.horizontal) {
          barHeight = barLineBox.height;
          barWidth = barLineBox.width;
        } else {
          barHeight = barLineBox.width;
          barWidth = barLineBox.height;
        }

        barLine = Align(
          alignment: linesAlignment,
          child: Container(
            decoration: barLineBox.decoration,
            foregroundDecoration: barLineBox.foregroundDecoration,
            transform: barLineBox.transform,
            height: barHeight,
            width: barWidth,
          ),
        );

        if (widget.axis == Axis.horizontal) {
//        left = (p * distance) + _handlersPadding - labelBoxHalfSize - 0.5;
          linesLeft = (p * distance) + _handlersPadding - 0.75;
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.right) {
            linesTop = _containerHeight / 2 + maxTrackBarHeight / 2 + 2;
            linesBottom = _containerHeight / 2 - maxTrackBarHeight - 15;
          } else {
            linesTop = _containerHeight / 2 - maxTrackBarHeight - 15;
            linesBottom = _containerHeight / 2 + maxTrackBarHeight / 2 + 2;
          }
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left)
            linesBottom += hatchMark.linesDistanceFromTrackBar;
          else
            linesTop += hatchMark.linesDistanceFromTrackBar;
        } else {
          linesTop = (p * distance) + _handlersPadding - 0.5;
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.right) {
            linesLeft = _containerWidth / 2 + maxTrackBarHeight / 2 + 2;
            linesRight = _containerWidth / 2 - maxTrackBarHeight - 15;
          } else {
            linesLeft = _containerWidth / 2 - maxTrackBarHeight - 15;
            linesRight = _containerWidth / 2 + maxTrackBarHeight / 2 + 2;
          }
          if (hatchMark.linesAlignment == FlutterSliderHatchMarkAlignment.left)
            linesRight += hatchMark.linesDistanceFromTrackBar;
          else
            linesLeft += hatchMark.linesDistanceFromTrackBar;
        }

        _points.add(Positioned(
            top: linesTop,
            bottom: linesBottom,
            left: linesLeft,
            right: linesRight,
            child: barLine));
      }
    }

    if (hatchMark.labels != null && hatchMark.labels.length > 0) {
      List<Widget> labelWidget = [];
      Widget label;
      double labelBoxHalfSize;
      double top, left, bottom, right;
      double tr;
      for (FlutterSliderHatchMarkLabel markLabel in hatchMark.labels) {
        label = markLabel.label;
        tr = markLabel.percent;
        labelBoxHalfSize = 0;

        if (widget.rtl) tr = 100 - tr;

        if (widget.axis == Axis.horizontal) {
          labelBoxHalfSize = hatchMark.labelBox.width / 2 - 0.5;
        } else {
          labelBoxHalfSize = hatchMark.labelBox.height / 2 - 0.5;
        }

        labelWidget = [
          Container(
            height: widget.axis == Axis.vertical ? hatchMark.labelBox.height : null,
            width: widget.axis == Axis.horizontal ? hatchMark.labelBox.width : null,
            decoration: hatchMark.labelBox.decoration,
            foregroundDecoration: hatchMark.labelBox.foregroundDecoration,
            transform: hatchMark.labelBox.transform,
            child: Align(alignment: Alignment.center, child: label),
          )
        ];

        Widget bar;
        if (widget.axis == Axis.horizontal) {
          bar = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: labelWidget,
          );
          left = tr * _containerWidthWithoutPadding / 100 -
              0.5 +
              _handlersPadding -
              labelBoxHalfSize;
//          left = (tr * distance) + _handlersPadding - labelBoxHalfSize - 0.5;

          top = hatchMark.labelsDistanceFromTrackBar;
          bottom = 0;
        } else {
          bar = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: labelWidget,
          );
          top = tr * _containerHeightWithoutPadding / 100 -
              0.5 +
              _handlersPadding -
              labelBoxHalfSize;
          right = 0;
          left = hatchMark.labelsDistanceFromTrackBar;
        }

        _points.add(
            Positioned(top: top, bottom: bottom, left: left, right: right, child: bar));
      }
    }
  }

  void _validations() {
    if (widget.rangeSlider == true && widget.values.length < 2)
      throw 'when range mode is true, slider needs both lower and upper values';

    if (widget.fixedValues == null) {
      if (widget.values[0] != null && widget.values[0] < _widgetMin)
        throw 'Lower value should be greater than min';

      if (widget.rangeSlider == true) {
        if (widget.values[1] != null && widget.values[1] > _widgetMax)
          throw 'Upper value should be smaller than max';
      }
    } else {
      if (!(widget.fixedValues != null &&
          widget.values[0] >= 0 &&
          widget.values[0] <= 100)) {
        throw 'When using fixedValues, you should set values within the range of fixedValues';
      }

      if (widget.rangeSlider == true && widget.values.length > 1) {
        if (!(widget.fixedValues != null &&
            widget.values[1] >= 0 &&
            widget.values[1] <= 100)) {
          throw 'When using fixedValues, you should set values within the range of fixedValues';
        }
      }
    }

    if (widget.rangeSlider == true) {
      if (widget.values[0] > widget.values[1])
        throw 'Lower value must be smaller than upper value';
    }
  }

  void _setParameters() {
    _realMin = 0;
    _widgetMax = widget.max;
    _widgetMin = widget.min;

    _ignoreSteps = [];

    if (widget.fixedValues != null && widget.fixedValues.length > 0) {
      _realMax = 100;
      _realMin = 0;
      _widgetStep = 1;
      _widgetMax = 100;
      _widgetMin = 0;

      List<double> fixedValuesIndices = [];
      for (FlutterSliderFixedValue fixedValue in widget.fixedValues) {
        fixedValuesIndices.add(fixedValue.percent.toDouble());
      }

      double lowerIgnoreBound = -1;
      double upperIgnoreBound;
      List<double> fixedV = [];
      for (double fixedPercent = 0; fixedPercent <= 100; fixedPercent++) {
        dynamic fValue = '';
        for (FlutterSliderFixedValue fixedValue in widget.fixedValues) {
          if (fixedValue.percent == fixedPercent.toInt()) {
            fixedValuesIndices.add(fixedValue.percent.toDouble());
            fValue = fixedValue.value;

            upperIgnoreBound = fixedPercent;
            if (fixedPercent > lowerIgnoreBound + 1 || lowerIgnoreBound == 0) {
              if (lowerIgnoreBound > 0) lowerIgnoreBound += 1;
              upperIgnoreBound = fixedPercent - 1;
              _ignoreSteps.add(
                  FlutterSliderIgnoreSteps(from: lowerIgnoreBound, to: upperIgnoreBound));
            }
            lowerIgnoreBound = fixedPercent;
            break;
          }
        }
        _fixedValues
            .add(FlutterSliderFixedValue(percent: fixedPercent.toInt(), value: fValue));
        if (fValue.toString().isNotEmpty) {
          fixedV.add(fixedPercent);
        }
      }

      double biggestPoint = _findBiggestIgnorePoint(ignoreBeyondBoundaries: true);
      if (!fixedV.contains(100)) {
        _ignoreSteps.add(FlutterSliderIgnoreSteps(from: biggestPoint + 1, to: 101));
      }
    } else {
      _realMax = _widgetMax - _widgetMin;
      _widgetStep = widget.step.step;
    }

    _ignoreSteps..addAll(widget.ignoreSteps);

    _handlersWidth = widget.handlerWidth ?? widget.handlerHeight ?? 35;
    _handlersHeight = widget.handlerHeight ?? widget.handlerWidth ?? 35;

    _setDivisionAndDecimalScale();

    _positionedItems = [
      _leftHandlerWidget,
      _rightHandlerWidget,
    ];

    FlutterSliderTooltip widgetTooltip = widget.tooltip ?? FlutterSliderTooltip();

    _tooltipData = FlutterSliderTooltip();
    _tooltipData.boxStyle = widgetTooltip.boxStyle ??
        FlutterSliderTooltipBox(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 0.5),
                color: Color(0xffffffff)));
    _tooltipData.textStyle =
        widgetTooltip.textStyle ?? TextStyle(fontSize: 12, color: Colors.black38);
    _tooltipData.leftPrefix = widgetTooltip.leftPrefix ?? null;
    _tooltipData.leftSuffix = widgetTooltip.leftSuffix ?? null;
    _tooltipData.rightPrefix = widgetTooltip.rightPrefix ?? null;
    _tooltipData.rightSuffix = widgetTooltip.rightSuffix ?? null;
    _tooltipData.alwaysShowTooltip = widgetTooltip.alwaysShowTooltip ?? false;
    _tooltipData.disabled = widgetTooltip.disabled ?? false;
    _tooltipData.disableAnimation = widgetTooltip.disableAnimation ?? false;
    _tooltipData.direction = widgetTooltip.direction ?? FlutterSliderTooltipDirection.top;
    _tooltipData.positionOffset = widgetTooltip.positionOffset ?? null;
    _tooltipData.format = widgetTooltip.format ?? null;
    _tooltipData.custom = widgetTooltip.custom ?? null;
    _tooltipData.absolutePosition = widgetTooltip.absolutePosition ?? false;

    _arrangeHandlersZIndex();

    _generateHandler();

    _handlersDistance = widget.lockDistance ?? _upperValue - _lowerValue;
  }

  void _setDivisionAndDecimalScale() {
    _divisions = _realMax / _widgetStep;
    String tmpDecimalScale = '0';
    List<String> tmpDecimalScaleArr = _widgetStep.toString().split(".");
    if (tmpDecimalScaleArr.length > 1) tmpDecimalScale = tmpDecimalScaleArr[1];
    if (int.parse(tmpDecimalScale) > 0) {
      _decimalScale = tmpDecimalScale.length;
    }
  }

  List<double> _calculateUpperAndLowerValues() {
    double localLV, localUV;
    localLV = widget.values[0];
    if (widget.rangeSlider) {
      localUV = widget.values[1];
    } else {
      // when direction is rtl, then we use left handler. so to make right hand side
      // as blue ( as if selected ), then upper value should be max
      if (widget.rtl) {
        localUV = _widgetMax;
      } else {
        // when direction is ltr, so we use right handler, to make left hand side of handler
        // as blue ( as if selected ), we set lower value to min, and upper value to (input lower value)
        localUV = localLV;
        localLV = _widgetMin;
      }
    }

    return [localLV, localUV];
  }

  void _setValues() {
    List<double> localValues = _calculateUpperAndLowerValues();

    _lowerValue = localValues[0] - _widgetMin;
    _upperValue = localValues[1] - _widgetMin;

    _outputUpperValue = _displayRealValue(_upperValue);
    _outputLowerValue = _displayRealValue(_lowerValue);

    if (widget.rtl == true) {
      _outputLowerValue = _displayRealValue(_upperValue);
      _outputUpperValue = _displayRealValue(_lowerValue);

      double tmpUpperValue = _realMax - _lowerValue;
      double tmpLowerValue = _realMax - _upperValue;

      _lowerValue = tmpLowerValue;
      _upperValue = tmpUpperValue;
    }
  }

  void _arrangeHandlersPosition() {
    if (!__dragging) {
      if (widget.axis == Axis.horizontal) {
        _handlersPadding = _handlersWidth / 2;
        _leftHandlerXPosition = getPositionByValue(_lowerValue);
        _rightHandlerXPosition = getPositionByValue(_upperValue);
      } else {
        _handlersPadding = _handlersHeight / 2;
        _leftHandlerYPosition = getPositionByValue(_lowerValue);
        _rightHandlerYPosition = getPositionByValue(_upperValue);
      }
    }
  }

  void _generateHandler() {
    /*Right Handler Data*/
    FlutterSliderHandler inputRightHandler =
        widget.rightHandler ?? FlutterSliderHandler();
    inputRightHandler.child ??= Icon(
        (widget.axis == Axis.horizontal) ? Icons.chevron_left : Icons.expand_less,
        color: Colors.black45);
    inputRightHandler.disabled ??= false;
    inputRightHandler.decoration ??= BoxDecoration(boxShadow: [
      BoxShadow(
          color: Colors.black26, blurRadius: 2, spreadRadius: 0.2, offset: Offset(0, 1))
    ], color: Colors.white, shape: BoxShape.circle);

    rightHandler = _MakeHandler(
        animation: _rightHandlerScaleAnimation,
        id: rightHandlerKey,
        visibleTouchArea: widget.visibleTouchArea,
        handlerData: widget.rightHandler,
        width: _handlersWidth,
        height: _handlersHeight,
        axis: widget.axis,
        handlerIndex: 2,
        touchSize: _touchSize);

    leftHandler = _MakeHandler(
        animation: _leftHandlerScaleAnimation,
        id: leftHandlerKey,
        visibleTouchArea: widget.visibleTouchArea,
        handlerData: widget.handler,
        width: _handlersWidth,
        height: _handlersHeight,
        rtl: widget.rtl,
        rangeSlider: widget.rangeSlider,
        axis: widget.axis,
        touchSize: _touchSize);

    if (widget.rangeSlider == false) {
      rightHandler = leftHandler;
    }
  }

  double getPositionByValue(value) {
    if (widget.axis == Axis.horizontal)
      return (((_constraintMaxWidth - _handlersWidth) / _realMax) * value) - (_touchSize);
    else
      return (((_constraintMaxHeight - _handlersHeight) / _realMax) * value) -
          (_touchSize);
  }

  double getValueByPosition(double position) {
    double value =
        ((position / (__containerSizeWithoutPadding / _divisions)) * _widgetStep);
    value = (double.parse(value.toStringAsFixed(_decimalScale)) -
        double.parse((value % _widgetStep).toStringAsFixed(_decimalScale)));
    return value;
  }

  double getLengthByValue(value) {
    return value * __containerSizeWithoutPadding / _realMax;
  }

  double getValueByPositionIgnoreOffset(double position) {
    double value =
        ((position / (__containerSizeWithoutPadding / _divisions)) * _widgetStep);
    return value;
  }

  void _leftHandlerMove(PointerEvent pointer,
      {double lockedHandlersDragOffset = 0,
      double tappedPositionWithPadding = 0,
      bool selectedByTap = false}) {
    if (widget.disabled || (widget.handler != null && widget.handler.disabled)) return;

    _handlersDistance = widget.lockDistance ?? _upperValue - _lowerValue;

    // Tip: lockedHandlersDragOffset only subtracts from left handler position
    // because it calculates drag position only by left handler's position
    if (lockedHandlersDragOffset == 0) __lockedHandlersDragOffset = 0;

    if (selectedByTap) {
      _callbacks('onDragStarted', 0);
    }

    bool validMove = true;

    if (widget.axis == Axis.horizontal) {
      __dAxis = pointer.position.dx -
          tappedPositionWithPadding -
          lockedHandlersDragOffset -
          _containerLeft;
      __axisDragTmp = xDragTmp;
      __containerSizeWithoutPadding = _containerWidthWithoutPadding;
      __rightHandlerPosition = _rightHandlerXPosition;
      __leftHandlerPosition = _leftHandlerXPosition;
    } else {
      __dAxis = pointer.position.dy -
          tappedPositionWithPadding -
          lockedHandlersDragOffset -
          _containerTop;
      __axisDragTmp = yDragTmp;
      __containerSizeWithoutPadding = _containerHeightWithoutPadding;
      __rightHandlerPosition = _rightHandlerYPosition;
      __leftHandlerPosition = _leftHandlerYPosition;
    }

    __axisPosTmp = __dAxis - __axisDragTmp + (_touchSize);

    _checkRangeStep(getValueByPositionIgnoreOffset(__axisPosTmp));

    __rAxis = getValueByPosition(__axisPosTmp);

    if (widget.rangeSlider &&
        widget.minimumDistance > 0 &&
        (__rAxis + widget.minimumDistance) >= _upperValue) {
      _lowerValue = (_upperValue - widget.minimumDistance > _realMin)
          ? _upperValue - widget.minimumDistance
          : _realMin;
      _updateLowerValue(_lowerValue);

      if (lockedHandlersDragOffset == 0) validMove = validMove & false;
    }

    if (widget.rangeSlider &&
        widget.maximumDistance > 0 &&
        __rAxis <= (_upperValue - widget.maximumDistance)) {
      _lowerValue = (_upperValue - widget.maximumDistance > _realMin)
          ? _upperValue - widget.maximumDistance
          : _realMin;
      _updateLowerValue(_lowerValue);

      if (lockedHandlersDragOffset == 0) validMove = validMove & false;
    }

    double tS = _touchSize;
    if (widget.jump) {
      tS = _touchSize + _handlersPadding;
    }

    validMove = validMove & _leftHandlerIgnoreSteps(tS);

    bool forcePosStop = false;
    if (((__axisPosTmp <= 0) || (__axisPosTmp - tS >= __rightHandlerPosition))) {
      forcePosStop = true;
    }

    if (validMove &&
        ((__axisPosTmp + _handlersPadding >= _handlersPadding) || forcePosStop)) {
      double tmpLowerValue = __rAxis;

      if (tmpLowerValue > _realMax) tmpLowerValue = _realMax;
      if (tmpLowerValue < _realMin) tmpLowerValue = _realMin;

      if (tmpLowerValue > _upperValue) tmpLowerValue = _upperValue;

      if (widget.jump == true) {
        if (!forcePosStop) {
          _lowerValue = tmpLowerValue;
          _leftHandlerMoveBetweenSteps(__dAxis - __axisDragTmp, selectedByTap);
          __leftHandlerPosition = getPositionByValue(_lowerValue);
        } else {
          if (__axisPosTmp - tS >= __rightHandlerPosition) {
            __leftHandlerPosition = __rightHandlerPosition;
            _lowerValue = tmpLowerValue = _upperValue;
          } else {
            __leftHandlerPosition = getPositionByValue(_realMin);
            _lowerValue = tmpLowerValue = _realMin;
          }
          _updateLowerValue(tmpLowerValue);
        }
      } else {
        _lowerValue = tmpLowerValue;

        if (!forcePosStop) {
          __leftHandlerPosition = __dAxis - __axisDragTmp; // - (_touchSize);

          _leftHandlerMoveBetweenSteps(__leftHandlerPosition, selectedByTap);
          tmpLowerValue = _lowerValue;
        } else {
          if (__axisPosTmp - tS >= __rightHandlerPosition) {
            __leftHandlerPosition = __rightHandlerPosition;
            _lowerValue = tmpLowerValue = _upperValue;
          } else {
            __leftHandlerPosition = getPositionByValue(_realMin);
            _lowerValue = tmpLowerValue = _realMin;
          }
          _updateLowerValue(tmpLowerValue);
        }
      }
    }

    if (widget.axis == Axis.horizontal) {
      _leftHandlerXPosition = __leftHandlerPosition;
    } else {
      _leftHandlerYPosition = __leftHandlerPosition;
    }
    if (widget.lockHandlers || lockedHandlersDragOffset > 0) {
      _lockedHandlers('leftHandler');
    }
    setState(() {});

    if (selectedByTap) {
      _callbacks('onDragging', 0);
      _callbacks('onDragCompleted', 0);
    } else {
      _callbacks('onDragging', 0);
    }
  }

  bool _leftHandlerIgnoreSteps(double tS) {
    bool validMove = true;
    if (_ignoreSteps.length > 0) {
      if (__axisPosTmp <= 0) {
        double ignorePoint;
        if (widget.rtl)
          ignorePoint = _findBiggestIgnorePoint();
        else
          ignorePoint = _findSmallestIgnorePoint();

        __leftHandlerPosition = getPositionByValue(ignorePoint);
        _lowerValue = ignorePoint;
        _updateLowerValue(_lowerValue);
        return false;
      } else if (__axisPosTmp - tS >= __rightHandlerPosition) {
        __leftHandlerPosition = __rightHandlerPosition;
        _lowerValue = _upperValue;
        _updateLowerValue(_lowerValue);
        return false;
      }

      for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
        if (((!widget.rtl) &&
                ((getValueByPositionIgnoreOffset(__axisPosTmp) >
                        steps.from - _widgetStep / 2 &&
                    getValueByPositionIgnoreOffset(__axisPosTmp) <=
                        steps.to + _widgetStep / 2))) ||
            ((widget.rtl) &&
                ((_realMax - getValueByPositionIgnoreOffset(__axisPosTmp) >
                        steps.from - _widgetStep / 2 &&
                    _realMax - getValueByPositionIgnoreOffset(__axisPosTmp) <=
                        steps.to + _widgetStep / 2)))) validMove = false;
      }
    }

    return validMove;
  }

  void _leftHandlerMoveBetweenSteps(handlerPos, bool selectedByTap) {
    double nextStepMiddlePos =
        getPositionByValue((_lowerValue + (_lowerValue + _widgetStep)) / 2);
    double prevStepMiddlePos =
        getPositionByValue((_lowerValue - (_lowerValue - _widgetStep)) / 2);

    if (handlerPos > nextStepMiddlePos || handlerPos < prevStepMiddlePos) {
      if (handlerPos > nextStepMiddlePos) {
        _lowerValue += _widgetStep;
        if (_lowerValue > _realMax) _lowerValue = _realMax;
        if (_lowerValue > _upperValue) _lowerValue = _upperValue;
      } else {
        _lowerValue -= _widgetStep;
        if (_lowerValue < _realMin) _lowerValue = _realMin;
      }
    }
    _updateLowerValue(_lowerValue);
  }

  void _lockedHandlers(handler) {
    double distanceOfTwoHandlers = getLengthByValue(_handlersDistance);

    double leftHandlerPos, rightHandlerPos;
    if (widget.axis == Axis.horizontal) {
      leftHandlerPos = _leftHandlerXPosition;
      rightHandlerPos = _rightHandlerXPosition;
    } else {
      leftHandlerPos = _leftHandlerYPosition;
      rightHandlerPos = _rightHandlerYPosition;
    }

    if (handler == 'rightHandler') {
      _lowerValue = _upperValue - _handlersDistance;
      leftHandlerPos = rightHandlerPos - distanceOfTwoHandlers;
      if (getValueByPositionIgnoreOffset(__axisPosTmp) - _handlersDistance < _realMin) {
        _lowerValue = _realMin;
        _upperValue = _realMin + _handlersDistance;
        rightHandlerPos = getPositionByValue(_upperValue);
        leftHandlerPos = getPositionByValue(_lowerValue);
      }
    } else {
      _upperValue = _lowerValue + _handlersDistance;
      rightHandlerPos = leftHandlerPos + distanceOfTwoHandlers;
      if (getValueByPositionIgnoreOffset(__axisPosTmp) + _handlersDistance > _realMax) {
        _upperValue = _realMax;
        _lowerValue = _realMax - _handlersDistance;
        rightHandlerPos = getPositionByValue(_upperValue);
        leftHandlerPos = getPositionByValue(_lowerValue);
      }
    }

    if (widget.axis == Axis.horizontal) {
      _leftHandlerXPosition = leftHandlerPos;
      _rightHandlerXPosition = rightHandlerPos;
    } else {
      _leftHandlerYPosition = leftHandlerPos;
      _rightHandlerYPosition = rightHandlerPos;
    }

    _updateUpperValue(_upperValue);
    _updateLowerValue(_lowerValue);
  }

  void _updateLowerValue(value) {
    _outputLowerValue = _displayRealValue(value);
    if (widget.rtl == true) {
      _outputLowerValue = _displayRealValue(_realMax - value);
    }
  }

  void _rightHandlerMove(PointerEvent pointer,
      {double tappedPositionWithPadding = 0, bool selectedByTap = false}) {
    if (widget.disabled || (widget.rightHandler != null && widget.rightHandler.disabled))
      return;

    _handlersDistance = widget.lockDistance ?? _upperValue - _lowerValue;

    if (selectedByTap) {
      _callbacks('onDragStarted', 1);
    }

    bool validMove = true;

    if (widget.axis == Axis.horizontal) {
      __dAxis = pointer.position.dx - tappedPositionWithPadding - _containerLeft;
      __axisDragTmp = xDragTmp;
      __containerSizeWithoutPadding = _containerWidthWithoutPadding;
      __rightHandlerPosition = _rightHandlerXPosition;
      __leftHandlerPosition = _leftHandlerXPosition;
      __containerSizeWithoutHalfPadding = _constraintMaxWidth - _handlersPadding + 1;
    } else {
      __dAxis = pointer.position.dy - tappedPositionWithPadding - _containerTop;
      __axisDragTmp = yDragTmp;
      __containerSizeWithoutPadding = _containerHeightWithoutPadding;
      __rightHandlerPosition = _rightHandlerYPosition;
      __leftHandlerPosition = _leftHandlerYPosition;
      __containerSizeWithoutHalfPadding = _constraintMaxHeight - _handlersPadding + 1;
    }

    __axisPosTmp = __dAxis - __axisDragTmp + (_touchSize);

    _checkRangeStep(getValueByPositionIgnoreOffset(__axisPosTmp));

    __rAxis = getValueByPosition(__axisPosTmp);

    if (widget.rangeSlider &&
        widget.minimumDistance > 0 &&
        (__rAxis - widget.minimumDistance) <= _lowerValue) {
      _upperValue = (_lowerValue + widget.minimumDistance < _realMax)
          ? _lowerValue + widget.minimumDistance
          : _realMax;
      validMove = validMove & false;
      _updateUpperValue(_upperValue);
    }
    if (widget.rangeSlider &&
        widget.maximumDistance > 0 &&
        __rAxis >= (_lowerValue + widget.maximumDistance)) {
      _upperValue = (_lowerValue + widget.maximumDistance < _realMax)
          ? _lowerValue + widget.maximumDistance
          : _realMax;
      validMove = validMove & false;
      _updateUpperValue(_upperValue);
    }

    double tS = _touchSize;
    double rM = _handlersPadding;
    if (widget.jump) {
      rM = -_handlersWidth;
      tS = -_touchSize;
    }

    validMove = validMove & _rightHandlerIgnoreSteps(tS);

    bool forcePosStop = false;
    if (((__axisPosTmp >= __containerSizeWithoutPadding) ||
        (__axisPosTmp - tS <= __leftHandlerPosition))) {
      forcePosStop = true;
    }

    if (validMove &&
        (__axisPosTmp + rM <= __containerSizeWithoutHalfPadding || forcePosStop)) {
      double tmpUpperValue = __rAxis;

      if (tmpUpperValue > _realMax) tmpUpperValue = _realMax;
      if (tmpUpperValue < _realMin) tmpUpperValue = _realMin;

      if (tmpUpperValue < _lowerValue) tmpUpperValue = _lowerValue;

      if (widget.jump == true) {
        if (!forcePosStop) {
          _upperValue = tmpUpperValue;
          _rightHandlerMoveBetweenSteps(__dAxis - __axisDragTmp, selectedByTap);
          __rightHandlerPosition = getPositionByValue(_upperValue);
        } else {
          if (__axisPosTmp - tS <= __leftHandlerPosition) {
            __rightHandlerPosition = __leftHandlerPosition;
            _upperValue = tmpUpperValue = _lowerValue;
          } else {
            __rightHandlerPosition = getPositionByValue(_realMax);
            _upperValue = tmpUpperValue = _realMax;
          }

          _updateUpperValue(tmpUpperValue);
        }
      } else {
        _upperValue = tmpUpperValue;

        if (!forcePosStop) {
          __rightHandlerPosition = __dAxis - __axisDragTmp;
          _rightHandlerMoveBetweenSteps(__rightHandlerPosition, selectedByTap);
          tmpUpperValue = _upperValue;
        } else {
          if (__axisPosTmp - tS <= __leftHandlerPosition) {
            __rightHandlerPosition = __leftHandlerPosition;
            _upperValue = tmpUpperValue = _lowerValue;
          } else {
            __rightHandlerPosition = getPositionByValue(_realMax) + 1;
            _upperValue = tmpUpperValue = _realMax;
          }
        }
        _updateUpperValue(tmpUpperValue);
      }
    }

    if (widget.axis == Axis.horizontal) {
      _rightHandlerXPosition = __rightHandlerPosition;
    } else {
      _rightHandlerYPosition = __rightHandlerPosition;
    }
    if (widget.lockHandlers) {
      _lockedHandlers('rightHandler');
    }

    setState(() {});

    if (selectedByTap) {
      _callbacks('onDragging', 1);
      _callbacks('onDragCompleted', 1);
    } else {
      _callbacks('onDragging', 1);
    }
  }

  bool _rightHandlerIgnoreSteps(double tS) {
    bool validMove = true;
    if (_ignoreSteps.length > 0) {
      if (__axisPosTmp <= 0) {
        if (!widget.rangeSlider) {
          double ignorePoint;
          if (widget.rtl)
            ignorePoint = _findBiggestIgnorePoint();
          else
            ignorePoint = _findSmallestIgnorePoint();

          __rightHandlerPosition = getPositionByValue(ignorePoint);
          _upperValue = ignorePoint;
          _updateUpperValue(_upperValue);
        } else {
          __rightHandlerPosition = __leftHandlerPosition;
          _upperValue = _lowerValue;
          _updateUpperValue(_upperValue);
        }
        return false;
      } else if (__axisPosTmp >= __containerSizeWithoutPadding) {
        double ignorePoint;

        if (widget.rtl)
          ignorePoint = _findSmallestIgnorePoint();
        else
          ignorePoint = _findBiggestIgnorePoint();

        __rightHandlerPosition = getPositionByValue(ignorePoint);
        _upperValue = ignorePoint;
        _updateUpperValue(_upperValue);
        return false;
      }

      for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
        if (((!widget.rtl) &&
                ((getValueByPositionIgnoreOffset(__axisPosTmp) >
                        steps.from - _widgetStep / 2 &&
                    getValueByPositionIgnoreOffset(__axisPosTmp) <=
                        steps.to + _widgetStep / 2))) ||
            ((widget.rtl) &&
                ((_realMax - getValueByPositionIgnoreOffset(__axisPosTmp) >
                        steps.from - _widgetStep / 2 &&
                    _realMax - getValueByPositionIgnoreOffset(__axisPosTmp) <=
                        steps.to + _widgetStep / 2)))) validMove = false;
      }
    }
    return validMove;
  }

  double _findSmallestIgnorePoint({ignoreBeyondBoundaries = false}) {
    double ignorePoint = _realMax;
    bool beyondBoundaries = false;
    for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
      if (steps.from < _realMin) beyondBoundaries = true;
      if (steps.from < ignorePoint && steps.from >= _realMin)
        ignorePoint = steps.from - _widgetStep;
      else if (steps.to < ignorePoint && steps.to >= _realMin)
        ignorePoint = steps.to + _widgetStep;
    }
    if (beyondBoundaries || ignoreBeyondBoundaries) {
      if (widget.rtl) {
        ignorePoint = _realMax - ignorePoint;
      }
      return ignorePoint;
    } else {
      if (widget.rtl) return _realMax;
      return _realMin;
    }
  }

  double _findBiggestIgnorePoint({ignoreBeyondBoundaries = false}) {
    double ignorePoint = _realMin;
    bool beyondBoundaries = false;
    for (FlutterSliderIgnoreSteps steps in _ignoreSteps) {
      if (steps.to > _realMax) beyondBoundaries = true;

      if (steps.to > ignorePoint && steps.to <= _realMax)
        ignorePoint = steps.to + _widgetStep;
      else if (steps.from > ignorePoint && steps.from <= _realMax)
        ignorePoint = steps.from - _widgetStep;
    }
    if (beyondBoundaries || ignoreBeyondBoundaries) {
      if (widget.rtl) {
        ignorePoint = _realMax - ignorePoint;
      }

      return ignorePoint;
    } else {
      if (widget.rtl) return _realMin;
      return _realMax;
    }
  }

  void _rightHandlerMoveBetweenSteps(handlerPos, bool selectedByTap) {
    double nextStepMiddlePos =
        getPositionByValue((_upperValue + (_upperValue + _widgetStep)) / 2);
    double prevStepMiddlePos =
        getPositionByValue((_upperValue - (_upperValue - _widgetStep)) / 2);

    if (handlerPos > nextStepMiddlePos || handlerPos < prevStepMiddlePos) {
      if (handlerPos > nextStepMiddlePos) {
        _upperValue += _widgetStep;
        if (_upperValue > _realMax) _upperValue = _realMax;
      } else {
        _upperValue -= _widgetStep;
        if (_upperValue < _realMin) _upperValue = _realMin;
        if (_upperValue < _lowerValue) _upperValue = _lowerValue;
      }
    }
    _updateUpperValue(_upperValue);
  }

  void _updateUpperValue(value) {
    _outputUpperValue = _displayRealValue(value);
    if (widget.rtl == true) {
      _outputUpperValue = _displayRealValue(_realMax - value);
    }
  }

  void _checkRangeStep(double realValue) {
    double sliderFromRange, sliderToRange;
    if (widget.step.rangeList != null) {
      for (FlutterSliderRangeStep rangeStep in widget.step.rangeList) {
        if (widget.step.isPercentRange) {
          sliderFromRange = _widgetMax * rangeStep.from / 100;
          sliderToRange = _widgetMax * rangeStep.to / 100;
        } else {
          sliderFromRange = rangeStep.from;
          sliderToRange = rangeStep.to;
        }

        if (realValue >= sliderFromRange && realValue <= sliderToRange) {
          _widgetStep = rangeStep.step;
          _setDivisionAndDecimalScale();
          break;
        }
      }
    }
  }

  Positioned _leftHandlerWidget() {
    if (widget.rangeSlider == false)
      return Positioned(
        child: Container(),
      );

    double bottom;
    double right;
    if (widget.axis == Axis.horizontal) {
      bottom = 0;
    } else {
      right = 0;
    }

    return Positioned(
      key: Key('leftHandler'),
      left: _leftHandlerXPosition,
      top: _leftHandlerYPosition,
      bottom: bottom,
      right: right,
      child: Listener(
        child: Draggable(
            axis: widget.axis,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                _tooltip(
                    offsetLeft: _leftHandlerXPosition,
                    side: 'left',
                    value: _outputLowerValue,
                    opacity: _leftTooltipOpacity,
                    animation: _leftTooltipAnimation),
                leftHandler,
              ],
            ),
            feedback: Container()),
        onPointerMove: (_) {
          __dragging = true;

          _leftHandlerMove(_);
        },
        onPointerDown: (_) {
          if (widget.disabled || (widget.handler != null && widget.handler.disabled))
            return;

          _renderBoxInitialization();

          xDragTmp = (_.position.dx - _containerLeft - _leftHandlerXPosition);
          yDragTmp = (_.position.dy - _containerTop - _leftHandlerYPosition);

          if (!_tooltipData.disabled && _tooltipData.alwaysShowTooltip == false) {
            _leftTooltipOpacity = 1;
            _leftTooltipAnimationController.forward();

            if (widget.lockHandlers) {
              _rightTooltipOpacity = 1;
              _rightTooltipAnimationController.forward();
            }
          }

          _leftHandlerScaleAnimationController.forward();

          setState(() {});

          _callbacks('onDragStarted', 0);
        },
        onPointerUp: (_) {
          __dragging = false;

          _adjustLeftHandlerPosition();

          if (widget.disabled || (widget.handler != null && widget.handler.disabled))
            return;

          _arrangeHandlersZIndex();

          _stopHandlerAnimation(
              animation: _leftHandlerScaleAnimation,
              controller: _leftHandlerScaleAnimationController);

          _hideTooltips();

          setState(() {});

          _callbacks('onDragCompleted', 0);
        },
      ),
    );
  }

  void _adjustLeftHandlerPosition() {
    if (!widget.jump) {
      double position = getPositionByValue(_lowerValue);
      if (widget.axis == Axis.horizontal) {
        _leftHandlerXPosition =
            position > _rightHandlerXPosition ? _rightHandlerXPosition : position;
        if (widget.lockHandlers || __lockedHandlersDragOffset > 0) {
          position = getPositionByValue(_lowerValue + _handlersDistance);
          _rightHandlerXPosition =
              position < _leftHandlerXPosition ? _leftHandlerXPosition : position;
        }
      } else {
        _leftHandlerYPosition =
            position > _rightHandlerYPosition ? _rightHandlerYPosition : position;
        if (widget.lockHandlers || __lockedHandlersDragOffset > 0) {
          position = getPositionByValue(_lowerValue + _handlersDistance);
          _rightHandlerYPosition =
              position < _leftHandlerYPosition ? _leftHandlerYPosition : position;
        }
      }
    }
  }

  void _hideTooltips() {
    if (!_tooltipData.alwaysShowTooltip) {
      _leftTooltipOpacity = 0;
      _rightTooltipOpacity = 0;
      _leftTooltipAnimationController.reset();
      _rightTooltipAnimationController.reset();
    }
  }

  Positioned _rightHandlerWidget() {
    double bottom;
    double right;
    if (widget.axis == Axis.horizontal) {
      bottom = 0;
    } else {
      right = 0;
    }

    return Positioned(
      key: Key('rightHandler'),
      left: _rightHandlerXPosition,
      top: _rightHandlerYPosition,
      right: right,
      bottom: bottom,
      child: Listener(
        child: Draggable(
            axis: Axis.horizontal,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                _tooltip(
                    offsetLeft: _rightHandlerXPosition,
                    side: 'right',
                    value: _outputUpperValue,
                    opacity: _rightTooltipOpacity,
                    animation: _rightTooltipAnimation),
                rightHandler,
              ],
            ),
            feedback: Container(
//                            width: 20,
//                            height: 20,
//                            color: Colors.blue.withOpacity(0.7),
                )),
        onPointerMove: (_) {
          __dragging = true;

          if (!_tooltipData.disabled && _tooltipData.alwaysShowTooltip == false) {
            _rightTooltipOpacity = 1;
          }
          _rightHandlerMove(_);
        },
        onPointerDown: (_) {
          if (widget.disabled ||
              (widget.rightHandler != null && widget.rightHandler.disabled)) return;

          _renderBoxInitialization();

          xDragTmp = (_.position.dx - _containerLeft - _rightHandlerXPosition);
          yDragTmp = (_.position.dy - _containerTop - _rightHandlerYPosition);

          if (!_tooltipData.disabled && _tooltipData.alwaysShowTooltip == false) {
            _rightTooltipOpacity = 1;
            _rightTooltipAnimationController.forward();

            if (widget.lockHandlers) {
              _leftTooltipOpacity = 1;
              _leftTooltipAnimationController.forward();
            }

            setState(() {});
          }
          if (widget.rangeSlider == false)
            _leftHandlerScaleAnimationController.forward();
          else
            _rightHandlerScaleAnimationController.forward();

          _callbacks('onDragStarted', 1);
        },
        onPointerUp: (_) {
          __dragging = false;

          _adjustRightHandlerPosition();

          if (widget.disabled ||
              (widget.rightHandler != null && widget.rightHandler.disabled)) return;

          _arrangeHandlersZIndex();

          if (widget.rangeSlider == false) {
            _stopHandlerAnimation(
                animation: _leftHandlerScaleAnimation,
                controller: _leftHandlerScaleAnimationController);
          } else {
            _stopHandlerAnimation(
                animation: _rightHandlerScaleAnimation,
                controller: _rightHandlerScaleAnimationController);
          }

          _hideTooltips();

          setState(() {});

          _callbacks('onDragCompleted', 1);
        },
      ),
    );
  }

  void _adjustRightHandlerPosition() {
    if (!widget.jump) {
      double position = getPositionByValue(_upperValue);
      if (widget.axis == Axis.horizontal) {
        _rightHandlerXPosition =
            position < _leftHandlerXPosition ? _leftHandlerXPosition : position;
        if (widget.lockHandlers) {
          position = getPositionByValue(_upperValue - _handlersDistance);
          _leftHandlerXPosition =
              position > _rightHandlerXPosition ? _rightHandlerXPosition : position;
        }
      } else {
        _rightHandlerYPosition =
            position < _leftHandlerYPosition ? _leftHandlerYPosition : position;
        if (widget.lockHandlers) {
          position = getPositionByValue(_upperValue - _handlersDistance);
          _leftHandlerYPosition =
              position > _rightHandlerYPosition ? _rightHandlerYPosition : position;
        }
      }
    }
  }

  void _stopHandlerAnimation({Animation animation, AnimationController controller}) {
    if (widget.handlerAnimation.reverseCurve != null) {
      if (animation.isCompleted)
        controller.reverse();
      else {
        controller.reset();
      }
    } else
      controller.reset();
  }

  drawHandlers() {
    List<Positioned> items = []..addAll([
        Function.apply(_inactiveTrack, []),
        Function.apply(_centralWidget, []),
        Function.apply(_activeTrack, []),
      ]);
    items..addAll(_points);

    double tappedPositionWithPadding = 0;

    items.add(Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Opacity(
          opacity: 0,
          child: Listener(
            onPointerUp: (_) {
              if (widget.selectByTap && !__dragging) {
                tappedPositionWithPadding = _distance();
                if (_distanceFromLeftHandler < _distanceFromRightHandler) {
                  if (!widget.rangeSlider) {
                    _rightHandlerMove(_,
                        tappedPositionWithPadding: tappedPositionWithPadding,
                        selectedByTap: true);
                  } else {
                    _leftHandlerMove(_,
                        tappedPositionWithPadding: tappedPositionWithPadding,
                        selectedByTap: true);
                  }
                } else
                  _rightHandlerMove(_,
                      tappedPositionWithPadding: tappedPositionWithPadding,
                      selectedByTap: true);
              } else {
                if (_slidingByActiveTrackBar) {
                  _callbacks('onDragCompleted', 0);
                }
                if (_leftTapAndSlide) {
                  _callbacks('onDragCompleted', 0);
                }
                if (_rightTapAndSlide) {
                  _callbacks('onDragCompleted', 1);
                }
              }

//              _adjustLeftHandlerPosition();
//              _adjustRightHandlerPosition();

              _hideTooltips();

              _stopHandlerAnimation(
                  animation: _leftHandlerScaleAnimation,
                  controller: _leftHandlerScaleAnimationController);
              _stopHandlerAnimation(
                  animation: _rightHandlerScaleAnimation,
                  controller: _rightHandlerScaleAnimationController);

              __dragging = false;

              setState(() {});
            },
            onPointerMove: (_) {
              __dragging = true;

              if (_slidingByActiveTrackBar) {
                _trackBarSlideCallDragStated(0);
                _leftHandlerMove(_, lockedHandlersDragOffset: __lockedHandlersDragOffset);
              } else {
                tappedPositionWithPadding = _distance();

                if (widget.rangeSlider) {
                  if (_leftTapAndSlide) {
                    _trackBarSlideCallDragStated(0);
                    if (!_tooltipData.disabled &&
                        _tooltipData.alwaysShowTooltip == false) {
                      _leftTooltipOpacity = 1;
                      _leftTooltipAnimationController.forward();
                    }
                    _leftHandlerMove(_,
                        tappedPositionWithPadding: tappedPositionWithPadding);
                  } else {
                    _trackBarSlideCallDragStated(1);
                    if (!_tooltipData.disabled &&
                        _tooltipData.alwaysShowTooltip == false) {
                      _rightTooltipOpacity = 1;
                      _rightTooltipAnimationController.forward();
                    }
                    _rightHandlerMove(_,
                        tappedPositionWithPadding: tappedPositionWithPadding);
                  }
                } else {
                  _trackBarSlideCallDragStated(1);
                  if (!_tooltipData.disabled && _tooltipData.alwaysShowTooltip == false) {
                    _rightTooltipOpacity = 1;
                    _rightTooltipAnimationController.forward();
                  }
                  _rightHandlerMove(_,
                      tappedPositionWithPadding: tappedPositionWithPadding);
                }
              }
            },
            onPointerDown: (_) {
              _leftTapAndSlide = false;
              _rightTapAndSlide = false;
              _slidingByActiveTrackBar = false;
              __dragging = false;
              _trackBarSlideOnDragStartedCalled = false;

              double leftHandlerLastPosition, rightHandlerLastPosition;
              if (widget.axis == Axis.horizontal) {
                double lX = _leftHandlerXPosition +
                    _handlersPadding +
                    (_touchSize) +
                    _containerLeft;
                double rX = _rightHandlerXPosition +
                    _handlersPadding +
                    (_touchSize) +
                    _containerLeft;

                _distanceFromRightHandler = (rX - _.position.dx);
                _distanceFromLeftHandler = (lX - _.position.dx);

                leftHandlerLastPosition = lX;
                rightHandlerLastPosition = rX;
              } else {
                double lY =
                    _leftHandlerYPosition + _handlersPadding + _touchSize + _containerTop;
                double rY = _rightHandlerYPosition +
                    _handlersPadding +
                    _touchSize +
                    _containerTop;

                _distanceFromLeftHandler = (lY - _.position.dy);
                _distanceFromRightHandler = (rY - _.position.dy);

                leftHandlerLastPosition = lY;
                rightHandlerLastPosition = rY;
              }

              if (widget.rangeSlider &&
                  widget.trackBar.activeTrackBarDraggable &&
                  _ignoreSteps.length == 0 &&
                  _distanceFromRightHandler > 0 &&
                  _distanceFromLeftHandler < 0) {
                _slidingByActiveTrackBar = true;
              } else {
                double thumbPosition =
                    (widget.axis == Axis.vertical) ? _.position.dy : _.position.dx;
                if (_distanceFromLeftHandler.abs() < _distanceFromRightHandler.abs() ||
                    (_distanceFromLeftHandler == _distanceFromRightHandler &&
                        thumbPosition < leftHandlerLastPosition)) {
                  _leftTapAndSlide = true;
                }
                if (_distanceFromRightHandler.abs() < _distanceFromLeftHandler.abs() ||
                    (_distanceFromLeftHandler == _distanceFromRightHandler &&
                        thumbPosition < rightHandlerLastPosition)) {
                  _rightTapAndSlide = true;
                }
              }

              // if drag is within active area
              if (_distanceFromRightHandler > 0 && _distanceFromLeftHandler < 0) {
                if (widget.axis == Axis.horizontal) {
                  xDragTmp = 0;
                  __lockedHandlersDragOffset =
                      ((_leftHandlerXPosition) + _containerLeft - _.position.dx).abs();
                } else {
                  yDragTmp = 0;
                  __lockedHandlersDragOffset =
                      ((_leftHandlerYPosition) + _containerTop - _.position.dy).abs();
                }
              }
//              }

              if (_ignoreSteps.length == 0) {
                if ((widget.lockHandlers || __lockedHandlersDragOffset > 0) &&
                    !_tooltipData.disabled &&
                    _tooltipData.alwaysShowTooltip == false) {
                  _leftTooltipOpacity = 1;
                  _leftTooltipAnimationController.forward();
                  _rightTooltipOpacity = 1;
                  _rightTooltipAnimationController.forward();
                }

                if ((widget.lockHandlers || __lockedHandlersDragOffset > 0)) {
                  _leftHandlerScaleAnimationController.forward();
                  _rightHandlerScaleAnimationController.forward();
                }
              }

              setState(() {});
            },
            child: Draggable(
                axis: widget.axis,
                feedback: Container(),
                child: Container(
                  color: Colors.transparent,
                )),
          ),
        )));

//    items      ..addAll(_points);

    for (Function func in _positionedItems) {
      items.add(Function.apply(func, []));
    }

    return items;
  }

  _trackBarSlideCallDragStated(handlerIndex) {
    if (!_trackBarSlideOnDragStartedCalled) {
      _callbacks('onDragStarted', handlerIndex);
      _trackBarSlideOnDragStartedCalled = true;
    }
  }

  _distance() {
    _distanceFromLeftHandler = _distanceFromLeftHandler.abs();
    _distanceFromRightHandler = _distanceFromRightHandler.abs();

    if (widget.axis == Axis.horizontal) {
      return _handlersWidth / 2 + (_touchSize) - xDragTmp;
    } else {
      return _handlersHeight / 2 + (_touchSize) - yDragTmp;
    }
  }

  Positioned _tooltip(
      {String side,
      dynamic value,
      double opacity,
      Animation animation,
      double offsetLeft}) {
    if (_tooltipData.disabled || value == '')
      return Positioned(
        child: Container(),
      );

    Widget prefix;
    Widget suffix;

    if (side == 'left') {
      prefix = _tooltipData.leftPrefix ?? Container();
      suffix = _tooltipData.leftSuffix ?? Container();
      if (widget.rangeSlider == false)
        return Positioned(
          child: Container(),
        );
    } else {
      prefix = _tooltipData.rightPrefix ?? Container();
      suffix = _tooltipData.rightSuffix ?? Container();
    }
    String numberFormat = value.toString();
    if (_tooltipData.format != null) numberFormat = _tooltipData.format(numberFormat);

    List<Widget> children = [
      prefix,
      Text(numberFormat, style: _tooltipData.textStyle),
      suffix,
    ];

    Widget _tooltipHolderWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
    if (_tooltipData.direction == FlutterSliderTooltipDirection.top) {
      _tooltipHolderWidget = Row(
        mainAxisSize: MainAxisSize.max,
        children: children,
      );
    }

    Widget tooltipWidget = IgnorePointer(
        child: Center(
      child: FittedBox(
        child: Container(
//            height: ,
//          height: __tooltipKEY.currentContext.size.height,
          key: (side == 'left') ? leftTooltipKey : rightTooltipKey,
//            alignment: Alignment.center,
          child: (widget.tooltip != null && widget.tooltip.custom != null)
              ? widget.tooltip.custom(value)
              : Container(
                  padding: EdgeInsets.all(8),
                  decoration: _tooltipData.boxStyle.decoration,
                  foregroundDecoration: _tooltipData.boxStyle.foregroundDecoration,
                  transform: _tooltipData.boxStyle.transform,
                  child: _tooltipHolderWidget),
        ),
      ),
    ));

    double top, right, bottom, left;
    switch (_tooltipData.direction) {
      case FlutterSliderTooltipDirection.top:
        top = 0;
        left = 0;
        right = 0;
        break;
      case FlutterSliderTooltipDirection.left:
        left = 0;
        top = 0;
        bottom = 0;
        break;
      case FlutterSliderTooltipDirection.right:
        right = 0;
        top = 0;
        bottom = 0;
        break;
    }

    if (_tooltipData.positionOffset != null) {
      if (_tooltipData.positionOffset.top != null) top += _tooltipData.positionOffset.top;
      if (_tooltipData.positionOffset.left != null)
        left += _tooltipData.positionOffset.left;
      if (_tooltipData.positionOffset.right != null)
        right += _tooltipData.positionOffset.right;
      if (_tooltipData.positionOffset.bottom != null)
        bottom += _tooltipData.positionOffset.bottom;
    }
    if (_tooltipData.absolutePosition && left != null) {
      left -= offsetLeft;
      right += offsetLeft;
    }

    tooltipWidget = SlideTransition(position: animation, child: tooltipWidget);

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Opacity(
        opacity: opacity,
        child: Center(child: tooltipWidget),
      ),
    );
  }

  Positioned _inactiveTrack() {
    BoxDecoration boxDecoration = widget.trackBar.inactiveTrackBar ?? BoxDecoration();

    Color trackBarColor = boxDecoration.color ?? Color(0x110000ff);
    if (widget.disabled) trackBarColor = widget.trackBar.inactiveDisabledTrackBarColor;

    double top, bottom, left, right, width, height;
    top = left = right = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      left = _handlersPadding;
      width = _containerWidthWithoutPadding;
      height = widget.trackBar.inactiveTrackBarHeight;
      top = 0;
    } else {
      right = 0;
      height = _containerHeightWithoutPadding;
      top = _handlersPadding;
      width = widget.trackBar.inactiveTrackBarHeight;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Center(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: trackBarColor,
              backgroundBlendMode: boxDecoration.backgroundBlendMode,
              shape: boxDecoration.shape,
              gradient: boxDecoration.gradient,
              border: boxDecoration.border,
              borderRadius: boxDecoration.borderRadius,
              boxShadow: boxDecoration.boxShadow,
              image: boxDecoration.image),
        ),
      ),
    );
  }

  Positioned _activeTrack() {
    BoxDecoration boxDecoration = widget.trackBar.activeTrackBar ?? BoxDecoration();

    Color trackBarColor = boxDecoration.color ?? Color(0xff2196F3);
    if (widget.disabled) trackBarColor = widget.trackBar.activeDisabledTrackBarColor;

    double top, bottom, left, right, width, height;
    top = left = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      height = widget.trackBar.activeTrackBarHeight;
      if (!widget.centeredOrigin || widget.rangeSlider) {
        width = _rightHandlerXPosition - _leftHandlerXPosition;
        left = _leftHandlerXPosition + _handlersWidth / 2 + (_touchSize);

        if (widget.rtl == true && widget.rangeSlider == false) {
          left = null;
          right = _handlersWidth / 2;
          width = _containerWidthWithoutPadding - _rightHandlerXPosition - _touchSize;
        }
      } else {
        if (_containerWidthWithoutPadding / 2 - _touchSize > _rightHandlerXPosition) {
          width = _containerWidthWithoutPadding / 2 - _rightHandlerXPosition - _touchSize;
          left = _rightHandlerXPosition + _handlersWidth / 2 + (_touchSize);
        } else {
          left = _containerWidthWithoutPadding / 2 + _handlersPadding;
          width = _rightHandlerXPosition + _touchSize - _containerWidthWithoutPadding / 2;
        }
      }
    } else {
      right = 0;
      width = widget.trackBar.activeTrackBarHeight;

      if (!widget.centeredOrigin || widget.rangeSlider) {
        height = _rightHandlerYPosition - _leftHandlerYPosition;
        top = _leftHandlerYPosition + _handlersHeight / 2 + (_touchSize);
        if (widget.rtl == true && widget.rangeSlider == false) {
          top = null;
          bottom = _handlersHeight / 2;
          height = _containerHeightWithoutPadding - _rightHandlerYPosition - _touchSize;
        }
      } else {
        if (_containerHeightWithoutPadding / 2 - _touchSize > _rightHandlerYPosition) {
          height =
              _containerHeightWithoutPadding / 2 - _rightHandlerYPosition - _touchSize;
          top = _rightHandlerYPosition + _handlersHeight / 2 + (_touchSize);
        } else {
          top = _containerHeightWithoutPadding / 2 + _handlersPadding;
          height =
              _rightHandlerYPosition + _touchSize - _containerHeightWithoutPadding / 2;
        }
      }
    }

    width = (width.isNaN || width < 0) ? 0 : width;
    height = (height.isNaN || height < 0) ? 0 : height;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Center(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: trackBarColor,
              backgroundBlendMode: boxDecoration.backgroundBlendMode,
              shape: boxDecoration.shape,
              gradient: boxDecoration.gradient,
              border: boxDecoration.border,
              borderRadius: boxDecoration.borderRadius,
              boxShadow: boxDecoration.boxShadow,
              image: boxDecoration.image),
        ),
      ),
    );
  }

  Positioned _centralWidget() {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Center(child: widget.trackBar.centralWidget ?? Container()),
    );
  }

  void _callbacks(String callbackName, int handlerIndex) {
    dynamic lowerValue = _outputLowerValue;
    dynamic upperValue = _outputUpperValue;
    if (widget.rtl == true || widget.rangeSlider == false) {
      lowerValue = _outputUpperValue;
      upperValue = _outputLowerValue;
    }

    switch (callbackName) {
      case 'onDragging':
        if (widget.onDragging != null)
          widget.onDragging(handlerIndex, lowerValue, upperValue);
        break;
      case 'onDragCompleted':
        if (widget.onDragCompleted != null)
          widget.onDragCompleted(handlerIndex, lowerValue, upperValue);
        break;
      case 'onDragStarted':
        if (widget.onDragStarted != null)
          widget.onDragStarted(handlerIndex, lowerValue, upperValue);
        break;
    }
  }

  dynamic _displayRealValue(double value) {
    if (_fixedValues.length > 0) {
      return _fixedValues[value.toInt()].value;
    }

    return double.parse((value + _widgetMin).toStringAsFixed(_decimalScale));
  }

  void _arrangeHandlersZIndex() {
    if (_lowerValue >= (_realMax / 2))
      _positionedItems = [
        _rightHandlerWidget,
        _leftHandlerWidget,
      ];
    else
      _positionedItems = [
        _leftHandlerWidget,
        _rightHandlerWidget,
      ];
  }

  void _renderBoxInitialization() {
    if (_containerLeft <= 0 ||
        (MediaQuery.of(context).size.width - _constraintMaxWidth) <= _containerLeft) {
      RenderBox containerRenderBox = containerKey.currentContext.findRenderObject();
      _containerLeft = containerRenderBox.localToGlobal(Offset.zero).dx;
    }
    if (_containerTop <= 0 ||
        (MediaQuery.of(context).size.height - _constraintMaxHeight) <= _containerTop) {
      RenderBox containerRenderBox = containerKey.currentContext.findRenderObject();
      _containerTop = containerRenderBox.localToGlobal(Offset.zero).dy;
    }
  }
}

class _MakeHandler extends StatelessWidget {
  final double width;
  final double height;
  final GlobalKey id;
  final FlutterSliderHandler handlerData;
  final bool visibleTouchArea;
  final Animation animation;
  final Axis axis;
  final int handlerIndex;
  final bool rtl;
  final bool rangeSlider;
  final double touchSize;

  _MakeHandler(
      {this.id,
      this.handlerData,
      this.visibleTouchArea,
      this.width,
      this.height,
      this.animation,
      this.rtl = false,
      this.rangeSlider = false,
      this.axis,
      this.handlerIndex,
      this.touchSize});

  @override
  Widget build(BuildContext context) {
    double touchOpacity = (visibleTouchArea == true) ? 1 : 0;

    double localWidth, localHeight;
    localHeight = height + (touchSize * 2);
    localWidth = width + (touchSize * 2);

    FlutterSliderHandler handler = handlerData ?? FlutterSliderHandler();

    if (handlerIndex == 2) {
      handler.child ??= Icon(
          (axis == Axis.horizontal) ? Icons.chevron_left : Icons.expand_less,
          color: Colors.black45);
    } else {
      IconData hIcon =
          (axis == Axis.horizontal) ? Icons.chevron_right : Icons.expand_more;
      if (rtl && !rangeSlider) {
        hIcon = (axis == Axis.horizontal) ? Icons.chevron_left : Icons.expand_less;
      }
      handler.child ??= Icon(hIcon, color: Colors.black45);
    }

    handler.disabled ??= false;
    handler.decoration ??= BoxDecoration(boxShadow: [
      BoxShadow(
          color: Colors.black26, blurRadius: 2, spreadRadius: 0.2, offset: Offset(0, 1))
    ], color: Colors.white, shape: BoxShape.circle);

    return Center(
      child: Container(
        key: id,
        width: localWidth,
        height: localHeight,
        child: Stack(children: <Widget>[
          Opacity(
            opacity: touchOpacity,
            child: Container(
              color: Colors.black12,
              child: Container(),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: animation,
              child: Opacity(
                opacity: handler.opacity ?? 1,
                child: Container(
                  alignment: Alignment.center,
                  foregroundDecoration: handler.foregroundDecoration,
                  decoration: handler.decoration,
                  transform: handler.transform,
                  width: width.isNaN ? 0 : width,
                  height: height.isNaN ? 0 : height,
                  child: handler.child,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class FlutterSliderHandler {
  BoxDecoration decoration;
  BoxDecoration foregroundDecoration;
  Matrix4 transform;
  Widget child;
  bool disabled;
  double opacity;

  FlutterSliderHandler(
      {this.child,
      this.decoration,
      this.foregroundDecoration,
      this.transform,
      this.disabled = false,
      this.opacity = 1})
      : assert(disabled != null);

  @override
  String toString() {
    return child.toString() +
        '-' +
        disabled.toString() +
        '-' +
        decoration.toString() +
        '-' +
        foregroundDecoration.toString() +
        '-' +
        transform.toString() +
        '-' +
        opacity.toString();
  }
}

class FlutterSliderTooltip {
  /// 使用自定义组件
  Widget Function(dynamic value) custom;

  /// 修改显示结果
  String Function(String value) format;
  TextStyle textStyle;
  FlutterSliderTooltipBox boxStyle;
  Widget leftPrefix;
  Widget leftSuffix;
  Widget rightPrefix;
  Widget rightSuffix;
  bool alwaysShowTooltip;
  bool disabled;
  bool disableAnimation;

  /// 显示位置
  FlutterSliderTooltipDirection direction;

  /// 修改相对定位偏移量和容器大小
  FlutterSliderTooltipPositionOffset positionOffset;
  // 添加相对定位和绝对定位条件
  bool absolutePosition;

  FlutterSliderTooltip({
    this.custom,
    this.format,
    this.textStyle,
    this.boxStyle,
    this.leftPrefix,
    this.leftSuffix,
    this.rightPrefix,
    this.rightSuffix,
    this.alwaysShowTooltip,
    this.disableAnimation,
    this.disabled,
    this.direction,
    this.positionOffset,
    this.absolutePosition,
  });

  @override
  String toString() {
    return textStyle.toString() +
        '-' +
        boxStyle.toString() +
        '-' +
        leftPrefix.toString() +
        '-' +
        leftSuffix.toString() +
        '-' +
        rightPrefix.toString() +
        '-' +
        rightSuffix.toString() +
        '-' +
        alwaysShowTooltip.toString() +
        '-' +
        disabled.toString() +
        '-' +
        disableAnimation.toString() +
        '-' +
        direction.toString() +
        '-' +
        positionOffset.toString();
  }
}

class FlutterSliderTooltipPositionOffset {
  double top;
  double left;
  double right;
  double bottom;

  FlutterSliderTooltipPositionOffset({this.top, this.left, this.right, this.bottom});

  @override
  String toString() {
    return top.toString() +
        '-' +
        left.toString() +
        '-' +
        bottom.toString() +
        '-' +
        right.toString();
  }
}

class FlutterSliderTooltipBox {
  final BoxDecoration decoration;
  final BoxDecoration foregroundDecoration;
  final Matrix4 transform;

  const FlutterSliderTooltipBox(
      {this.decoration, this.foregroundDecoration, this.transform});

  @override
  String toString() {
    return decoration.toString() +
        '-' +
        foregroundDecoration.toString() +
        '-' +
        transform.toString();
  }
}

class FlutterSliderTrackBar {
  final BoxDecoration inactiveTrackBar;
  final BoxDecoration activeTrackBar;
  final Color activeDisabledTrackBarColor;
  final Color inactiveDisabledTrackBarColor;
  final double activeTrackBarHeight;
  final double inactiveTrackBarHeight;
  final Widget centralWidget;
  final bool activeTrackBarDraggable;

  const FlutterSliderTrackBar({
    this.inactiveTrackBar,
    this.activeTrackBar,
    this.activeDisabledTrackBarColor = const Color(0xffb5b5b5),
    this.inactiveDisabledTrackBarColor = const Color(0xffe5e5e5),
    this.activeTrackBarHeight = 3.5,
    this.inactiveTrackBarHeight = 3,
    this.centralWidget,
    this.activeTrackBarDraggable = true,
  })  : assert(activeTrackBarHeight != null &&
            activeTrackBarHeight > 0 &&
            inactiveTrackBarHeight != null &&
            inactiveTrackBarHeight > 0),
        assert(
            activeDisabledTrackBarColor != null && inactiveDisabledTrackBarColor != null);

  @override
  String toString() {
    return inactiveTrackBar.toString() +
        '-' +
        activeTrackBar.toString() +
        '-' +
        activeDisabledTrackBarColor.toString() +
        '-' +
        inactiveDisabledTrackBarColor.toString() +
        '-' +
        activeTrackBarHeight.toString() +
        '-' +
        inactiveTrackBarHeight.toString() +
        '-' +
        centralWidget.toString();
  }
}

class FlutterSliderIgnoreSteps {
  final double from;
  final double to;

  FlutterSliderIgnoreSteps({this.from, this.to})
      : assert(from != null && to != null && from <= to);

  @override
  String toString() {
    return from.toString() + '-' + to.toString();
  }
}

class FlutterSliderFixedValue {
  final int percent;
  final dynamic value;

  FlutterSliderFixedValue({this.percent, this.value})
      : assert(percent != null && value != null && percent >= 0 && percent <= 100);

  @override
  String toString() {
    return percent.toString() + '-' + value.toString();
  }
}

class FlutterSliderHandlerAnimation {
  final Curve curve;
  final Curve reverseCurve;
  final Duration duration;
  final double scale;

  const FlutterSliderHandlerAnimation(
      {this.curve = Curves.elasticOut,
      this.reverseCurve,
      this.duration = const Duration(milliseconds: 700),
      this.scale = 1.3})
      : assert(curve != null && duration != null && scale != null);

  @override
  String toString() {
    return curve.toString() +
        '-' +
        reverseCurve.toString() +
        '-' +
        duration.toString() +
        '-' +
        scale.toString();
  }
}

class FlutterSliderHatchMark {
  bool disabled;
  double density;
  double linesDistanceFromTrackBar;
  double labelsDistanceFromTrackBar;
  List<FlutterSliderHatchMarkLabel> labels;
  FlutterSliderSizedBox smallLine;
  FlutterSliderSizedBox bigLine;
  FlutterSliderSizedBox labelBox;
  FlutterSliderHatchMarkAlignment linesAlignment;
  bool displayLines;

  FlutterSliderHatchMark(
      {this.disabled = false,
      this.density = 1,
      this.linesDistanceFromTrackBar,
      this.labelsDistanceFromTrackBar,
      this.labels,
      this.smallLine,
      this.bigLine,
      this.linesAlignment = FlutterSliderHatchMarkAlignment.right,
      this.labelBox,
      this.displayLines})
      : assert(disabled != null),
        assert(density != null && density > 0 && density <= 2);

  @override
  String toString() {
    return disabled.toString() +
        '-' +
        density.toString() +
        '-' +
        linesDistanceFromTrackBar.toString() +
        '-' +
        labelsDistanceFromTrackBar.toString() +
        '-' +
        labels.toString() +
        '-' +
        smallLine.toString() +
        '-' +
        bigLine.toString() +
        '-' +
        labelBox.toString() +
        '-' +
        linesAlignment.toString() +
        '-' +
        displayLines.toString();
  }
}

class FlutterSliderHatchMarkLabel {
  final double percent;
  final Widget label;

  FlutterSliderHatchMarkLabel({
    this.percent,
    this.label,
  }) : assert((label == null && percent == null) ||
            (label != null && percent != null && percent >= 0));

  @override
  String toString() {
    return percent.toString() + '-' + label.toString();
  }
}

class FlutterSliderSizedBox {
  final BoxDecoration decoration;
  final BoxDecoration foregroundDecoration;
  final Matrix4 transform;
  final double width;
  final double height;

  const FlutterSliderSizedBox(
      {this.decoration,
      this.foregroundDecoration,
      this.transform,
      @required this.height,
      @required this.width})
      : assert(width != null && height != null && width > 0 && height > 0);

  @override
  String toString() {
    return width.toString() +
        '-' +
        height.toString() +
        '-' +
        decoration.toString() +
        '-' +
        foregroundDecoration.toString() +
        '-' +
        transform.toString();
  }
}

class FlutterSliderStep {
  final double step;
  final bool isPercentRange;
  final List<FlutterSliderRangeStep> rangeList;

  const FlutterSliderStep({
    this.step = 1,
    this.isPercentRange = true,
    this.rangeList,
  }) : assert(step != null && isPercentRange != null);

  @override
  String toString() {
    return step.toString() + '-' + isPercentRange.toString() + '-' + rangeList.toString();
  }
}

class FlutterSliderRangeStep {
  final double from;
  final double to;
  final double step;

  FlutterSliderRangeStep({
    this.from,
    this.to,
    this.step,
  }) : assert(from != null && to != null && step != null);

  @override
  String toString() {
    return from.toString() + '-' + to.toString() + '-' + step.toString();
  }
}

enum FlutterSliderTooltipDirection { top, left, right }

enum FlutterSliderHatchMarkAlignment { left, right }
