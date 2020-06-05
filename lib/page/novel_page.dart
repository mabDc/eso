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

class NovelPage extends StatefulWidget {
  final SearchItem searchItem;

  const NovelPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _NovelPageState createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  Widget page;
  NovelPageProvider __provider;

  @override
  Widget build(BuildContext context) {
    if (page == null) {
      page = buildPage(Provider.of<Profile>(context, listen: false).novelKeepOn);
    }
    return page;
  }

  @override
  void dispose() {
    __provider?.dispose();
    super.dispose();
  }

  Widget buildPage(bool keepOn) {
    return ChangeNotifierProvider<NovelPageProvider>.value(
      value: NovelPageProvider(searchItem: widget.searchItem, keepOn: keepOn),
      child: Scaffold(
        body: Consumer2<NovelPageProvider, Profile>(
          builder:
              (BuildContext context, NovelPageProvider provider, Profile profile, _) {
            __provider = provider;
            if (provider.content == null) {
              return LandingPage();
            }
            return GestureDetector(
              child: Stack(
                children: <Widget>[
                  NotificationListener(
                    onNotification: (t) {
                      if (t is ScrollEndNotification) {
                        provider.refreshProgress();
                      }
                      return false;
                    },
                    child: _buildContent(provider, profile),
                  ),
                  provider.showMenu
                      ? UINovelMenu(searchItem: widget.searchItem)
                      : Container(),
                  provider.showChapter
                      ? UIChapterSelect(
                          searchItem: widget.searchItem,
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
                }
              },
            );
          },
        ),
      ),
    );
  }

  RefreshController _refreshController = RefreshController();
  Widget _buildContent(NovelPageProvider provider, Profile profile) {
    final paragraphs = provider.content
        .join("\n")
        .split(RegExp(r"\n\s*"))
        .map((s) => "　　" + s.trimLeft())
        .toList();
    final width = MediaQuery.of(context).size.width - 32;
    final offset = Offset(width, 6);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final lines = <Line>[];
    for (var paragraph in paragraphs) {
      bool firstLine = true;
      while (true) {
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
          ),
        );
        tp.layout(maxWidth: width);
        final pos = tp.getPositionForOffset(offset).offset;
        final text = paragraph.substring(0, pos);
        paragraph = paragraph.substring(pos);
        if (paragraph.isEmpty) {
          // 最后一行调整宽度保证单行显示
          if (width - tp.width - profile.novelFontSize < 0) {
            //字号最大只能70 保证一行至少3个字符
            lines.add(Line(text: text.substring(0, firstPos)));
            lines.add(Line(
              text: text.substring(firstPos, text.length - 1),
              letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
            ));
            lines.add(Line(text: text.substring(text.length - 1)));
          } else {
            lines.add(Line(text: text));
          }
          lines.add(Line(text: "\n"));
          break;
        }
        tp.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: profile.novelFontSize,
            height: profile.novelHeight,
          ),
        );
        tp.layout();
        lines.add(Line(text: text.substring(0, firstPos)));
        lines.add(Line(
          text: text.substring(firstPos, text.length - 1),
          letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
        ));
        lines.add(Line(text: text.substring(text.length - 1)));
        lines.add(Line(text: "\n"));
      }
    }
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
                  controller: _refreshController,
                  enablePullUp: true,
                  child: ListView(
                    controller: provider.controller,
                    padding:
                        EdgeInsets.fromLTRB(16, 100, 0, 0), //右侧padding设置为0，用spacing控制
                    children: <Widget>[
                      SelectableText(
                        '${widget.searchItem.durChapter}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: fontColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      provider.useSelectableText
                          ? SelectableText(
                              paragraphs.join("\n"),
                              style: TextStyle(
                                fontSize: profile.novelFontSize,
                                height: profile.novelHeight * 0.98,
                                color: fontColor,
                              ),
                              textAlign: TextAlign.justify,
                            )
                          : RichText(
                              text: TextSpan(
                                children: lines
                                    .map((line) => TextSpan(
                                          text: line.text,
                                          style: TextStyle(
                                            fontSize: profile.novelFontSize,
                                            height: profile.novelHeight,
                                            color: fontColor,
                                            letterSpacing: line.letterSpacing,
                                          ),
                                        ))
                                    .toList(),
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
                    _refreshController.refreshCompleted();
                  },
                  onLoading: () async {
                    await provider.loadChapterHideLoading(false);
                    _refreshController.loadComplete();
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
                    '${widget.searchItem.durChapter}',
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

class Line {
  final String text;
  final double letterSpacing;
  Line({this.text, this.letterSpacing});
}
