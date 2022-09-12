import 'dart:convert';
import 'dart:io';

import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_chapter_loding.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_fade_in_image.dart';
import 'package:eso/ui/ui_manga_menu.dart';
import 'package:eso/ui/ui_system_info.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import 'content_page_manager.dart';
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
  Widget pageMangaContent;
  MangaPageProvider __provider;

  @override
  Widget build(BuildContext context) {
    if (page == null) {
      final provider = ESOTheme();
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
    final contentProvider = Provider.of<ContentProvider>(context);
    return ChangeNotifierProvider<MangaPageProvider>.value(
      value: MangaPageProvider(
        searchItem: widget.searchItem,
        keepOn: keepOn,
        landscape: landscape,
        direction: direction,
        contentProvider: contentProvider,
      ),
      child: Scaffold(
        body: Consumer<MangaPageProvider>(
          builder: (BuildContext context, MangaPageProvider provider, _) {
            final profile = ESOTheme();
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

  Widget _buildMangaContent(MangaPageProvider provider, ESOTheme profile) {
    if (pageMangaContent != null && !provider.shouldUpdateManga) return pageMangaContent;
    Axis direction;
    bool reverse;
    switch (profile.mangaDirection) {
      case ESOTheme.mangaDirectionTopToBottom:
        direction = Axis.vertical;
        reverse = false;
        break;
      case ESOTheme.mangaDirectionLeftToRight:
        direction = Axis.horizontal;
        reverse = false;
        break;
      case ESOTheme.mangaDirectionRightToLeft:
        direction = Axis.horizontal;
        reverse = true;
        break;
      default:
        direction = Axis.vertical;
        reverse = false;
    }
    provider.shouldUpdateManga = false;
    pageMangaContent = ListView.builder(
      key: Key("pageMangaContent" + provider.searchItem.durChapterIndex.toString()),
      padding: EdgeInsets.all(0),
      physics: BouncingScrollPhysics(),
      scrollDirection: direction,
      reverse: reverse,
      // initialScrollIndex: provider.searchItem.durContentIndex,
      // itemPositionsListener: provider.mangaPositionsListener,
      // itemScrollController: provider.mangaScroller,
      itemCount: provider.content.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return TextButton(
            onPressed: () => provider.loadNextChapter(false),
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
                  fontFamily: ESOTheme.staticFontFamily,
                  height: 2,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
            ),
          );
        }
        if (index == provider.content.length + 1) {
          return TextButton(
            onPressed: () => provider.loadNextChapter(true),
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
                  fontFamily: ESOTheme.staticFontFamily,
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
                  items: provider.content,
                  index: index,
                ));
          },
          child: UIFadeInImage(
            item: provider.content[index - 1],
            placeHolderHeight: 200,
          ),
        );
      },
    );
    return pageMangaContent;
  }

  bool lastShowMenu;

  updateSystemChrome(bool showMenu, ESOTheme profile) {
    if (showMenu == lastShowMenu) return;
    lastShowMenu = showMenu;
    if (showMenu) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else if (!profile.showMangaStatus) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }
}

class MangaPageProvider with ChangeNotifier {
  final SearchItem searchItem;
  List<PhotoItem> _content;
  List<PhotoItem> get content => _content;
  bool _isLoading;
  bool get isLoading => _isLoading;
  Map<String, String> _headers;
  Map<String, String> get headers => _headers;
  bool _showChapter;
  bool get showChapter => _showChapter;
  final ContentProvider contentProvider;
  bool shouldUpdateManga;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  bool _showMenu;
  bool get showMenu => _showMenu;
  set showMenu(bool value) {
    if (_showMenu != value) {
      _showMenu = value;
      notifyListeners();
    }
  }

  bool _showSetting;
  bool get showSetting => _showSetting;
  set showSetting(bool value) {
    if (_showSetting != value) {
      _showSetting = value;
      notifyListeners();
    }
  }

  double _brightness;
  double get brightness => _brightness;
  set brightness(double value) {
    if ((value - _brightness).abs() > 0.005) {
      _brightness = value;
      DeviceDisplayBrightness.setBrightness(brightness);
    }
  }

  bool keepOn;
  void setKeepOn(bool value) {
    if (value != keepOn) {
      keepOn = value;
      // ScreenBrightness().keepOn(keepOn);
    }
  }

  bool landscape;
  void setLandscape(bool value) {
    if (value != landscape) {
      landscape = value;
      if (landscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    }
  }

  int direction;
  void setDirection(int value) {
    if (value != direction) {
      direction = value;
      notifyListeners();
    }
  }

  MangaPageProvider({
    this.searchItem,
    this.keepOn = false,
    this.landscape = false,
    this.direction = ESOTheme.mangaDirectionTopToBottom,
    this.contentProvider,
  }) {
    _brightness = 0.5;
    _isLoading = false;
    _showChapter = false;
    _showMenu = false;
    _showSetting = false;
    _headers = Map<String, String>();
    shouldUpdateManga = true;
    // if (searchItem.chapters?.length == 0 &&
    //     SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
    //   searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    // }
    _initContent();
    loadChapter();
  }

  void _initContent() async {
    if (Platform.isAndroid || Platform.isIOS) {
      _brightness = await DeviceDisplayBrightness.getBrightness();
      if (_brightness > 1) {
        _brightness = 0.5;
      }
      DeviceDisplayBrightness.keepOn(enabled: keepOn);
    }
    if (landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void share() {
    Share.share(
        '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description.trim()}\n\n${searchItem.chapterUrl}');
  }

  Future<void> loadChapter([
    int chapterIndex,
    bool useCache = true,
    bool loadNext = true,
    bool shouldChangeIndex = true,
  ]) async {
    if (chapterIndex == null) {
      chapterIndex = searchItem.durChapterIndex;
    }

    if (isLoading || chapterIndex < 0 || chapterIndex >= searchItem.chapters.length)
      return;

    _isLoading = true;
    notifyListeners();
    final c = await contentProvider.loadChapter(
        chapterIndex, useCache, loadNext, shouldChangeIndex);
    Map<String, String> headers = null;
    _content = List.generate(c.length, (i) {
      final index = c[i].indexOf("@headers");
      if (index == -1) return PhotoItem(c[i], headers);
      headers = (jsonDecode(c[i].substring(index + 8)) as Map)
          .map((k, v) => MapEntry('$k', '$v'));
      return PhotoItem(c[i].substring(0, index), headers);
    });
    headers = null;
    _isLoading = false;
    shouldUpdateManga = true;
    notifyListeners();
  }

  bool get isFavorite =>
      SearchItemManager.isFavorite(searchItem.originTag, searchItem.url);

  Future<bool> addToFavorite() async {
    if (isFavorite) return null;
    return await SearchItemManager.addSearchItem(searchItem);
  }

  Future<bool> removeFormFavorite() async {
    if (!isFavorite) return true;
    return await SearchItemManager.removeSearchItem(searchItem.id);
  }

  void loadNextChapter(bool next) {
    final index = searchItem.durChapterIndex;
    if (next && index < (searchItem.chaptersCount - 1))
      loadChapter(index + 1);
    else if (index > 0) loadChapter(index - 1);
  }

  void refreshCurrent() => loadChapter(null, false, false, false);
  void clearCurrent() => loadChapter(null, false, true, false);

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      DeviceDisplayBrightness.resetBrightness();
      DeviceDisplayBrightness.keepOn(enabled: false);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    content.clear();
    super.dispose();
  }
}
