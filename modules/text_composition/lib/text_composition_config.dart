import 'package:flutter/material.dart';

import 'text_composition.dart';

enum AnimationType {
  simulation,
  simulation2L,
  simulation2R,
  simulationHalf,
  scroll,
  slide,
  slideHorizontal,
  slideVertical,
  cover,
  coverHorizontal,
  coverVertical,
  curl,
  flip,
}

/// + 这里配置需要离线保存和加载
/// + 其他配置实时计算
///
class TextCompositionConfig {
  /// bool
  bool showStatus;
  bool showInfo; // info , index/total percent - right 60px
  bool justifyHeight;
  bool oneHand;
  bool underLine;
  bool animationStatus;
  bool animationHighImage;
  bool animationWithImage;
  AnimationType animation;
  int animationDuration;

  /// padding
  double topPadding;
  double leftPadding;
  double bottomPadding;
  double rightPadding;
  double titlePadding;
  double paragraphPadding;
  double columnPadding;

  /// font
  int columns; // <1 <==> auto
  int indentation;
  Color fontColor;
  double fontSize;
  double fontHeight;
  String fontFamily;

  // string
  String background; // 图片 未实现
  Color backgroundColor;

  TextCompositionConfig({
    this.showStatus = true,
    this.showInfo = true,
    this.justifyHeight = true,
    this.oneHand = false,
    this.underLine = true,
    this.animationStatus = true,
    this.animationHighImage = false,
    this.animationWithImage = true,
    this.animation = AnimationType.cover,
    this.animationDuration = 450,
    this.topPadding = 16,
    this.leftPadding = 16,
    this.bottomPadding = 16,
    this.rightPadding = 16,
    this.titlePadding = 30,
    this.paragraphPadding = 18,
    this.columnPadding = 30,
    this.columns = 0,
    this.indentation = 2,
    this.fontColor = const Color(0xFF303133),
    this.fontSize = 20,
    this.fontHeight = 1.6,
    this.fontFamily = '',
    this.background = '#FFFFFFCC',
    this.backgroundColor = const Color(0xFFFFFFCC),
  });

  bool updateConfig({
    bool? showStatus,
    bool? showInfo,
    bool? justifyHeight,
    bool? oneHand,
    bool? underLine,
    bool? animationStatus,
    bool? animationHighImage,
    bool? animationWithImage,
    AnimationType? animation,
    int? animationDuration,
    double? topPadding,
    double? leftPadding,
    double? bottomPadding,
    double? rightPadding,
    double? titlePadding,
    double? paragraphPadding,
    double? columnPadding,
    int? columns,
    int? indentation,
    Color? fontColor,
    double? fontSize,
    double? fontHeight,
    String? fontFamily,
    String? background,
    Color? backgroundColor,
  }) {
    bool? update;

    if (showStatus != null && this.showStatus != showStatus) {
      this.showStatus = showStatus;
      update ??= true;
    }
    if (showInfo != null && this.showInfo != showInfo) {
      this.showInfo = showInfo;
      update ??= true;
    }
    if (justifyHeight != null && this.justifyHeight != justifyHeight) {
      this.justifyHeight = justifyHeight;
      update ??= true;
    }
    if (oneHand != null && this.oneHand != oneHand) {
      this.oneHand = oneHand;
      update ??= true;
    }
    if (underLine != null && this.underLine != underLine) {
      this.underLine = underLine;
      update ??= true;
    }
    if (animationStatus != null && this.animationStatus != animationStatus) {
      this.animationStatus = animationStatus;
      update ??= true;
    }
    if (animationHighImage != null && this.animationHighImage != animationHighImage) {
      this.animationHighImage = animationHighImage;
      update ??= true;
    }
    if (animationWithImage != null && this.animationWithImage != animationWithImage) {
      this.animationWithImage = animationWithImage;
      update ??= true;
    }
    if (animation != null && this.animation != animation) {
      this.animation = animation;
      update ??= true;
    }
    if (animationDuration != null && this.animationDuration != animationDuration) {
      this.animationDuration = animationDuration;
      update ??= true;
    }
    if (topPadding != null && this.topPadding != topPadding) {
      this.topPadding = topPadding;
      update ??= true;
    }
    if (leftPadding != null && this.leftPadding != leftPadding) {
      this.leftPadding = leftPadding;
      update ??= true;
    }
    if (bottomPadding != null && this.bottomPadding != bottomPadding) {
      this.bottomPadding = bottomPadding;
      update ??= true;
    }
    if (rightPadding != null && this.rightPadding != rightPadding) {
      this.rightPadding = rightPadding;
      update ??= true;
    }
    if (titlePadding != null && this.titlePadding != titlePadding) {
      this.titlePadding = titlePadding;
      update ??= true;
    }
    if (paragraphPadding != null && this.paragraphPadding != paragraphPadding) {
      this.paragraphPadding = paragraphPadding;
      update ??= true;
    }
    if (columnPadding != null && this.columnPadding != columnPadding) {
      this.columnPadding = columnPadding;
      update ??= true;
    }
    if (columns != null && this.columns != columns) {
      this.columns = columns;
      update ??= true;
    }
    if (indentation != null && this.indentation != indentation) {
      this.indentation = indentation;
      update ??= true;
    }
    if (fontColor != null && this.fontColor != fontColor) {
      this.fontColor = fontColor;
      update ??= true;
    }
    if (fontSize != null && this.fontSize != fontSize) {
      this.fontSize = fontSize;
      update ??= true;
    }
    if (fontHeight != null && this.fontHeight != fontHeight) {
      this.fontHeight = fontHeight;
      update ??= true;
    }
    if (fontFamily != null && this.fontFamily != fontFamily) {
      this.fontFamily = fontFamily;
      update ??= true;
    }
    if (background != null && this.background != background) {
      this.background = background;
      update ??= true;
    }
    if (backgroundColor != null && this.backgroundColor != backgroundColor) {
      this.backgroundColor = backgroundColor;
      update ??= true;
    }

    return update == true;
  }

