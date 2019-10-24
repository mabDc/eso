import 'package:flutter/material.dart';
import '../database/chapter_item.dart';

class UIBigListChapterItem extends StatelessWidget {
  final ChapterItem chapter;

  const UIBigListChapterItem({
    this.chapter,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chapter.cover == null
        ? chapter.time == null
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                alignment: FractionalOffset.centerLeft,
                height: 55,
                child: Text('${chapter.name}'),
              )
            : _UIBigListChapterItemWithoutCover(
                name: chapter.name,
                time: chapter.time,
              )
        : _UIBigListChapterItem(
            cover: chapter.cover,
            name: chapter.name,
            time: chapter.time,
          );
  }
}

class _UIBigListChapterItem extends StatelessWidget {
  final String cover;
  final String name;
  final String time;

  const _UIBigListChapterItem({
    this.cover,
    this.name,
    this.time,
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
              child: Image.network(
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
                  Text(
                    '$name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$time',
                    maxLines: 1,
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

class _UIBigListChapterItemWithoutCover extends StatelessWidget {
  final String name;
  final String time;

  const _UIBigListChapterItemWithoutCover({
    this.name,
    this.time,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      alignment: FractionalOffset.centerLeft,
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$time',
                    maxLines: 1,
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
