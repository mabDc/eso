import 'package:eso/model/manga_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_chapter_separate.dart';
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
          builder: (BuildContext context, MangaPageProvider provider,
              Profile profile, _) {
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
                  provider.showMenu
                      ? UIMangaMenu(
                          searchItem: widget.searchItem,
                          loadChapter: provider.loadChapter,
                        )
                      : Container(),
                  // provider.showChapter
                  //     ? UIChapterSelect(
                  //         searchItem: widget.searchItem,
                  //         loadChapter: provider.loadChapter,
                  //       )
                  //     : Container(),
                  profile.showMangaInfo && !provider.showMenu
                      ? UISystemInfo(
                          mangaInfo: provider.searchItem.durChapter,
                          mangaCount: provider.content.length,
                        )
                      : Container(),
                ],
              ),
              onLongPress: () => profile.showMangaInfo = !profile.showMangaInfo,
              onTapUp: (TapUpDetails details) {
                final size = MediaQuery.of(context).size;
                if (details.globalPosition.dx > size.width * 3 / 8 &&
                    details.globalPosition.dx < size.width * 5 / 8 &&
                    details.globalPosition.dy > size.height * 3 / 8 &&
                    details.globalPosition.dy < size.height * 5 / 8 &&
                    !provider.showMenu) {
                  // provider.showChapter = true;
                  provider.showMenu = true;
                } else {
                  // provider.showChapter = false;
                  provider.showMenu = false;
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMangaContent(MangaPageProvider provider) {
    return ListView.builder(
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
          image: NetworkImage(
            path,
            headers: provider.headers,
          ),
          fit: BoxFit.fitWidth,
        );
      },
    );
  }
}
