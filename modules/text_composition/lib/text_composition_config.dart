import 'package:flutter/material.dart';

import 'text_composition.dart';

/// + 这里配置需要离线保存和加载
/// + 其他配置实时计算
///
/// - [animationTap]
/// - [animationDrag]
/// - [animationDragEnd]
/// - [justifyHeight]
/// - [showInfo]
/// - [animation]
/// - [animationDuration]
/// - [topPadding]
/// - [leftPadding]
/// - [bottomPadding]
/// - [rightPadding]
/// - [titlePadding]
/// - [paragraphPadding]
/// - [columnPadding]
/// - [columns]
/// - [indentation]
/// - [fontColor]
/// - [fontSize]
/// - [fontHeight]
/// - [fontFamily]
/// - [background]
class TextCompositionConfig {
  /// bool
  bool animationTap;
  bool animationDrag;
  bool animationDragEnd;
  bool justifyHeight;
  bool showInfo; // info size - 100px, index/total percent - right 100px
  String animation;
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
    this.animationTap = true,
    this.animationDrag = true,
    this.animationDragEnd = true,
    this.justifyHeight = true,
    this.showInfo = true,
    this.animation = 'curl',
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
    bool? animationTap,
    bool? animationDrag,
    bool? animationDragEnd,
    bool? justifyHeight,
    bool? showInfo,
    String? animation,
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

    if (animationTap != null && this.animationTap != animationTap) {
      this.animationTap = animationTap;
      update ??= true;
    }
    if (animationDrag != null && this.animationDrag != animationDrag) {
      this.animationDrag = animationDrag;
      update ??= true;
    }
    if (animationDragEnd != null && this.animationDragEnd != animationDragEnd) {
      this.animationDragEnd = animationDragEnd;
      update ??= true;
    }
    if (justifyHeight != null && this.justifyHeight != justifyHeight) {
      this.justifyHeight = justifyHeight;
      update ??= true;
    }
    if (showInfo != null && this.showInfo != showInfo) {
      this.showInfo = showInfo;
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
      // text: encoded['text'] as String,
      animationTap: cast(encoded['animationTap'], true),
      animationDrag: cast(encoded['animationDrag'], true),
      animationDragEnd: cast(encoded['animationDragEnd'], true),
      justifyHeight: cast(encoded['justifyHeight'], true),
      showInfo: cast(encoded['showInfo'], true),
      animation: cast(encoded['animation'], 'curl'),
      animationDuration: cast(encoded['animationDuration'], 300),
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
      'animationTap': animationTap,
      'animationDrag': animationDrag,
      'animationDragEnd': animationDragEnd,
      'justifyHeight': justifyHeight,
      'showInfo': showInfo,
      'animation': animation,
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
        other.animationTap == animationTap &&
        other.animationDrag == animationDrag &&
        other.animationDragEnd == animationDragEnd &&
        other.justifyHeight == justifyHeight &&
        other.showInfo == showInfo &&
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
