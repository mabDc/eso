import 'package:eso/model/manga_page_provider.dart';
import 'package:eso/profile.dart';
import 'package:eso/ui/ui_chapter_loding.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_fade_in_image.dart';
import 'package:eso/ui/ui_manga_menu.dart';
import 'package:eso/ui/ui_system_info.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../database/search_item.dart';
import 'langding_page.dart';
import 'photo_view_page.dart';

/// 漫画显示页面
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
      final provider = Provider.of<Profile>(context, listen: false);
      page = buildPage(
        provider.mangaKeepOn,
        provider.mangaLandscape,
        provider.mangaDirection,
      );
    }
    return page;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    __provider?.dispose();
    super.dispose();
  }

  Widget buildPage(bool keepOn, bool landscape, int direction) {
    return ChangeNotifierProvider<MangaPageProvider>.value(
      value: MangaPageProvider(
        searchItem: widget.searchItem,
        keepOn: keepOn,
        landscape: landscape,
        direction: direction,
      ),
      child: Scaffold(
        body: Consumer2<MangaPageProvider, Profile>(
          builder:
              (BuildContext context, MangaPageProvider provider, Profile profile, _) {
            if (__provider == null) {
              __provider = provider;
            }

            if (provider.content == null) {
              return LandingPage();
            }
            updateSystemChrome(provider.showMenu, profile);
            return Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                _buildMangaContent(provider, profile),
                if (profile.showMangaInfo)
                  UISystemInfo(
                    mangaInfo: provider.searchItem.durChapter,
                    mangaCount: provider.content.length,
                    mangeCurrent: provider.searchItem.durContentIndex,
                  ),
                if (provider.showMenu)
                  UIMangaMenu(
                    searchItem: widget.searchItem,
                  ),
                if (provider.showChapter)
                  UIChapterSelect(
                    searchItem: widget.searchItem,
                    loadChapter: provider.loadChapter,
                  ),
                if (provider.isLoading) UIChapterLoding(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMangaContent(MangaPageProvider provider, Profile profile) {
    Axis direction;
    bool reverse;
    switch (profile.mangaDirection) {
      case Profile.mangaDirectionTopToBottom:
        direction = Axis.vertical;
        reverse = false;
        break;
      case Profile.mangaDirectionLeftToRight:
        direction = Axis.horizontal;
        reverse = false;
        break;
      case Profile.mangaDirectionRightToLeft:
        direction = Axis.horizontal;
        reverse = true;
        break;
      default:
        direction = Axis.vertical;
        reverse = false;
    }
    return ScrollablePositionedList.builder(
      padding: EdgeInsets.all(0),
      physics: BouncingScrollPhysics(),
      scrollDirection: direction,
      reverse: reverse,
      initialScrollIndex: provider.searchItem.durContentIndex,
      itemPositionsListener: provider.mangaPositionsListener,
      itemScrollController: provider.mangaScroller,
      itemCount: provider.content.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return TextButton(
            onPressed: () => provider.loadChapterHideLoading(true),
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(
                top: 20,
                left: 32,
                right: 10,
                bottom: 20,
              ),
              child: Text(
                "点击加载上一章\n--- 章节结束 ---\n${provider.searchItem.durChapter}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Profile.staticFontFamily,
                  height: 2,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
            ),
          );
        }
        if (index == provider.content.length + 1) {
          return TextButton(
            onPressed: () => provider.loadChapterHideLoading(false),
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(
                top: 20,
                left: 32,
                right: 10,
                bottom: 20,
              ),
              child: Text(
                "${provider.searchItem.durChapter}\n--- 章节结束 ---\n点击加载下一章",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Profile.staticFontFamily,
                  height: 2,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
            ),
          );
        }
        return GestureDetector(
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
          onLongPress: () {
            Utils.startPageWait(
                context,
                PhotoViewPage(
                  items: provider.content
                      .map((e) => PhotoItem(e, headers: provider.headers))
                      .toList(),
                  index: index,
                ));
          },
          child: UIFadeInImage(
            url: provider.content[index - 1],
            header: provider.headers,
            placeHolderHeight: 200,
          ),
        );
      },
    );
  }

  bool lastShowMenu;

  updateSystemChrome(bool showMenu, Profile profile) {
    if (showMenu == lastShowMenu) return;
    lastShowMenu = showMenu;
    if (showMenu) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else if (!profile.showMangaStatus) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }
}
