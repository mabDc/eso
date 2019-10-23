import 'package:eso/model/content_novel_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';

class ContentNovelPage extends StatelessWidget {
  final List<String> p;
  final List<ChapterItem> chapters;
  final SearchItem searchItem;

  const ContentNovelPage({
    this.p,
    this.chapters,
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (p == null) {
      return Scaffold(
        body: Center(
          child: Text('加载失败'),
        ),
      );
    }
    return ChangeNotifierProvider<ContentNovelPageController>.value(
      value: ContentNovelPageController(
        p: p,
        chapters: chapters,
        searchItem: searchItem,
      ),
      child: Scaffold(
        body: Consumer<ContentNovelPageController>(builder:
            (BuildContext context,
                ContentNovelPageController contentNovelPageController, _) {
          return Stack(
            children: <Widget>[
              Material(
                color: Color(0xFFF5DEB3),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical:100,horizontal: 12),
                  controller: contentNovelPageController.controller,
                  itemCount: contentNovelPageController.p.length + 2,
                  itemBuilder: (context, index) {
                    if (index == contentNovelPageController.p.length + 1) {
                      return Container(
                        height: 700,
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(top: 50),
                        child: Text(
                          searchItem.durChapterIndex == chapters.length - 1
                              ? "${searchItem.durChapter} 结束\n\n已经是最后一章"
                              : contentNovelPageController.isLoading
                                  ? "${searchItem.durChapter} 结束\n\n正在加载下一章..."
                                  : "${searchItem.durChapter} 结束\n\n继续滑动加载下一章",
                          style: TextStyle(fontSize: 22),
                        ),
                      );
                    }
                    if (index == 0) {
                      return Text(
                        '${contentNovelPageController.searchItem.durChapter}',
                        style: TextStyle(fontSize: 32),
                        textAlign: TextAlign.center,
                      );
                    }
                    return Text(contentNovelPageController.p[index - 1],
                      style: TextStyle(fontSize: 20,height: 2),);
                  },
                ),
              ),
              Positioned(
                right: 16,
                bottom: 0,
                child: Container(
                  color: Colors.black.withAlpha(0x80),
                  child: Text(
                    '${contentNovelPageController.searchItem.durChapter} ${contentNovelPageController.p.length}自然段',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
