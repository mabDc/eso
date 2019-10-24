import '../database/search_item.dart';
import '../global.dart';
import 'package:flutter/material.dart';

class UIDiscoverItem extends StatelessWidget {
  final SearchItem item;

  const UIDiscoverItem({
    @required this.item,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(item.cover ?? Global.waitingPath, fit: BoxFit.cover,),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: EdgeInsets.all(4),
            color: Colors.black.withAlpha(50),
            width: double.infinity,
            child: Text(
              '${item.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
