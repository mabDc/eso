import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_chapter_separate.dart';
import 'package:eso/ui/ui_novel_menu.dart';
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
                                  CircularProgressIndicator(),
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

  Widget _buildContent(NovelPageProvider provider, Profile profile) {
    final content = '　　' + provider.content.map((s) => s.trim()).join('\n　　');
    return Container(
      color: Color(profile.novelBackgroundColor),
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
                      color: Color(profile.novelFontColor),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  provider.useSelectableText
                      ? SelectableText(content,
                          style: TextStyle(
                            fontSize: profile.novelFontSize,
                            height: profile.novelHeight * 0.98,
                            color: Color(profile.novelFontColor),
                          ))
                      : Text(content,
                          style: TextStyle(
                            fontSize: profile.novelFontSize,
                            height: profile.novelHeight,
                            color: Color(profile.novelFontColor),
                          )),
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
          UIDash(
            height: 2,
            dashWidth: 6,
            color: Color(profile.novelFontColor),
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
                    style: TextStyle(
                      color: Color(profile.novelFontColor),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${provider.progress}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(profile.novelFontColor),
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
