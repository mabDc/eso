import 'package:flutter/material.dart';

import '../global.dart';
import '../page/photo_view_page.dart';
import 'ui_fade_in_image.dart';

class UIImageItem extends StatelessWidget {
  final String cover;
  final double radius;
  final double initWidth;
  final double initHeight;
  final BoxFit fit;
  final String hero;

  const UIImageItem({
    this.cover,
    this.radius = 3.0,
    this.initWidth = 400,
    this.initHeight = 400,
    this.fit,
    this.hero,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cover == null) {
      return Image.asset(
        Global.waitingPath,
        fit: fit,
        height: initWidth,
        width: initHeight,
      );
    }
    final _child = ClipRRect(
      borderRadius: radius == null || radius <= 0.0
          ? BorderRadius.zero
          : BorderRadius.circular(radius),
      child: UIFadeInImage(
        item: PhotoItem.parse(cover),
        fit: fit,
        placeHolderWidth: initWidth,
        placeHolderHeight: initHeight,
      ),
    );
    if (hero == null || hero.isEmpty) return _child;
    return Hero(
      child: _child,
      tag: hero,
    );
  }

  // ImageProvider checkUrl(String url, Map<String, String> header) {
  //   try {
  //     return NetworkImage(url, headers: header);
  //   } catch (e) {
  //     return AssetImage(Global.nowayPath);
  //   }
  // }
}
