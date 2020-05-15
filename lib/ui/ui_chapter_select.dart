import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';

import 'ui_dash.dart';

class UIChapterSelect extends StatelessWidget {
  final SearchItem searchItem;
  final Function(int index) loadChapter;
  const UIChapterSelect({
    this.loadChapter,
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height / 2 - 10;
    final itemHeight = 46.0;
    final height = searchItem.chapters.length * itemHeight;
    final durHeight = searchItem.durChapterIndex * itemHeight;
    double offset;
    if (height < screenHeight) {
      offset = 1.0;
    } else if ((height - durHeight) < screenHeight) {
      offset = height - screenHeight - 1;
    } else {
      offset = durHeight;
    }
    final primaryColor = Theme.of(context).primaryColor;
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          height: size.height / 2,
          width: size.width * 0.85,
          child: ListView.builder(
            itemExtent: itemHeight,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            controller: ScrollController(initialScrollOffset: offset),
            itemCount: searchItem.chapters.length,
            itemBuilder: (_, index) {
              return Container(
                height: itemHeight,
                child: _buildChapter(index, primaryColor),
              );
            },
          ),
        ),
      ),
    );
  }

  Column _buildChapter(int index, Color primaryColor) {
    return Column(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => loadChapter(index),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${searchItem.chapters[index].name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                searchItem.durChapterIndex == index
                    ? Icon(
                        Icons.done,
                        color: primaryColor,
                      )
                    : Container()
              ],
            ),
          ),
        ),
        UIDash(height: 0.5, dashWidth: 4, color: Colors.grey),
      ],
    );
  }
}
