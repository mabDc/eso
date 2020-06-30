import 'ui_image_item.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class UIDiscover2Item extends StatelessWidget {
  final SearchItem item;

  const UIDiscover2Item({
    @required this.item,
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
            child: UIImageItem(cover: item.cover, hero: "${item.name}.${item.cover}"),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor, width: 0.1)
            ),
        )),
        Container(
          alignment: Alignment.bottomLeft,
          margin: EdgeInsets.only(top: 4, bottom: 4, left: 4),
          child: Text(
            '${item.name}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
