import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../model/content_page_controller.dart';

class ContentPage extends StatelessWidget {
  final List<String> content;
  final List<ChapterItem> chapters;
  final SearchItem searchItem;

  const ContentPage({
    this.content,
    this.chapters,
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      return Scaffold(
        body: Center(
          child: Text('内容加载失败'),
        ),
      );
    }
    return ChangeNotifierProvider<ContentPageController>.value(
      value: ContentPageController(
        content: content,
        chapters: chapters,
        searchItem: searchItem,
      ),
      child: Scaffold(
        body: Consumer<ContentPageController>(builder:
            (BuildContext context, ContentPageController pageController, _) {
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
    return Stack(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.all(0),
          controller: pageController.controller,
          itemCount: pageController.content.length + 1,
          itemBuilder: (context, index) {
            if (index == pageController.content.length) {
              return Container(
                height: 400,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  pageController.searchItem.durChapterIndex ==
                          pageController.chapters.length - 1
                      ? "${pageController.searchItem.durChapter} 结束\n\n已经是最后一章"
                      : pageController.isLoading
                          ? "${pageController.searchItem.durChapter} 结束\n\n正在加载下一章..."
                          : "${pageController.searchItem.durChapter} 结束\n\n继续滑动加载下一章",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }
            return FadeInImage.assetNetwork(
              placeholder: Global.waitingPath,
              image: '${pageController.content[index]}',
            );
          },
        ),
        Positioned(
          right: 10,
          bottom: 0,
          child: Container(
            color: Colors.black.withAlpha(0x80),
            child: Text(
              '${pageController.searchItem.durChapter} ${pageController.searchItem.durContentIndex}/${pageController.content.length}',
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
              padding: EdgeInsets.only(top: 100),
              controller: pageController.controller,
              itemCount: pageController.content.length + 2,
              itemBuilder: (context, index) {
                if (index == pageController.content.length + 1) {
                  return Container(
                    height: 700,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: 50,left: 30),
                    child: Text(
                      pageController.searchItem.durChapterIndex ==
                              pageController.chapters.length - 1
                          ? "当前章节\n${pageController.searchItem.durChapter}\n\n已经是最后一章"
                          : pageController.isLoading
                              ? "当前章节\n${pageController.searchItem.durChapter}\n\n正在加载下一章..."
                              : "当前章节\n${pageController.searchItem.durChapter}\n\n继续滑动加载下一章",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                if (index == 0) {
                  return Text(
                    '${pageController.searchItem.durChapter}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  );
                }
                return Text(
                  pageController.content[index - 1],
                  style: TextStyle(fontSize: 20, height: 2),
                );
              },
            ),
          ),
          Divider(),
          Text(
            '${pageController.searchItem.durChapter} ${pageController.content.length}自然段',
          ),
        ],
      ),
    );
  }
}
