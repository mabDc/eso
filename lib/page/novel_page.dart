import 'dart:ui';

import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_novel_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../database/search_item.dart';
import '../ui/ui_dash.dart';
import 'langding_page.dart';

class NovelPage extends StatelessWidget {
  final SearchItem searchItem;
  const NovelPage({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RefreshController refreshController = RefreshController();
    final profile = Provider.of<Profile>(context, listen: false);
    final height = MediaQuery.of(context).size.height - 32 - 2 * profile.novelEdgePadding;
    return ChangeNotifierProvider<NovelPageProvider>(
      create: (BuildContext context) => NovelPageProvider(
        searchItem: searchItem,
        keepOn: profile.novelKeepOn,
        profile: profile,
        height: height,
      ),
      builder: (context, child) => Scaffold(
        body: Consumer2<NovelPageProvider, Profile>(
          builder:
              (BuildContext context, NovelPageProvider provider, Profile profile, _) {
            if (provider.paragraphs == null) {
              return LandingPage();
            }
            Widget content = Center(child: Text("暂不支持"));
            switch (profile.novelPageSwitch) {
              case Profile.NovelScroll:
                content = NotificationListener(
                  onNotification: (t) {
                    if (t is ScrollEndNotification) {
                      provider.refreshProgress();
                    }
                    return false;
                  },
                  child: _buildContent(context, provider, profile, refreshController),
                );
                break;
              case Profile.NovelNone:
                content = _buildContentNone(context, provider, profile);
                break;
              default:
            }
            return GestureDetector(
              child: Stack(
                children: <Widget>[
                  content,
                  provider.showMenu ? UINovelMenu(searchItem: searchItem) : Container(),
                  provider.showChapter
                      ? UIChapterSelect(
                          searchItem: searchItem,
                          loadChapter: provider.loadChapter,
                        )
                      : Container(),
                  provider.isLoading
                      ? Opacity(
                          opacity: 0.8,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).canvasColor,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoActivityIndicator(),
                                  SizedBox(height: 20),
                                  Text(
                                    "加载中...",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              onTapUp: (TapUpDetails details) {
                final size = MediaQuery.of(context).size;
                if (details.globalPosition.dx > size.width * 3 / 8 &&
                    details.globalPosition.dx < size.width * 5 / 8 &&
                    details.globalPosition.dy > size.height * 3 / 8 &&
                    details.globalPosition.dy < size.height * 5 / 8 &&
                    !provider.useSelectableText) {
                  provider.showMenu = !provider.showMenu;
                  provider.showSetting = false;
                } else {
                  provider.showChapter = false;
                  if (details.globalPosition.dx > size.width * 3 / 4 &&
                      details.globalPosition.dy > size.height / 2) {
                    provider.tapNextPage();
                  } else if (details.globalPosition.dx < size.width * 1 / 4 &&
                      details.globalPosition.dy < size.height / 2) {
                    provider.tapLastPage();
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }

  List<List<TextSpan>> _buildSpans(
      BuildContext context, NovelPageProvider provider, Profile profile) {
    final width = MediaQuery.of(context).size.width - profile.novelEdgePadding * 2 - 10;
    final offset = Offset(width, 6);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final oneLineHeight = profile.novelFontSize * profile.novelHeight;
    final height = MediaQuery.of(context).size.height -
        profile.novelEdgePadding * 2 -
        32 -
        MediaQuery.of(context).padding.top -
        oneLineHeight;
    final fontColor = Color(profile.novelFontColor);
    final spanss = <List<TextSpan>>[];
    var currentSpans = <TextSpan>[
      TextSpan(
        text: searchItem.durChapter,
        style: TextStyle(
          fontSize: profile.novelFontSize + 2,
          color: fontColor,
          height: profile.novelHeight,
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(text: "\n"),
      TextSpan(
          text: " \n",
          style: TextStyle(
            height: profile.novelParagraphPadding / 10,
            color: fontColor,
            fontSize: 10,
          )),
    ];
    var currentHeight =
        (profile.novelFontSize + 2) * profile.novelHeight + profile.novelParagraphPadding;
    bool firstLine = true;
    for (var paragraph in provider.paragraphs) {
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
        }
        tp.text = TextSpan(
          text: paragraph,
          style: TextStyle(
            fontSize: profile.novelFontSize,
            height: profile.novelHeight,
            color: fontColor,
          ),
        );
        tp.layout(maxWidth: width);
        final pos = tp.getPositionForOffset(offset).offset;
        final text = paragraph.substring(0, pos);
        paragraph = paragraph.substring(pos);
        if (paragraph.isEmpty) {
          // 最后一行调整宽度保证单行显示
          if (width - tp.width - profile.novelFontSize < 0) {
            currentSpans.add(TextSpan(
                text: text.substring(0, firstPos),
                style: TextStyle(
                  fontSize: profile.novelFontSize,
                  color: fontColor,
                  height: profile.novelHeight,
                )));
            currentSpans.add(TextSpan(
                text: text.substring(firstPos, text.length - 1),
                style: TextStyle(
                  fontSize: profile.novelFontSize,
                  color: fontColor,
                  height: profile.novelHeight,
                  letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
                )));
            currentSpans.add(TextSpan(
                text: text.substring(text.length - 1),
                style: TextStyle(
                  fontSize: profile.novelFontSize,
                  color: fontColor,
                  height: profile.novelHeight,
                )));
          } else {
            currentSpans.add(TextSpan(
                text: text,
                style: TextStyle(
                  fontSize: profile.novelFontSize,
                  height: profile.novelHeight,
                  color: fontColor,
                )));
          }
          currentSpans.add(TextSpan(text: "\n"));
          //段间距
          currentSpans.add(TextSpan(
              text: " \n",
              style: TextStyle(
                height: profile.novelParagraphPadding / 10,
                color: fontColor,
                fontSize: 10,
              )));
          currentHeight += oneLineHeight;
          currentHeight += profile.novelParagraphPadding;
          firstLine = true;
          break;
        }
        tp.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: profile.novelFontSize,
            color: fontColor,
            height: profile.novelHeight,
          ),
        );
        tp.layout();
        currentSpans.add(TextSpan(
            text: text.substring(0, firstPos),
            style: TextStyle(
              fontSize: profile.novelFontSize,
              color: fontColor,
              height: profile.novelHeight,
            )));
        currentSpans.add(TextSpan(
            text: text.substring(firstPos, text.length - 1),
            style: TextStyle(
              fontSize: profile.novelFontSize,
              color: fontColor,
              height: profile.novelHeight,
              letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
            )));
        currentSpans.add(TextSpan(
            text: text.substring(text.length - 1),
            style: TextStyle(
              color: fontColor,
              fontSize: profile.novelFontSize,
              height: profile.novelHeight,
            )));
        currentSpans.add(TextSpan(text: "\n"));
        currentHeight += oneLineHeight;
      }
    }
    spanss.add(currentSpans);
    return spanss;
  }

  Widget _buildContentNone(
      BuildContext context, NovelPageProvider provider, Profile profile) {
    final spanss = provider.didUpdateReadSetting(profile)
        ? provider.updateSpans(_buildSpans(context, provider, profile))
        : provider.spans;
    final spans = spanss[provider.currentPage - 1];
    final fontColor = Color(profile.novelFontColor);
    return Container(
      color: Color(profile.novelBackgroundColor),
      padding: EdgeInsets.only(
        // left: profile.novelEdgePadding,
        top: MediaQuery.of(context).padding.top, //profile.novelEdgePadding,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: profile.novelEdgePadding + 5,
                top: profile.novelEdgePadding,
              ),
              width: double.infinity,
              child: RichText(text: TextSpan(children: spans)),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          UIDash(
            height: 2,
            dashWidth: 6,
            color: fontColor,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 26,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${searchItem.durChapter}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fontColor),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${provider.currentPage}/${spanss.length}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: fontColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NovelPageProvider provider, Profile profile,
      RefreshController refreshController) {
    final spans = provider.didUpdateReadSetting(profile)
        ? provider.updateSpansFlat(_buildSpans(context, provider, profile))
        : provider.spansFlat;
    final fontColor = Color(profile.novelFontColor);
    return Container(
      color: Color(profile.novelBackgroundColor),
      child: Column(
        children: <Widget>[
          Expanded(
            child: RefreshConfiguration(
              enableBallisticLoad: false,
              child: SmartRefresher(
                  header: CustomHeader(
                    builder: (BuildContext context, RefreshStatus mode) {
                      Widget body;
                      if (mode == RefreshStatus.idle) {
                        body = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_downward, color: fontColor),
                            Text(
                              "下拉加载上一章",
                              style: TextStyle(color: fontColor),
                            ),
                          ],
                        );
                      } else if (mode == RefreshStatus.refreshing) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == RefreshStatus.failed) {
                        body = Text(
                          "加载失败!请重试!",
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: fontColor),
                        );
                      } else if (mode == RefreshStatus.canRefresh) {
                        body = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward, color: fontColor),
                            Text(
                              "松手加载上一章!",
                              style: TextStyle(color: fontColor),
                            )
                          ],
                        );
                      } else {
                        body = Text(
                          "加载完成或没有更多数据",
                          style: TextStyle(color: fontColor),
                        );
                      }
                      return Container(
                        height: 60.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward, color: fontColor),
                            Text(
                              "上拉加载下一章",
                              style: TextStyle(color: fontColor),
                            ),
                          ],
                        );
                      } else if (mode == LoadStatus.loading) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = Text(
                          "加载失败!请重试!",
                          style: TextStyle(color: fontColor),
                        );
                      } else if (mode == LoadStatus.canLoading) {
                        body = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_downward, color: fontColor),
                            Text(
                              "松手加载下一章!",
                              style: TextStyle(color: fontColor),
                            )
                          ],
                        );
                      } else {
                        body = Text(
                          "加载完成或没有更多数据",
                          style: TextStyle(color: fontColor),
                        );
                      }
                      return Container(
                        height: 60.0,
                        alignment: Alignment.center,
                        child: body,
                      );
                    },
                  ),
                  controller: refreshController,
                  enablePullUp: true,
                  child: ListView(
                    controller: provider.controller,
                    padding: EdgeInsets.only(
                      left: profile.novelEdgePadding + 5,
                      top: profile.novelEdgePadding,
                    ), //右侧padding设置为0，用spacing控制
                    children: <Widget>[
                      provider.useSelectableText
                          ? SelectableText(
                              provider.paragraphs.join("\n"),
                              style: TextStyle(
                                fontSize: profile.novelFontSize,
                                height: profile.novelHeight * 0.98,
                                color: fontColor,
                              ),
                              textAlign: TextAlign.justify,
                            )
                          : RichText(
                              text: TextSpan(
                                children: spans,
                              ),
                            ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                          top: 50,
                          left: 32,
                          right: 10,
                          bottom: 30,
                        ),
                        child: Text(
                          "当前章节已结束\n${provider.searchItem.durChapter}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 2,
                            color: fontColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onRefresh: () async {
                    await provider.loadChapterHideLoading(true);
                    refreshController.refreshCompleted();
                  },
                  onLoading: () async {
                    await provider.loadChapterHideLoading(false);
                    refreshController.loadComplete();
                  }),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          UIDash(
            height: 2,
            dashWidth: 6,
            color: fontColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${searchItem.durChapter}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fontColor),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${provider.progress}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: fontColor,
                    ),
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
