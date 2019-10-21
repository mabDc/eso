import 'package:flutter/material.dart';

import '../global.dart';

class UIBigListChapterItem extends StatelessWidget {
  final String cover;
  final String title;
  final String subtitle;

  const UIBigListChapterItem({
    this.cover,
    this.title,
    this.subtitle,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      alignment: FractionalOffset.centerLeft,
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 100,
              height: double.infinity,
              child: cover == null
                  ? Image.asset(
                      Global.waitingPath,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      '$cover',
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('$title'),
                  Text('$subtitle'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
