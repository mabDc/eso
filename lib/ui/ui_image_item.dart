import 'dart:convert';

import 'package:flutter/material.dart';

import '../global.dart';

class UIImageItem extends StatelessWidget {
  final String cover;

  const UIImageItem({
    this.cover,
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
    print(_cover);
    print(headers);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: FadeInImage(
        placeholder: AssetImage(Global.waitingPath),
        image: checkUrl(_cover,headers),
        fit: BoxFit.cover,
      ),
    );
  }

  ImageProvider checkUrl(String url,Map<String, String> header) {
    try {
      return NetworkImage(url,headers: header);
    } catch (e) {
      return AssetImage(Global.waitingPath);
    }
  }
}
