import 'dart:ui';

import 'package:flutter/material.dart';
import '../database/chapter_item.dart';

class UIBigListChapterItem extends StatelessWidget {
  final ChapterItem chapter;
  final int chapterNum;

  const UIBigListChapterItem({
    this.chapter,
    this.chapterNum,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _UIBigListChapterItem(
      index: chapterNum,
      title: chapter.name,
      subtitle: chapter.time,
      thumbnail: chapter.cover,
    );
  }
}

class _UIBigListChapterItem extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String thumbnail;

  const _UIBigListChapterItem({
    this.index,
    this.title,
    this.subtitle,
    this.thumbnail,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: double.infinity,
            child: Center(
              child: Text(
                '${index < 10 ? '0':''}$index',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: subtitle == null
                ? Text(
                    '$title'.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        '$title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$subtitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          thumbnail == null
              ? Container()
              : SizedBox(
                  width: 100,
                  height: double.infinity,
                  child: Image.network(
                    '$thumbnail',
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }
}
