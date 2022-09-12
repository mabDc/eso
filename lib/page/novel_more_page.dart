import 'dart:convert';

import 'package:eso/database/search_item.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/editor/highlight.dart';
import 'package:eso/eso_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../ui/ui_fade_in_image.dart';
import '../ui/ui_image_item.dart';
import 'content_page_manager.dart';
import 'photo_view_page.dart';
import 'dart:ui' as ui;

class NovelMorePage extends StatelessWidget {
  final SearchItem searchItem;
  NovelMorePage({Key key, this.searchItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: contentProvider.loadChapter(searchItem.durChapterIndex),
        initialData: null,
        builder: (BuildContext _, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return LandingPage();
          }
          return RawKeyboardListener(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.titleSmall.color),
                              children:
                                  buildSpansFlatter(snapshot.data, searchItem.chapter))),
                    ),
                  ),
                ],
              ),
            ),
            focusNode: FocusNode()..requestFocus(),
            onKey: (event) {
              // 按下时触发
              if (event.runtimeType.toString() == 'RawKeyUpEvent') return;

              if (event.data is RawKeyEventDataMacOs) {
                RawKeyEventDataMacOs data = event.data;
                print(data.keyCode);
                switch (data.keyCode) {
                  case 123: // 方向键左
                    break;
                  case 124: // 方向键右
                    break;
                  case 53: // esc
                    Navigator.of(context).pop();
                    break;
                  case 27: // -
                    break;
                  case 24: // +
                    break;
                  case 36: //enter
                    break;
                }
              } else if (event.data is RawKeyEventDataWindows) {
                RawKeyEventDataWindows data = event.data;
                print(data.keyCode);
                switch (data.keyCode) {
                  // case 123: // 方向键左
                  //   break;
                  // case 124: // 方向键右
                  //   break;
                  case 27: // esc
                    Navigator.of(context).pop();
                    break;
                  // case 27: // -
                  //   break;
                  // case 24: // +
                  //   break;
                  // case 36: //enter
                  //   break;
                }
              }
            },
          );
        },
      ),
    );
  }
}

class NovelProfile {
  final novelLeftPadding = 20;
  final novelFontSize = 14.0;
  final novelHeight = 1.5;
  final novelTopPadding = 100.0;
  final novelParagraphPadding = 20.0;
  final novelIndentation = 2;
}

List<TextSpan> buildSpansFlatter(List<String> content, String chapter) {
  return buildSpans(content, chapter).expand((s) => s).toList();
}

