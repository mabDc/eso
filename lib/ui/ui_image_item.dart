import 'dart:convert';

import 'package:flutter/material.dart';

import '../global.dart';
import 'ui_fade_in_image.dart';

class UIImageItem extends StatelessWidget {
  final String cover;
  final double radius;
  final BoxFit fit;

  const UIImageItem({
    this.cover,
    this.radius = 3.0,
    this.fit,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cover == null) {
      return Image.asset(
        Global.waitingPath,
        fit: BoxFit.cover,
      );
    }
    String _cover = cover;
    Map<String, String> headers = Map<String, String>();
    final ss = _cover.split('@headers');
    if (ss.length > 1) {
      _cover = ss[0];
      headers = (jsonDecode(ss[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
    }
    if (radius == null || radius <= 0.0) return UIFadeInImage(url: _cover, header: headers, fit: fit);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: UIFadeInImage(url: _cover, header: headers, fit: fit),
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
