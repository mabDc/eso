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
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
            child: Container(
          width: double.infinity,
          height: 150,
          child: UIImageItem(cover: searchItem.cover),
        )),
        Container(
          alignment: Alignment.bottomLeft,
          margin: EdgeInsets.only(top: 5),
          child: Text(
            '${searchItem.name}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            '${searchItem.durChapterIndex + 1}话/${searchItem.chaptersCount}话',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
