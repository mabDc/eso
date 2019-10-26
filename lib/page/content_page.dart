import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/ui_dash.dart';
import '../global.dart';
import '../database/search_item.dart';
import '../model/content_page_controller.dart';
import 'langding_page.dart';

class ContentPage extends StatelessWidget {
  final List<String> content;
  final SearchItem searchItem;

  const ContentPage({
    this.content,
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentPageController>.value(
      value: ContentPageController(
        content: content,
        searchItem: searchItem,
      ),
      child: Scaffold(
        body: Consumer<ContentPageController>(builder:
            (BuildContext context, ContentPageController pageController, _) {
          if (pageController.content == null) {
            return LandingPage();
          }
          switch (searchItem.ruleContentType) {
            case RuleContentType.MANGA:
              return _MangaContentPage(pageController: pageController);
            case RuleContentType.NOVEL:
              return _NovelContentPage(pageController: pageController);
            default:
              throw ('${searchItem.ruleContentType} not support');
          }
        }),
      ),
    );
  }
}

class _MangaContentPage extends StatelessWidget {
  final ContentPageController pageController;

  const _MangaContentPage({
    this.pageController,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final first = pageController.content[0].split('@headers');
    Map<String, String> headers = Map<String, String>();
    if (first.length > 1) {
      pageController.content[0] = first[0];
      headers = (jsonDecode(first[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
    }
    return Stack(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.all(0),
          controller: pageController.controller,
          itemCount: pageController.content.length + 1,
          itemBuilder: (context, index) {
            if (index == pageController.content.length) {
              return Container(
                height: 800,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 80, left: 32),
                child: Text(
                  pageController.searchItem.durChapterIndex ==
                          pageController.searchItem.chapters.length - 1
                      ? "当前章节\n${pageController.searchItem.durChapter}\n\n已经是最后一章"
                      : pageController.isLoading
                          ? "当前章节\n${pageController.searchItem.durChapter}\n\n正在加载下一章..."
                          : "当前章节\n${pageController.searchItem.durChapter}\n\n继续滑动加载下一章",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, height: 2),
                ),
              );
            }
            return FadeInImage(
              placeholder: AssetImage(Global.waitingPath),
              image: NetworkImage(
                "${pageController.content[index]}",
                headers: headers,
              ),
            );
          },
        ),
        Positioned(
          right: 10,
          bottom: 0,
          child: Container(
            color: Colors.black.withAlpha(0x80),
            child: Text(
              '${pageController.searchItem.durChapter} ${pageController.content.length}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _NovelContentPage extends StatelessWidget {
  final ContentPageController pageController;

  const _NovelContentPage({
    this.pageController,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5DEB3),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 80),
              controller: pageController.controller,
              itemCount: pageController.content.length + 2,
              itemBuilder: (context, index) {
                if (index == pageController.content.length + 1) {
                  return Container(
                    height: 800,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: 80, left: 30),
                    child: Text(
                      pageController.searchItem.durChapterIndex ==
                              pageController.searchItem.chapters.length - 1
                          ? "当前章节\n${pageController.searchItem.durChapter}\n\n\n已经是最后一章"
                          : pageController.isLoading
                              ? "当前章节\n${pageController.searchItem.durChapter}\n\n\n正在加载下一章..."
                              : "当前章节\n${pageController.searchItem.durChapter}\n\n\n继续滑动加载下一章",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),
                  );
                }
                if (index == 0) {
                  return Text(
                    '${pageController.searchItem.durChapter}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                return Text(
                  pageController.content[index - 1],
                  style: TextStyle(
                    fontSize: 20,
                    height: 2,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 4,
          ),
          UIDash(
            height: 2,
            color: Colors.black38,
          ),
          Text(
            '${pageController.searchItem.durChapter} ${pageController.content.length}自然段',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
