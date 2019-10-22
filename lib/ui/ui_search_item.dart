import 'package:flutter/material.dart';
import '../global.dart';
import '../database/search_item.dart';

class UiSearchItem extends StatelessWidget {
  final SearchItem item;

  const UiSearchItem({
    @required
    this.item,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _UiSearchItem(
      origin:item.origin,
      cover:item.cover,
      title:item.title,
      author:item.author,
      chapter:item.chapter,
      description:item.description,
    );
  }
}


class _UiSearchItem extends StatelessWidget {
  final String origin;
  final String cover;
  final String title;
  final String author;
  final String chapter;
  final String description;

  const _UiSearchItem({
    this.origin,
    this.cover,
    this.title,
    this.author,
    this.chapter,
    this.description,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 80,
              height: double.infinity,
              child: cover == null
                  ? Image.asset(
                      Global.waitingPath,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      cover,
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '$title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        '$origin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .body1
                              .color
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .body1
                          .color
                          .withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '$chapter',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
