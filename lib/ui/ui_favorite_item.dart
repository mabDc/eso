import 'package:eso/api/api.dart';
import 'package:eso/eso_theme.dart';

import 'ui_image_item.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class UIFavoriteItem extends StatelessWidget {
  final SearchItem searchItem;

  const UIFavoriteItem({
    @required this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = searchItem.chaptersCount.toString();
    final currentCount = searchItem.durChapterIndex + 1;
    final suffix = {
      API.NOVEL: "章",
      API.MANGA: "话",
      API.AUDIO: "首",
      API.VIDEO: "集",
    };
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
            child: Container(
          width: double.infinity,
          child: UIImageItem(cover: searchItem.cover),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black12)
          ]),
        )),
        SizedBox(height: 6),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            '${searchItem.name}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            '${"0" * (count.length - currentCount.toString().length)}$currentCount${suffix[searchItem.ruleContentType]}/$count${suffix[searchItem.ruleContentType]}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: ESOTheme.staticFontFamily,
              fontSize: 10,
            ),
          ),
        ),
        SizedBox(height: 6),
      ],
    );
  }
}
