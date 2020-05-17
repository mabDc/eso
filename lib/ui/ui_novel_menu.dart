import 'dart:math';

import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class UINovelMenu extends StatelessWidget {
  final SearchItem searchItem;
  const UINovelMenu({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
    final color = Theme.of(context).textTheme.bodyText1.color;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: _buildTopRow(context, bgColor, color),
        ),
        provider.showSetting
            ? _buildSetting(context, bgColor, color)
            : _buildBottomRow(context, bgColor, color),
      ],
    );
  }

  Widget _buildSetting(BuildContext context, Color bgColor, Color color) {
    return IconTheme(
      data: IconThemeData(size: 18, color: color),
      child: Container(
        width: double.infinity,
        height: 220,
        color: bgColor,
        padding: EdgeInsets.fromLTRB(25, 4, 25, 16),
        child: Row(
          children: [
            Container(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("亮度", style: TextStyle(color: color.withOpacity(0.7))),
                  Text("字号", style: TextStyle(color: color.withOpacity(0.7))),
                  Text("高度", style: TextStyle(color: color.withOpacity(0.7))),
                  Text("背景", style: TextStyle(color: color.withOpacity(0.7))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.brightness_low),
                        SizedBox(width: 6),
                        Expanded(
                          child: SeekBar(
                            value: 0.4,
                            max: 1,
                            backgroundColor: color,
                            progressColor: Theme.of(context).primaryColor,
                            progresseight: 3,
                            afterDragShowSectionText: true,
                            onValueChanged: (progress) {},
                            indicatorRadius: 4,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.brightness_high),
                        SizedBox(width: 10),
                        Text("长亮"),
                        Switch(
                          value: true,
                          onChanged: (value) => null,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlineButton(
                            child: Text("小", style: TextStyle(color: color)),
                            onPressed: () => null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: color),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Text("20"),
                        SizedBox(width: 15),
                        Expanded(
                          child: OutlineButton(
                            child: Text("大", style: TextStyle(color: color)),
                            onPressed: () => null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18)),
                              border: Border.all(color: color.withOpacity(0.3))),
                          alignment: Alignment.center,
                          child:
                              // Icon(Icons.drag_handle),
                              Transform.rotate(
                            angle: pi / 2,
                            child: Icon(Icons.pause),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18)),
                              border: Border.all(color: color.withOpacity(0.3))),
                          alignment: Alignment.center,
                          child: Icon(Icons.menu),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18)),
                              border: Border.all(color: color.withOpacity(0.3))),
                          alignment: Alignment.center,
                          child: Icon(Icons.view_headline),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18)),
                              border: Border.all(color: color.withOpacity(0.3))),
                          alignment: Alignment.center,
                          child: Text("无"),
                        ),
                        Container(
                          width: 60,
                          height: 32,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              border: Border.all(color: color.withOpacity(0.3))),
                          alignment: Alignment.center,
                          child: Text("自定义"),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 18.0,
                              backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEA, 0xDE),
                            ),
                            CircleAvatar(
                              radius: 18.0,
                              backgroundColor: Color.fromARGB(0xFF, 0xDB, 0xBE, 0x98),
                            ),
                            CircleAvatar(
                              radius: 18.0,
                              backgroundColor: Color.fromARGB(0xFF, 0xC1, 0xEC, 0xC7),
                            ),
                            CircleAvatar(
                              radius: 18.0,
                              backgroundColor: Color.fromARGB(0xFF, 0x37, 0x3A, 0x3F),
                            ),
                            Container(
                              width: 60,
                              height: 32,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                  border: Border.all(color: color.withOpacity(0.3))),
                              alignment: Alignment.center,
                              child: Text("更多"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, Color bgColor, Color color) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(color: bgColor),
      padding: EdgeInsets.fromLTRB(12, 4 + MediaQuery.of(context).padding.top, 12, 4),
      child: Row(
        children: <Widget>[
          InkWell(
            child: Icon(Icons.arrow_back_ios, color: color, size: 26),
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${searchItem.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, color: color),
                ),
                Text(
                  '${searchItem.author}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.75)),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            child: Icon(Icons.share, color: color, size: 26),
            onTap: Provider.of<NovelPageProvider>(context, listen: false).share,
          ),
          _buildPopupmenu(context, bgColor, color),
        ],
      ),
    );
  }

  Widget _buildPopupmenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const SELECTABLE = 2;
    const ADD_ITEM = 3;
    final primaryColor = Theme.of(context).primaryColor;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.more_vert, color: color, size: 26),
      color: bgColor,
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case TO_CLICPBOARD:
            Clipboard.setData(
                ClipboardData(text: searchItem.chapters[searchItem.durChapterIndex].url));
            Toast.show(
                "已复制地址\n" + searchItem.chapters[searchItem.durChapterIndex].url, context);
            break;
          case LAUCH:
            launch(searchItem.chapters[searchItem.durChapterIndex].url);
            break;
          case SELECTABLE:
            provider.useSelectableText = !provider.useSelectableText;
            break;
          case ADD_ITEM:
            // TODO: 收藏
            Toast.show("功能未完成，请返回详情页操作", context, duration: 1);
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('复制原地址'),
              Icon(Icons.content_copy, color: primaryColor),
            ],
          ),
          value: TO_CLICPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('查看原页面'),
              Icon(Icons.launch, color: primaryColor),
            ],
          ),
          value: LAUCH,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(provider.useSelectableText ? '退出复制模式' : '进入复制模式'),
              Icon(
                provider.useSelectableText ? Icons.flip_to_back : Icons.flip_to_front,
                color: primaryColor,
              ),
            ],
          ),
          value: SELECTABLE,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('加入收藏'),
              Icon(
                Icons.add_to_photos,
                color: primaryColor,
              ),
            ],
          ),
          value: ADD_ITEM,
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, Color bgColor, Color color) {
    final currentCount = searchItem.durChapterIndex;
    final chapterCount = searchItem.chaptersCount.toString();
    final provider = Provider.of<NovelPageProvider>(context);
    return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                InkWell(
                  child: Text(
                    '章节',
                    style: TextStyle(color: color.withOpacity(0.75)),
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SeekBar(
                    value: searchItem.durChapterIndex.toDouble(),
                    max: searchItem.chaptersCount.toDouble(),
                    backgroundColor: color,
                    progressColor: Theme.of(context).primaryColor,
                    progresseight: 3,
                    afterDragShowSectionText: true,
                    onValueChanged: (progress) {
                      provider.loadChapteDebounce(progress.value.toInt());
                    },
                    indicatorRadius: 8,
                    indicatorColor: color.withOpacity(0.9),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  child: Text(
                    '${'0' * (chapterCount.length - (currentCount + 1).toString().length)}${currentCount + 1} / $chapterCount',
                    style: TextStyle(color: color.withOpacity(0.75)),
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_back, color: color, size: 28),
                        Text("上一章", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => provider.loadChapter(currentCount - 1),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.format_list_bulleted, color: color, size: 28),
                        Text("目录", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => provider.showChapter = !provider.showChapter,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.text_format, color: color, size: 28),
                        Text("调节", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () {
                      provider.showChapter = false;
                      provider.showSetting = true;
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_forward, color: color, size: 28),
                        Text("下一章", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => provider.loadChapter(currentCount + 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
