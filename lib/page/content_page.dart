import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/model/content_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/fake_data.dart';
import '../global.dart';

class ContentPage extends StatelessWidget {
  final List<String> urls;
  final List<ChapterItem> chapters;
  final SearchItem searchItem;

  const ContentPage({
    this.urls,
    this.chapters,
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (urls == null) {
      return Scaffold(
        body: ListView.builder(
          padding: EdgeInsets.only(top: 0),
          itemBuilder: (context, index) {
            return FadeInImage.assetNetwork(
              placeholder: Global.waitingPath,
              image: FakeData.picUrl,
            );
          },
        ),
      );
    }
    return ChangeNotifierProvider<ContentPageController>.value(
      value: ContentPageController(
          urls: urls, chapters: chapters, searchItem: searchItem),
      child: Scaffold(
        body: Consumer<ContentPageController>(builder: (BuildContext context,
            ContentPageController contentPageController, _) {
          return Stack(
            children: <Widget>[
              ListView.builder(
                padding: EdgeInsets.all(0),
                controller: contentPageController.controller,
                itemCount: contentPageController.urls.length + 1,
                itemBuilder: (context, index) {
                  if (index == contentPageController.urls.length) {
                    return Container(
                      height: 400,
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        contentPageController.isLoading
                            ? "正在加载下一章..."
                            : "继续滑动加载下一章",
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                  return FadeInImage.assetNetwork(
                    placeholder: Global.waitingPath,
                    image: '${contentPageController.urls[index]}',
                  );
                },
              ),
              Positioned(
                right: 10,
                bottom: 0,
                child: Container(
                  color: Colors.black.withAlpha(0x80),
                  child: Text(
                    '${contentPageController.searchItem.durChapter} ${contentPageController.searchItem.durContentIndex}/${contentPageController.urls.length}',
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
