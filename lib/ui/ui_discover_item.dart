import 'package:eso/utils.dart';

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
            margin: const EdgeInsets.all(4),
            child: UIImageItem(cover: searchItem.cover, hero: Utils.empty(searchItem.cover) ? null : "${searchItem.name}.${searchItem.cover}.${searchItem.id}"),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor, width: 0.1)
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
