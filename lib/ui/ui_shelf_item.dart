import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_image_item.dart';

import '../database/search_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiShelfItem extends StatelessWidget {
  final SearchItem searchItem;

  const UiShelfItem({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _UiShelfItem(
      origin: searchItem.origin,
      cover: searchItem.cover,
      title: searchItem.name,
      author: searchItem.author,
      chapter: searchItem.chapter,
      durChapter: searchItem.durChapter,
      chapterNum: searchItem.chaptersCount - searchItem.durChapterIndex - 1,
    );
  }
}

class _UiShelfItem extends StatelessWidget {
  final String origin;
  final String cover;
  final String title;
  final String author;
  final String chapter;
  final String durChapter;
  final int chapterNum;

  const _UiShelfItem({
    this.origin,
    this.cover,
    this.title,
    this.author,
    this.chapter,
    this.durChapter,
    this.chapterNum,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 80,
            height: double.infinity,
            child: UIImageItem(cover: cover),
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
                          fontFamily: ESOTheme.staticFontFamily,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    chapterNum == 0
                        ? Container()
                        : Container(
                            alignment: Alignment(0, 0),
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(Radius.circular(8))),
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Text(
                              '$chapterNum',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
                Text(
                  '$origin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                  ),
                ),
                Text(
                  '更新至 $chapter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '阅读至 $durChapter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
