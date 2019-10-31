import 'package:eso/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/search_item.dart';
import '../global.dart';
import '../model/content_page_controller.dart';
import '../ui/ui_dash.dart';
import 'langding_page.dart';

class ContentPage extends StatelessWidget {
  final SearchItem searchItem;

  const ContentPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentPageController>.value(
      value: ContentPageController(searchItem: searchItem),
      child: Scaffold(
        body: Consumer<ContentPageController>(builder:
            (BuildContext context, ContentPageController pageController, _) {
          if (pageController.content == null) {
            return LandingPage();
          }
          return GestureDetector(
            child: Stack(
              children: <Widget>[
                NotificationListener(
                  child: (() {
                    switch (searchItem.ruleContentType) {
                      case API.MANGA:
                        return _MangaContentPage(
                            pageController: pageController);
                      case API.NOVEL:
                        return _NovelContentPage(
                            pageController: pageController);
                      default:
                        throw ('${searchItem.ruleContentType} not support');
                    }
                  })(),
                  onNotification: (t) {
                    if (t is ScrollEndNotification) {
                      pageController.refreshProgress();
                    }
                    return false;
                  },
                ),
                pageController.showChapter
                    ? _buildChapterSelect(context, pageController)
                    : Container(),
              ],
            ),
            onTapUp: (TapUpDetails details) {
              final size = MediaQuery.of(context).size;
              if (details.globalPosition.dx > size.width * 3 / 8 &&
                  details.globalPosition.dx < size.width * 5 / 8 &&
                  details.globalPosition.dy > size.height * 3 / 8 &&
                  details.globalPosition.dy < size.height * 5 / 8) {
                pageController.showChapter = true;
              } else {
                pageController.showChapter = false;
              }
            },
          );
        }),
      ),
    );
  }

  Widget _buildChapterSelect(
      BuildContext context, ContentPageController pageController) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () => pageController.loadChapter(index),
                      child: Row(
                        children: <Widget>[
                          // Text(
                          //   '${index + 1}',
                          //   style: TextStyle(
                          //       fontSize: 10, fontStyle: FontStyle.italic),
                          // ),
                          // SizedBox(
                          //   width: 8,
                          // ),
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
                                  color: Theme.of(context).primaryColor,
                                )
                              : Container()
                        ],
                      ),
                    ),
                    UIDash(height: 0.5, dashWidth: 4, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildChapterSeparate(
    Color color, double screenHeight, bool isLoading, SearchItem searchItem) {
  return Container(
    alignment: Alignment.topLeft,
    padding: EdgeInsets.only(
      top: 80,
      left: 32,
      right: 10,
      bottom: screenHeight - 200,
    ),
    child: Text(
      searchItem.durChapterIndex == searchItem.chapters.length - 1
          ? "当前章节\n${searchItem.durChapter}\n\n已经是最后一章"
          : isLoading
              ? "当前章节\n${searchItem.durChapter}\n\n正在加载..."
              : "当前章节\n${searchItem.durChapter}\n\n继续滑动加载下一章",
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 2,
        color: color,
      ),
    ),
  );
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
          cacheExtent: double.infinity,
          padding: EdgeInsets.all(0),
          controller: pageController.controller,
          itemCount: pageController.content.length + 1,
          itemBuilder: (context, index) {
            if (index == pageController.content.length) {
              return _buildChapterSeparate(
                  null,
                  MediaQuery.of(context).size.height,
                  pageController.isLoading,
                  pageController.searchItem);
            }
            return FadeInImage(
              placeholder: AssetImage(Global.waitingPath),
              image: NetworkImage(
                "${pageController.content[index]}",
                headers: pageController.headers,
              ),
              fit: BoxFit.fitWidth,
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
                  return _buildChapterSeparate(
                      Colors.black87,
                      MediaQuery.of(context).size.height,
                      pageController.isLoading,
                      pageController.searchItem);
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
            dashWidth: 6,
            color: Colors.black38,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${pageController.searchItem.durChapter}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${pageController.progress}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