  /// Creates an instance of this class from a JSON object.
  factory TextCompositionConfig.fromJSON(Map<String, dynamic> encoded) {
    return TextCompositionConfig(
      showStatus: cast(encoded['showStatus'], true),
      showInfo: cast(encoded['showInfo'], true),
      justifyHeight: cast(encoded['justifyHeight'], true),
      oneHand: cast(encoded['oneHand'], false),
      underLine: cast(encoded['underLine'], true),
      animationStatus: cast(encoded['animationStatus'], true),
      animationHighImage: cast(encoded['animationHighImage'], false),
      animationWithImage: cast(encoded['animationWithImage'], true),
      animation: AnimationType.values.firstWhere(
          (a) => a.name == cast(encoded['animation'], ''),
          orElse: () => AnimationType.cover),
      animationDuration: cast(encoded['animationDuration'], 400),
      topPadding: cast(encoded['topPadding'], 16),
      leftPadding: cast(encoded['leftPadding'], 16),
      bottomPadding: cast(encoded['bottomPadding'], 16),
      rightPadding: cast(encoded['rightPadding'], 16),
      titlePadding: cast(encoded['titlePadding'], 30),
      paragraphPadding: cast(encoded['paragraphPadding'], 18),
      columnPadding: cast(encoded['columnPadding'], 30),
      columns: cast(encoded['columns'], 0),
      indentation: cast(encoded['indentation'], 2),
      fontColor: Color(cast(encoded['fontColor'], 0xFF303133)),
      fontSize: cast(encoded['fontSize'], 20),
      fontHeight: cast(encoded['fontHeight'], 1.6),
      fontFamily: cast(encoded['fontFamily'], ''),
      background: cast(encoded['background'], '#FFFFFFCC'),
      backgroundColor: Color(cast(encoded['backgroundColor'], 0xFFFFFFCC)),
    );
  }

  /// Returns a representation of this object as a JSON object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'showStatus': showStatus,
      'showInfo': showInfo,
      'justifyHeight': justifyHeight,
      'oneHand': oneHand,
      'underLine': underLine,
      'animationStatus': animationStatus,
      'animationHighImage': animationHighImage,
      'animationWithImage': animationWithImage,
      'animation': animation.name,
      'animationDuration': animationDuration,
      'topPadding': topPadding,
      'leftPadding': leftPadding,
      'bottomPadding': bottomPadding,
      'rightPadding': rightPadding,
      'titlePadding': titlePadding,
      'paragraphPadding': paragraphPadding,
      'columnPadding': columnPadding,
      'columns': columns,
      'indentation': indentation,
      'fontColor': fontColor.value,
      'fontSize': fontSize,
      'fontHeight': fontHeight,
      'fontFamily': fontFamily,
      'background': background,
      'backgroundColor': backgroundColor.value,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextCompositionConfig &&
        other.showStatus == showStatus &&
        other.showInfo == showInfo &&
        other.justifyHeight == justifyHeight &&
        other.oneHand == oneHand &&
        other.underLine == underLine &&
        other.animationStatus == animationStatus &&
        other.animationHighImage == animationHighImage &&
        other.animationWithImage == animationWithImage &&
        other.animation == animation &&
        other.animationDuration == animationDuration &&
        other.topPadding == topPadding &&
        other.leftPadding == leftPadding &&
        other.bottomPadding == bottomPadding &&
        other.rightPadding == rightPadding &&
        other.titlePadding == titlePadding &&
        other.paragraphPadding == paragraphPadding &&
        other.columnPadding == columnPadding &&
        other.columns == columns &&
        other.indentation == indentation &&
        other.fontColor == fontColor &&
        other.fontSize == fontSize &&
        other.fontHeight == fontHeight &&
        other.fontFamily == fontFamily &&
        other.background == background &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => super.hashCode;
}