/// 文字排版部分
List<List<TextSpan>> buildSpans(List<String> content, String chapter) {
  final __profile = NovelProfile();
  MediaQueryData mediaQueryData = MediaQueryData.fromWindow(ui.window);
  final width = mediaQueryData.size.width - __profile.novelLeftPadding * 2;
  final offset = Offset(width, 6);
  final tp = TextPainter(textDirection: TextDirection.ltr);
  final oneLineHeight = __profile.novelFontSize * __profile.novelHeight;
  final height = mediaQueryData.size.height -
      __profile.novelTopPadding * 2 -
      32 -
      mediaQueryData.padding.top -
      oneLineHeight;
  //final fontColor = Color(__profile.novelFontColor);
  final spanss = <List<TextSpan>>[];

  final newLine = TextSpan(text: "\n");
  final commonStyle = TextStyle(
    fontSize: __profile.novelFontSize,
    height: __profile.novelHeight,
    //color: fontColor,
  );

  var currentSpans = <TextSpan>[
    TextSpan(
      text: chapter,
      style: TextStyle(
        fontSize: __profile.novelFontSize + 2,
        //color: fontColor,
        height: __profile.novelHeight,
        fontWeight: FontWeight.bold,
      ),
    ),
    newLine,
    TextSpan(
        text: " ",
        style: TextStyle(
          height: 1,
          //color: fontColor,
          fontSize: __profile.novelParagraphPadding,
        )),
    newLine,
  ];
  tp.text = TextSpan(children: currentSpans);
  tp.layout(maxWidth: width);
  var currentHeight = tp.height;
  tp.maxLines = 1;
  bool firstLine = true;
  final indentation = Global.fullSpace * __profile.novelIndentation;
  for (var paragraph in content) {
    if (paragraph.startsWith("@img")) {
      print("------img--------");
      if (currentSpans.isNotEmpty) {
        spanss.add(currentSpans);
        currentHeight = 0;
        currentSpans = <TextSpan>[];
      }
      final img = paragraph.substring(4);
      spanss.add([
        TextSpan(
          children: [
            WidgetSpan(
                child: Container(
              width: width,
              child: UIImageItem(cover: img, hero: img),
            )),
            newLine,
          ],
        )
      ]);
      continue;
    } else if (paragraph.startsWith("<img")) {
      print("------img--------");
      if (currentSpans.isNotEmpty) {
        spanss.add(currentSpans);
        currentHeight = 0;
        currentSpans = <TextSpan>[];
      }
      final img = RegExp(r"""(src|data\-original)[^'"]*('|")([^'"]*)""")
          .firstMatch(paragraph)
          .group(3);
      spanss.add([
        TextSpan(
          children: [
            WidgetSpan(
                child: Container(
              width: width,
              child: UIImageItem(cover: img, hero: img),
            )),
            newLine,
          ],
        )
      ]);
      continue;
    }
    while (true) {
      if (currentHeight >= height) {
        spanss.add(currentSpans);
        currentHeight = 0;
        currentSpans = <TextSpan>[];
      }
      var firstPos = 1;
      if (firstLine) {
        firstPos = 3;
        firstLine = false;
        paragraph = indentation + paragraph;
      }
      tp.text = TextSpan(text: paragraph, style: commonStyle);
      tp.layout(maxWidth: width);
      final pos = tp.getPositionForOffset(offset).offset;
      final text = paragraph.substring(0, pos);
      paragraph = paragraph.substring(pos);
      if (paragraph.isEmpty) {
        // 最后一行调整宽度保证单行显示
        if (width - tp.width - __profile.novelFontSize < 0) {
          currentSpans.add(TextSpan(
            text: text.substring(0, firstPos),
            style: commonStyle,
          ));
          currentSpans.add(TextSpan(
              text: text.substring(firstPos, text.length - 1),
              style: TextStyle(
                fontSize: __profile.novelFontSize,
                //color: fontColor,
                height: __profile.novelHeight,
                letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
              )));
          currentSpans.add(TextSpan(
            text: text.substring(text.length - 1),
            style: commonStyle,
          ));
        } else {
          currentSpans.add(TextSpan(
              text: text,
              style: TextStyle(
                fontSize: __profile.novelFontSize,
                height: __profile.novelHeight,
                //color: fontColor,
              )));
        }
        currentSpans.add(newLine);
        currentSpans.add(TextSpan(
            text: " ",
            style: TextStyle(
              height: 1,
              //color: fontColor,
              fontSize: __profile.novelParagraphPadding,
            )));
        currentSpans.add(newLine);
        currentHeight += oneLineHeight;
        currentHeight += __profile.novelParagraphPadding;
        firstLine = true;
        break;
      }
      tp.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: __profile.novelFontSize,
          //color: fontColor,
          height: __profile.novelHeight,
        ),
      );
      tp.layout();
      currentSpans.add(TextSpan(
        text: text.substring(0, firstPos),
        style: commonStyle,
      ));
      currentSpans.add(TextSpan(
          text: text.substring(firstPos, text.length - 1),
          style: TextStyle(
            fontSize: __profile.novelFontSize,
            //color: fontColor,
            height: __profile.novelHeight,
            letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
          )));
      currentSpans.add(TextSpan(
        text: text.substring(text.length - 1),
        style: commonStyle,
      ));
      currentHeight += oneLineHeight;
    }
  }
  if (currentSpans.isNotEmpty) {
    spanss.add(currentSpans);
  }
  return spanss;
}
