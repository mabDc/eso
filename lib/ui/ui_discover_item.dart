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
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            child: UIImageItem(cover: searchItem.cover),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[BoxShadow(offset: Offset(4, 4), blurRadius: 3)]
            ),
        )),
        Container(
          alignment: Alignment.bottomLeft,
          margin: EdgeInsets.only(top: 4, bottom: 2, left: 4),
          child: Text(
            '${searchItem.name}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
