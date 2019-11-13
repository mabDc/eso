import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_chapter_separate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      page = buildPage();
    }
    return page;
  }

  @override
  void dispose() {
    __provider?.dispose();
    super.dispose();
  }

  Widget buildPage() {
    return ChangeNotifierProvider<NovelPageProvider>.value(
      value: NovelPageProvider(searchItem: widget.searchItem),
      child: Scaffold(
        body: Consumer<NovelPageProvider>(
          builder: (BuildContext context, NovelPageProvider provider, _) {
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
                    child: _buildContent(provider),
                  ),
                  provider.showChapter
                      ? UIChapterSelect(
                          searchItem: widget.searchItem,
                          loadChapter: provider.loadChapter,
                        )
                      : Container(),
                ],
              ),
              onLongPress: () => provider.useSelectableText = true,
              onTapUp: (TapUpDetails details) {
                final size = MediaQuery.of(context).size;
                if (details.globalPosition.dx > size.width * 3 / 8 &&
                    details.globalPosition.dx < size.width * 5 / 8 &&
                    details.globalPosition.dy > size.height * 3 / 8 &&
                    details.globalPosition.dy < size.height * 5 / 8) {
                  provider.showChapter = true;
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

  Widget _buildContent(NovelPageProvider provider) {
    final content = '　　' + provider.content.map((s) => s.trim()).join('\n　　');
    final contentStyle = TextStyle(
      fontSize: 20,
      height: 2,
      color: Colors.black,
    );
    return Container(
      color: Color(0xFFF5DEB3),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: provider.controller,
              padding: EdgeInsets.only(top: 100),
              child: Column(
                children: <Widget>[
                  SelectableText(
                    '${widget.searchItem.durChapter}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  provider.useSelectableText
                      ? SelectableText(content, style: contentStyle)
                      : Text(content, style: contentStyle),
                  UIChapterSeparate(
                    color: Colors.black87,
                    chapterName: widget.searchItem.durChapter,
                    isLastChapter: widget.searchItem.durChapterIndex ==
                        (widget.searchItem.chaptersCount - 1),
                    isLoading: provider.isLoading,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          provider.useSelectableText
              ? Container()
              : UIDash(
                  height: 2,
                  dashWidth: 6,
                  color: Colors.black38,
                ),
          provider.useSelectableText
              ? InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.white70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '已进入复制模式，点击退出',
                          style: TextStyle(color: Colors.black87),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => provider.useSelectableText = false,
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${widget.searchItem.durChapter}',
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
                        '${provider.progress}%',
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
