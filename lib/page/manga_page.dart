import 'package:eso/model/manga_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_chapter_separate.dart';
import 'package:eso/ui/zoom_view.dart';
import 'package:eso/ui/ui_manga_menu.dart';
import 'package:eso/ui/ui_system_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../database/search_item.dart';
import '../global.dart';
import 'langding_page.dart';

class MangaPage extends StatefulWidget {
  final SearchItem searchItem;

  const MangaPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  Widget page;
  MangaPageProvider __provider;

  @override
  Widget build(BuildContext context) {
    if (page == null) {
      page = buildPage();
    }
    return page;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    __provider?.dispose();
    super.dispose();
  }

  Widget buildPage() {
    return ChangeNotifierProvider<MangaPageProvider>.value(
      value: MangaPageProvider(searchItem: widget.searchItem),
      child: Scaffold(
        body: Consumer2<MangaPageProvider, Profile>(
          builder:
              (BuildContext context, MangaPageProvider provider, Profile profile, _) {
            if (__provider == null) {
              __provider = provider;
            }
            SystemChrome.setEnabledSystemUIOverlays([]);
            if (provider.content == null) {
              return LandingPage();
            }
            if (provider.showMenu) {
              SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            } else {
              SystemChrome.setEnabledSystemUIOverlays([]);
            }
            return GestureDetector(
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: <Widget>[
                  _buildMangaContent(provider),
                  profile.showMangaInfo
                      ? UISystemInfo(
                          mangaInfo: provider.searchItem.durChapter,
                          mangaCount: provider.content.length,
                        )
                      : Container(),
                  provider.showMenu
                      ? UIMangaMenu(
                          searchItem: widget.searchItem,
                        )
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
                    details.globalPosition.dy < size.height * 5 / 8) {
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

  Widget _buildMangaContent(MangaPageProvider provider) {
    return ZoomView(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        controller: provider.controller,
        itemCount: provider.content.length + 1,
        itemBuilder: (context, index) {
          if (index == provider.content.length) {
            return UIChapterSeparate(
              chapterName: provider.searchItem.durChapter,
              isLastChapter: (provider.searchItem.chaptersCount - 1) ==
                  provider.searchItem.durChapterIndex,
              isLoading: provider.isLoading,
            );
          }
          final path = '${provider.content[index]}';
          return FadeInImage(
            placeholder: AssetImage(Global.waitingPath),
            image: checkUrl(path, provider.headers),
            fit: BoxFit.fitWidth,
          );
        },
      ),
    );
  }

  ImageProvider checkUrl(String url, Map<String, String> header) {
    try {
      return NetworkImage(url, headers: header);
    } catch (e) {
      return AssetImage(Global.waitingPath);
    }
  }
}
