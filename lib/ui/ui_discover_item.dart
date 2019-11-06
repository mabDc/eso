import 'dart:ui';

import 'ui_image_item.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class UIDiscoverItem extends StatelessWidget {
  final SearchItem searchItem;

  const UIDiscoverItem({
    @required this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          child: UIImageItem(cover: searchItem.cover),
        ),
        Container(color: Colors.black.withAlpha(30)),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            '${searchItem.name}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
