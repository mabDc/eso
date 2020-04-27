import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:url_launcher/url_launcher.dart';

class UIMangaMenu extends StatelessWidget {
  final SearchItem searchItem;
  final Function(int index) loadChapter;
  const UIMangaMenu({
    this.loadChapter,
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).padding.top,
          color: Color(0xB0000000),
        ),
        _buildTopRow(context),
        Expanded(
          child: Container(),
        ),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x40000000),
            Color(0x90000000),
            Color(0xB0000000),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              InkWell(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 26,
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  '${searchItem.durChapter}'.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 26,
                ),
                onTap: () {},
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 26,
                ),
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 10),
          InkWell(
            child: Text(
              searchItem.chapters[searchItem.durChapterIndex].url,
              style: TextStyle(color: Colors.white, ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            onTap: () =>
                launch(searchItem.chapters[searchItem.durChapterIndex].url),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x40000000),
            Color(0x90000000),
            Color(0xB0000000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: <Widget>[
              InkWell(
                child: Text(
                  '上一章',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => loadChapter(searchItem.durChapterIndex - 1),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: SeekBar(
                  value: searchItem.durChapterIndex.toDouble(),
                  max: searchItem.chaptersCount.toDouble(),
                  backgroundColor: Colors.white54,
                  progresseight: 4,
                  afterDragShowSectionText: true,
                  onValueChanged: (progress) {
                    progress.value.toInt();
                  },
                  indicatorRadius: 5,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                child: Text(
                  '下一章',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => loadChapter(searchItem.durChapterIndex + 1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                child: Icon(
                  Icons.list,
                  color: Colors.white,
                  size: 32,
                ),
                onTap: () {},
              ),
              InkWell(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
                onTap: () {},
              ),
              InkWell(
                child: Icon(
                  Icons.brightness_medium,
                  color: Colors.white,
                  size: 32,
                ),
                onTap: () {},
              ),
              InkWell(
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 32,
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
