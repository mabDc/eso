import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
//import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:eso/api/analyzer.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/fonticons_icons.dart';
import 'package:eso/model/audio_page_controller.dart';
import 'package:eso/model/manga_page_provider.dart';
import 'package:eso/profile.dart';
import 'package:eso/ui/ui_chapter_loding.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_fade_in_image.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:eso/ui/ui_manga_menu.dart';
import 'package:eso/ui/ui_system_info.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock/wakelock.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import 'content_page_manager.dart';
import 'langding_page.dart';
import 'photo_view_page.dart';

class MangaChapterSelect extends StatefulWidget {
  final BuildContext context;
  final SearchItem searchItem;
  final Function(int index) loadChapter;

  const MangaChapterSelect(
      {this.context, this.searchItem, this.loadChapter, Key key})
      : super(key: key);

  @override
  State<MangaChapterSelect> createState() => _MangaChapterSelectState();
}

class _MangaChapterSelectState extends State<MangaChapterSelect> {
  ScrollController _controllerChapters;

  double _getOffset() {
    double _height = MediaQuery.of(widget.context).size.height;
    double offset = (widget.searchItem.durChapterIndex * 56.0) - 150;
    return offset;
  }

  @override
  void initState() {
    super.initState();
    _controllerChapters = ScrollController(initialScrollOffset: _getOffset());

    setState(() {});
  }

  @override
  void dispose() {
    _controllerChapters.dispose();

    super.dispose();
  }

  bool _isMaxScrollExtent() {
    try {
      final _maxScrollExtent = _controllerChapters.position.maxScrollExtent;
      final _pixels = _controllerChapters.position.pixels;
      print("_isMaxScrollExtent:${(_maxScrollExtent - _pixels).abs() > 2.0}");
      return (_maxScrollExtent - _pixels).abs() > 50.0;
    } catch (e) {}

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(widget.context);

    return Stack(
      children: [
        ListView.custom(
          // cacheExtent: 100.0,
          controller: _controllerChapters,
          childrenDelegate: CustomScrollDelegate(
            (context, index) => index == widget.searchItem.chaptersCount
                ? Container(
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: Text("────共${widget.searchItem.chaptersCount}话────"),
                  )
                : ListTile(
                    onTap: () {
                      widget.loadChapter(index);
                    },
                    title: Text(
                      "${index + 1} - ${widget.searchItem.chapters[index].name}",
                      style: TextStyle(
                        fontSize: 12,
                        color: index == widget.searchItem.durChapterIndex
                            ? Colors.deepOrange
                            : null,
                      ),
                    ),
                  ),
            itemCount: widget.searchItem.chaptersCount + 1,
          ),
        ),
        Positioned(
          right: 40,
          bottom: 150,
          child: Ink(
            height: 25,
            width: 25,
            decoration: ShapeDecoration(
              // color: Color.fromARGB(255, 231, 228, 228),
              color: _theme.dividerColor,
              shape: CircleBorder(),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              onPressed: () async {
                await _controllerChapters.animateTo(_getOffset(),
                    duration: Duration(milliseconds: 500), curve: Curves.ease);

                setState(() {});

                // _controllerChapters.jumpTo(_getOffset());
              },
              icon: Icon(
                Icons.location_pin,
              ),
            ),
          ),
        ),
        Positioned(
          right: 40,
          bottom: 100,
          child: Ink(
            height: 25,
            width: 25,
            decoration: ShapeDecoration(
              // color: Color.fromARGB(255, 231, 228, 228),
              color: _theme.dividerColor,
              shape: CircleBorder(),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              onPressed: () async {
                await _controllerChapters.animateTo(
                    _isMaxScrollExtent()
                        ? _controllerChapters.position.maxScrollExtent + 50
                        : _controllerChapters.position.minScrollExtent,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease);
                // _controllerChapters.jumpTo(_isMaxScrollExtent()
                //     ? _controllerChapters.position.maxScrollExtent + 50
                //     : _controllerChapters.position.minScrollExtent);

                setState(() {});
              },
              icon: Icon(
                _isMaxScrollExtent()
                    ? Icons.arrow_downward
                    : Icons.arrow_upward_outlined,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomScrollDelegate extends SliverChildBuilderDelegate {
  Function(int firstIndex, int lastIndex, double leadingScrollOffset,
      double trailingScrollOffset) scrollCallBack;
  Function(int firstIndex, int lastIndex) layoutFinishCallBack;

  int Function(Key key) findChildIndexCallback;

  CustomScrollDelegate(NullableIndexedWidgetBuilder builder,
      {int itemCount,
      this.scrollCallBack,
      this.findChildIndexCallback,
      this.layoutFinishCallBack})
      : super(builder,
            childCount: itemCount,
            findChildIndexCallback: findChildIndexCallback);
  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    super.didFinishLayout(firstIndex, lastIndex);
    if (layoutFinishCallBack != null) {
      layoutFinishCallBack(firstIndex, lastIndex);
    }
  }

  @override
  double estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    if (scrollCallBack != null) {
      scrollCallBack(
          firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
    }
    return super.estimateMaxScrollOffset(
        firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
  }
}

class MangaSetting extends StatefulWidget {
  final MangaPageProvider provider;

  const MangaSetting({this.provider, Key key}) : super(key: key);

  @override
  State<MangaSetting> createState() => _MangaSettingState();
}

class _MangaSettingState extends State<MangaSetting> {
  Widget _buildBrightness() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "亮度调节",
          style: TextStyle(fontSize: 12),
        ),
        if (widget.provider.landscape)
          SizedBox(
            width: 15,
          ),
        Row(
          children: [
            Icon(
              CupertinoIcons.sun_min,
              color: Colors.blueGrey,
            ),
            SeekBar(
              duration: Duration(milliseconds: 100),
              position: Duration(
                  milliseconds: (widget.provider.brightness * 100).toInt()),
              bufferedPosition: Duration.zero,
              showSeek: false,
              onChanged: (value) {
                widget.provider.brightness =
                    value.inMilliseconds / 100.toDouble();
              },
            ),
            Icon(
              CupertinoIcons.sun_max,
              color: Colors.blueGrey,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMode() {
    return Row(
      mainAxisAlignment: widget.provider.landscape
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "阅读模式",
          style: TextStyle(fontSize: 12),
        ),
        if (widget.provider.landscape)
          SizedBox(
            width: 15,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                widget.provider.setDirection(Profile.mangaDirectionLeftToRight);

                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.direction ==
                                Profile.mangaDirectionLeftToRight
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "       >\n普通模式",
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.provider.direction ==
                            Profile.mangaDirectionLeftToRight
                        ? Colors.deepOrange
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                widget.provider.setDirection(Profile.mangaDirectionRightToLeft);
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.direction ==
                                Profile.mangaDirectionRightToLeft
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "       <\n日漫模式",
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.provider.direction ==
                            Profile.mangaDirectionRightToLeft
                        ? Colors.deepOrange
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                widget.provider.setDirection(Profile.mangaDirectionTopToBottom);
                setState(() {});

                // setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.direction ==
                                Profile.mangaDirectionTopToBottom
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "       ∨\n滚动模式",
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.provider.direction ==
                            Profile.mangaDirectionTopToBottom
                        ? Colors.deepOrange
                        : null,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildscreen() {
    return Row(
      mainAxisAlignment: widget.provider.landscape
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "横竖屏 ",
          style: TextStyle(fontSize: 12),
        ),
        if (widget.provider.landscape)
          SizedBox(
            width: 25,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                widget.provider.setLandscape(false);
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: !widget.provider.landscape
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "竖屏",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                widget.provider.setLandscape(true);
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.landscape
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "横屏",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildQuality() {
    return Row(
      mainAxisAlignment: widget.provider.landscape
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "画质",
          style: TextStyle(fontSize: 12),
        ),
        if (widget.provider.landscape)
          SizedBox(
            width: 40,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                widget.provider.setQuality(FilterQuality.low);
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.quality == FilterQuality.low
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "低",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                widget.provider.setQuality(FilterQuality.medium);
                setState(() {});
                // widget.provider.setLandscape(true);
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.quality == FilterQuality.medium
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "中",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                widget.provider.setQuality(FilterQuality.high);
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                width: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(
                        color: widget.provider.quality == FilterQuality.high
                            ? Colors.deepOrange
                            : Colors.grey,
                        width: 1.5)),
                child: Text(
                  "高",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      // mainAxisAlignment: widget.provider.landscape
      //     ? MainAxisAlignment.start
      //     : MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "显示章节信息",
          style: TextStyle(fontSize: 12),
        ),
        if (widget.provider.landscape)
          SizedBox(
            width: 30,
          ),
        CupertinoSwitch(
          value: widget.provider.showMangaInfo,
          onChanged: (value) {
            widget.provider.setshowMangaInfo(value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    return Row(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMode(),
              SizedBox(
                height: 15,
              ),
              _buildscreen(),
              SizedBox(
                height: 15,
              ),
              _buildQuality(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 1,
          height: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.grey),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrightness(),
              _buildInfo(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: double.infinity,
      padding: widget.provider.landscape
          ? EdgeInsets.only(left: 50, top: 25, bottom: 25, right: 10)
          : EdgeInsets.all(10),

      child: widget.provider.landscape
          ? _buildHorizontal()
          : Column(
              children: [
                _buildBrightness(),
                SizedBox(
                  height: 10,
                ),
                _buildMode(),
                SizedBox(
                  height: 15,
                ),
                _buildscreen(),
                SizedBox(
                  height: 15,
                ),
                _buildQuality(),
                SizedBox(
                  height: 15,
                ),
                _buildInfo(),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
    );
  }
}

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
  Header _buildHeader() {
    return BuilderHeader(
      triggerOffset: 50,
      clamping: false,
      position: IndicatorPosition.above,
      infiniteOffset: null,
      processedDuration: Duration.zero,
      builder: (context, state) {
        // print("state.mode:${state.mode}");
        final _mode = state.mode;
        bool isRun = false;
        bool isFinish = false;
        switch (_mode) {
          case IndicatorMode.ready:
          case IndicatorMode.processing:
          case IndicatorMode.processed:
            isRun = true;
            break;
          case IndicatorMode.done:
            isFinish = true;
            break;
          default:
        }
        if (isFinish || _mode == IndicatorMode.inactive) {
          return SizedBox();
        }

        return Stack(
          children: [
            SizedBox(
              height: state.offset,
              width: double.infinity,
            ),
            Positioned(
              // top: state.offset / 2,
              bottom: state.offset / 2 - 20,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 40,
                child: state.result == IndicatorResult.noMore
                    ? Text("没有数据")
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            radius: 10,
                            // color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              "${isRun ? "正在" : state.offset > 60 ? "松开" : "下拉"}加载下一章",
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
              ),
            )
          ],
        );
      },
    );
  }

  Footer _buildFooter() {
    return BuilderFooter(
      // triggerWhenReach: true,
      triggerOffset: 50,
      clamping: false,
      // safeArea: false,
      position: IndicatorPosition.above,
      infiniteOffset: null,
      processedDuration: Duration.zero,
      builder: (context, state) {
        // print("state.mode:${state.mode}");
        final _mode = state.mode;
        bool isRun = false;
        bool isFinish = false;
        switch (_mode) {
          case IndicatorMode.ready:
          case IndicatorMode.processing:
          case IndicatorMode.processed:
            isRun = true;
            break;
          case IndicatorMode.done:
            isFinish = true;
            break;
          default:
        }
        if (isFinish || _mode == IndicatorMode.inactive) {
          return SizedBox();
        }

        return Stack(
          children: [
            SizedBox(
              height: state.offset,
              width: double.infinity,
            ),
            Positioned(
              top: 1,
              // bottom: 5,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 40,
                child: state.result == IndicatorResult.noMore
                    ? Text("没有数据")
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            radius: 10,
                            // color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              "${isRun ? "正在" : state.offset > 50 ? "松开" : "下拉"}加载下一章",
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget buildTop(BuildContext context, Brightness brightness,
      MangaPageProvider provider, String chapterName) {
    final _textTheme = Theme.of(context).textTheme;
    return AppBar(
      titleSpacing: 0,
      title: Text(
        chapterName,
        style: _textTheme.bodyText1.copyWith(fontSize: 18),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        // iconSize: 25,
        icon: Icon(CupertinoIcons.back),
      ),
      actions: [
        IconButton(
          icon: SearchItemManager.isFavorite(
                  provider.searchItem.originTag, provider.searchItem.url)
              ? Icon(
                  CupertinoIcons.heart_fill,
                  color: Colors.red,
                )
              : Icon(
                  CupertinoIcons.heart,
                  //color: Colors.black,
                ),
          tooltip: "收藏",
          onPressed: Provider.of<MangaPageProvider>(context, listen: false)
              .toggleFavorite,
        ),
        IconButton(
          icon: Icon(FIcons.share_2),
          tooltip: "分享",
          onPressed:
              Provider.of<MangaPageProvider>(context, listen: false).share,
        ),
        // _buildPopupmenu(context, bgColor, color),
      ],
    );
  }

  Widget buildBottom(BuildContext context, MangaPageProvider provider,
      Color bgColor, Color color) {
    final _textTheme = Theme.of(context).textTheme;
    return BottomAppBar(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                provider.showMenu = false;
                provider.showSetting = false;
                provider.easycontroller.callRefresh();
              },
              // onTap: () => provider.loadChapter(
              //     provider.searchItem.durChapterIndex - 1,
              //     true,
              //     true,
              //     true,
              //     false,
              //     true),
              child: IconText(
                "上一章",
                direction: Axis.vertical,
                style: _textTheme.bodyText1.copyWith(fontSize: 12),
                icon: Icon(
                  CupertinoIcons.arrow_left,
                  color: color,
                  size: 25,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // provider.showChapter = true;

                provider.showMenu = !provider.showMenu;
                // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                //     overlays: SystemUiOverlay.values);
                print("object");

                _scaffoldKey.currentState.openEndDrawer();
              },
              child: IconText(
                "目录",
                direction: Axis.vertical,
                style: _textTheme.bodyText1.copyWith(fontSize: 12),
                icon: Icon(
                  CupertinoIcons.list_bullet,
                  color: color,
                  size: 25,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                provider.showSetting = !provider.showSetting;
                showSetting(context, provider);
              },
              child: IconText(
                "设置",
                direction: Axis.vertical,
                style: _textTheme.bodyText1.copyWith(fontSize: 12),
                icon: Icon(
                  CupertinoIcons.gear,
                  color: color,
                  size: 25,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                provider.showMenu = false;
                provider.showSetting = false;
                provider.easycontroller.callLoad();
              },
              // onTap: () => provider.loadChapter(
              //     provider.searchItem.durChapterIndex + 1,
              //     true,
              //     true,
              //     true,
              //     false,
              //     true),
              child: IconText(
                "下一章",
                direction: Axis.vertical,
                style: _textTheme.bodyText1.copyWith(fontSize: 12),
                icon: Icon(
                  CupertinoIcons.arrow_right,
                  color: color,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSetting(BuildContext context, MangaPageProvider provider) {
    // final _brightness =
    //     context.select((MangaPageProvider provider) => provider.brightness);
    final _brightness = provider.brightness * 100;

    print("_brightness:${_brightness}");

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MangaSetting(provider: provider);
      },
    );
  }

  Widget buildAppbar(
    BuildContext context,
    MangaPageProvider provider,
    String chapterName,
  ) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.96);
    final color = Theme.of(context).textTheme.bodyText1.color;
    final refreshFav =
        context.select((MangaPageProvider provider) => provider.refreshFav);
    final showMenu =
        context.select((MangaPageProvider provider) => provider.showMenu);
    print("showMenu:${showMenu}");
    if (showMenu) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            reverseDuration: Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: child,
              );
            },
            child: !showMenu
                ? Container()
                : buildTop(context, brightness, provider, chapterName),
          ),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: !showMenu
              ? Container()
              : buildBottom(
                  context,
                  provider,
                  bgColor,
                  color,
                ),
        ),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget buildDrawer(BuildContext context, MangaPageProvider provider) {
    void Function(int index) onTap = (int index) async {
      provider.loadChapter(
        chapterIndex: index,
        isNext: true,
        restList: true,
        isShowLoading: true,
      );
    };

    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(children: [
          SizedBox(
            height: 15,
          ),
          Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  Text(
                    provider.searchItem.name,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: Colors.grey.withOpacity(0.1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "共${provider.searchItem.chaptersCount}话  ${provider.searchItem.author}",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        // IconText(
                        //   "倒序",
                        //   icon: Icon(Icons.arrow_upward),
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .bodyText1
                        //       .copyWith(fontSize: 12),
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: MangaChapterSelect(
              context: _scaffoldKey.currentContext,
              searchItem: provider.searchItem,
              loadChapter: onTap,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildCustomScrollView(
      BuildContext context,
      MangaPageProvider provider,
      Key centerKey,
      List<MangaList> contentPrevList,
      List<MangaList> contentList) {
    return CustomScrollView(
      center: centerKey,
      controller: provider.controller,
      cacheExtent: 50.0,
      clipBehavior: Clip.none,
      slivers: [
        // HeaderLocator.sliver(),

        SliverList(
          delegate: CustomScrollDelegate(
            (ctx, i) {
              if (contentList[i].photoItem.length <= 0 ||
                  contentList[i].photoItem.first.url == null ||
                  contentList[i].photoItem.first.url.isEmpty) {
                return Text("没有数据");
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contentPrevList[i]
                    .photoItem
                    .map(
                      (m) => UIFadeInImage(
                        filterQuality: provider.quality,
                        item: m,
                        placeHolderHeight: 200,
                      ),
                    )
                    .toList(),
              );
            },
            itemCount: contentPrevList.length,
            scrollCallBack: (firstIndex, lastIndex, leadingScrollOffset,
                trailingScrollOffset) {
              provider.streamController.add(
                ListScrollData(
                  firstIndex: firstIndex,
                  lastIndex: lastIndex,
                  leadingScrollOffset: leadingScrollOffset,
                  trailingScrollOffset: trailingScrollOffset,
                  isBottom: false,
                ),
              );
              // print(
              //     "top:firstIndex:${firstIndex},lastIndex:${lastIndex},leadingScrollOffset:${leadingScrollOffset},trailingScrollOffset:${trailingScrollOffset}");
            },
          ),
        ),
        SliverList(
          key: centerKey,
          delegate: CustomScrollDelegate(
            (ctx, i) {
              // print("photoItem:${contentList[i].photoItem.first.url}");
              if (contentList[i].photoItem.length <= 0 ||
                  contentList[i].photoItem.first.url == null ||
                  contentList[i].photoItem.first.url.isEmpty) {
                return Text("没有数据");
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contentList[i]
                    .photoItem
                    .map(
                      (m) => UIFadeInImage(
                        filterQuality: provider.quality,
                        item: m,
                        placeHolderHeight: 200,
                      ),
                    )
                    .toList(),
              );
            },
            itemCount: contentList.length,
            scrollCallBack: (firstIndex, lastIndex, leadingScrollOffset,
                trailingScrollOffset) {
              provider.streamController.add(
                ListScrollData(
                  firstIndex: firstIndex,
                  lastIndex: lastIndex,
                  leadingScrollOffset: leadingScrollOffset,
                  trailingScrollOffset: trailingScrollOffset,
                  isBottom: true,
                ),
              );

              //   print(
              //       "firstIndex:${firstIndex},lastIndex:${lastIndex},leadingScrollOffset:${leadingScrollOffset},trailingScrollOffset:${trailingScrollOffset}");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPageView(
    BuildContext context,
    MangaPageProvider provider,
    int direction,
    MangaList contentPrevList,
  ) {
    if (contentPrevList == null) {
      return Container();
    }
    bool _reverse = direction == Profile.mangaDirectionRightToLeft;

    return Container(
      color: Colors.black,
      child: PhotoViewGallery.builder(
        key: PageStorageKey<String>(
            'index - ${provider.searchItem.durChapterIndex}'),
        reverse: _reverse,
        // scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          var item = contentPrevList.photoItem[index];
          final startIndex = item.url.indexOf(";base64,");
          return PhotoViewGalleryPageOptions(
            filterQuality: provider.quality,
            imageProvider: startIndex == -1
                ? CachedNetworkImageProvider(
                    item.url,
                    headers: item.headers,
                    decrypt: item.onDecrypt,
                  )
                : MemoryImage(
                    base64Decode(
                      item.url.substring(startIndex + 8),
                    ),
                  ),
          );
        },
        itemCount: contentPrevList.length,
        loadingBuilder: (context, event) {
          return Center(
            child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white30))),
          );
        },
        backgroundDecoration: null,
        onPageChanged: (index) {
          provider.streamController.add(
            ListScrollData(
              firstIndex: 0,
              lastIndex: 0,
              isBottom: true,
              index: index + 1,
              length: contentPrevList.length,
            ),
          );
        },
      ),
    );

    // return PageView.builder(
    //   key: PageStorageKey<String>('index - ${contentPrevList.name}'),
    //   reverse: _reverse,
    //   itemBuilder: (context, index) {
    //     return UIFadeInImage(
    //       item: contentPrevList.photoItem[index],
    //       placeHolderHeight: 200,
    //       fit: BoxFit.contain,
    //     );
    //   },
    //   itemCount: contentPrevList.length,
    //   onPageChanged: (value) {
    //     // provider.currentIndex = value;
    //     provider.streamController.add(
    //       ListScrollData(
    //         firstIndex: 0,
    //         lastIndex: 0,
    //         isBottom: true,
    //         index: value + 1,
    //         length: contentPrevList.length,
    //       ),
    //     );

    //     print("onPageChanged:${value}");
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<Profile>(context, listen: false);
    final contentProvider = Provider.of<ContentProvider>(context);
    return ChangeNotifierProvider<MangaPageProvider>.value(
      value: MangaPageProvider(
        searchItem: widget.searchItem,
        showMangaInfo: profileProvider.showMangaInfo,
        landscape: profileProvider.mangaLandscape,
        direction: profileProvider.mangaDirection,
        contentProvider: contentProvider,
      ),
      builder: (context, child) {
        final centerKey = ValueKey<String>("bottom-sliver-list");
        final provider = Provider.of<MangaPageProvider>(context, listen: false);

        final easyRefreshController = context
            .select((MangaPageProvider provider) => provider.easycontroller);
        // 更新加载列表
        final loadCount =
            context.select((MangaPageProvider provider) => provider.loadCount);
        final firstChapterIndex = context
            .select((MangaPageProvider provider) => provider.firstChapterIndex);

        final contentList = context
            .select((MangaPageProvider provider) => provider.contentList);
        final contentPrevList = context
            .select((MangaPageProvider provider) => provider.contentPrevList);

        final chapterName = context
            .select((MangaPageProvider provider) => provider.chapterName);
        final showLoading = context
            .select((MangaPageProvider provider) => provider.showLoading);
        final direction =
            context.select((MangaPageProvider provider) => provider.direction);

        print(
            "chapterName:${chapterName}, ${provider.searchItem.durChapterIndex}");

        return Scaffold(
          key: _scaffoldKey,

          // backgroundColor: direction != Profile.mangaDirectionTopToBottom
          //     ? Colors.black
          //     : null,

          endDrawer: buildDrawer(context, provider),
          endDrawerEnableOpenDragGesture: false,
          // appBar: buildAppbar(context, chapterName),
          body: Stack(
            children: [
              GestureDetector(
                onVerticalDragStart: (details) {
                  provider.showSetting = false;
                  provider.showMenu = false;
                },
                onHorizontalDragStart: (details) {
                  provider.showSetting = false;
                  provider.showMenu = false;
                },
                onTap: () {
                  provider.showMenu = !provider.showMenu;
                  // print("provider.showMenu:${provider.showMenu}");
                },
                child: EasyRefresh(
                  controller: easyRefreshController,
                  header: direction == Profile.mangaDirectionTopToBottom
                      ? _buildHeader()
                      : CupertinoHeader(position: IndicatorPosition.above),
                  footer: direction == Profile.mangaDirectionTopToBottom
                      ? _buildFooter()
                      : CupertinoFooter(position: IndicatorPosition.above),
                  onLoad: () async {
                    // 上拉触底
                    await Future.delayed(Duration(seconds: 2));
                    // if (direction == Profile.mangaDirectionTopToBottom) {
                    //   provider.loadNextChapter(true);
                    // }
                    provider.loadNextChapter(true);

                    easyRefreshController.finishLoad();
                    easyRefreshController.resetFooter();
                  },
                  onRefresh: () async {
                    // 下拉刷新
                    print("offset:刷新回调");
                    await Future.delayed(Duration(seconds: 2));
                    // if (direction == Profile.mangaDirectionTopToBottom) {

                    // } else {
                    //   provider.loadChapter()
                    // }

                    provider.loadNextChapter(false);

                    easyRefreshController.finishRefresh();
                    easyRefreshController.resetHeader();
                  },
                  child: direction == Profile.mangaDirectionTopToBottom
                      ? _buildCustomScrollView(context, provider, centerKey,
                          contentPrevList, contentList)
                      : _buildPageView(
                          context,
                          provider,
                          direction,
                          provider.contentList.isEmpty
                              ? null
                              : provider.contentList.first),
                ),
              ),
              !provider.showMangaInfo
                  ? Container()
                  : Positioned(
                      bottom: 15,
                      right: 10,
                      child: StreamBuilder<ListScrollData>(
                        initialData: ListScrollData(isBottom: true),
                        stream: provider.streamController.stream,
                        builder: (context, snapshot) {
                          final listScrollData = snapshot.data;
                          int chapterIndex = 0;

                          if (direction == Profile.mangaDirectionTopToBottom) {
                            if (listScrollData.firstIndex != null &&
                                firstChapterIndex != null) {
                              if (listScrollData.isBottom) {
                                if (loadCount == 1 &&
                                    listScrollData.lastIndex == 0) {
                                  chapterIndex = firstChapterIndex;
                                } else {
                                  chapterIndex = (firstChapterIndex ?? 0) +
                                      listScrollData.lastIndex;
                                }
                              } else {
                                chapterIndex = (firstChapterIndex ?? 0) -
                                    listScrollData.lastIndex -
                                    1;
                              }
                            }
                          } else {
                            chapterIndex = firstChapterIndex;
                          }
                          final name = (listScrollData.firstIndex == null &&
                                          firstChapterIndex == null) &&
                                      listScrollData.index == -1 ||
                                  chapterIndex == null
                              ? "null"
                              : provider
                                  .searchItem?.chapters[chapterIndex].name;

                          Future(
                            () {
                              if (mounted &&
                                  listScrollData.firstIndex != null &&
                                  firstChapterIndex != null) {
                                print(
                                    "更新章节信息:chapterIndex:${chapterIndex},name:${name}");
                                provider.updateChapter(name, chapterIndex);
                              }
                            },
                          );
                          return Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "${name} ${listScrollData.index == -1 ? "" : "${listScrollData.index} / ${listScrollData.length}"}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: Profile.staticFontFamily,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              buildAppbar(context, provider, chapterName),
              showLoading
                  ? Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CupertinoActivityIndicator(radius: 25),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );

    // return buildPage(
    //   provider.mangaKeepOn,
    //   provider.mangaLandscape,
    //   provider.mangaDirection,
    // );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    super.dispose();
  }

  // Widget buildPage(bool keepOn, bool landscape, int direction) {
  //   final contentProvider = Provider.of<ContentProvider>(context);
  //   return ChangeNotifierProvider<MangaPageProvider>.value(
  //     value: MangaPageProvider(
  //       searchItem: widget.searchItem,
  //       keepOn: keepOn,
  //       landscape: landscape,
  //       direction: direction,
  //       contentProvider: contentProvider,
  //     ),
  //     child: Scaffold(
  //       //backgroundColor: Colors.black,
  //       body: Consumer2<MangaPageProvider, Profile>(
  //         builder: (BuildContext context, MangaPageProvider provider,
  //             Profile profile, _) {
  //           if (__provider == null) {
  //             __provider = provider;
  //           }
  //           print("provider.currentIndex:${provider.currentIndex}");
  //           if (provider.contentList == null) {
  //             return LandingPage();
  //           }
  //           updateSystemChrome(provider.showMenu, profile);
  //           return Stack(
  //             alignment: AlignmentDirectional.bottomEnd,
  //             children: <Widget>[
  //               EasyRefresh(
  //                 controller: provider.easycontroller,
  //                 header: BuilderHeader(
  //                     triggerOffset: 50,
  //                     clamping: false,
  //                     position: IndicatorPosition.above,
  //                     infiniteOffset: null,
  //                     processedDuration: Duration.zero,
  //                     builder: (context, state) {
  //                       // print("state.mode:${state.mode}");
  //                       final _mode = state.mode;
  //                       bool isRun = false;
  //                       bool isFinish = false;
  //                       switch (_mode) {
  //                         case IndicatorMode.ready:
  //                         case IndicatorMode.processing:
  //                         case IndicatorMode.processed:
  //                           isRun = true;
  //                           break;
  //                         case IndicatorMode.done:
  //                           isFinish = true;
  //                           break;
  //                         default:
  //                       }
  //                       if (isFinish) {
  //                         return SizedBox();
  //                       }
  //                       return Stack(
  //                         children: [
  //                           SizedBox(
  //                             height: state.offset,
  //                             width: double.infinity,
  //                           ),
  //                           Positioned(
  //                             top: 1,
  //                             // bottom: 0,
  //                             left: 0,
  //                             right: 0,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               width: double.infinity,
  //                               height: 40,
  //                               child: state.result == IndicatorResult.noMore
  //                                   ? Text("没有数据")
  //                                   : Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: [
  //                                         CupertinoActivityIndicator(
  //                                           radius: 10,
  //                                           // color: Theme.of(context).colorScheme.primary,
  //                                         ),
  //                                         SizedBox(
  //                                           width: 10,
  //                                         ),
  //                                         Text(
  //                                             "${isRun ? "正在" : state.offset > 50 ? "松开" : "上滑"}加载下一章",
  //                                             style: TextStyle(
  //                                                 fontSize: 15,
  //                                                 fontWeight: FontWeight.w400)),
  //                                       ],
  //                                     ),
  //                             ),
  //                           )
  //                         ],
  //                       );
  //                     }),
  //                 footer: BuilderFooter(
  //                     triggerOffset: 50,
  //                     clamping: false,
  //                     position: IndicatorPosition.above,
  //                     infiniteOffset: null,
  //                     processedDuration: Duration.zero,
  //                     builder: (context, state) {
  //                       // print("state.mode:${state.mode}");
  //                       final _mode = state.mode;
  //                       bool isRun = false;
  //                       bool isFinish = false;
  //                       switch (_mode) {
  //                         case IndicatorMode.ready:
  //                         case IndicatorMode.processing:
  //                         case IndicatorMode.processed:
  //                           isRun = true;
  //                           break;
  //                         case IndicatorMode.done:
  //                           isFinish = true;
  //                           break;
  //                         default:
  //                       }
  //                       if (isFinish) {
  //                         return SizedBox();
  //                       }
  //                       return Stack(
  //                         children: [
  //                           SizedBox(
  //                             height: state.offset,
  //                             width: double.infinity,
  //                           ),
  //                           Positioned(
  //                             bottom: 0,
  //                             left: 0,
  //                             right: 0,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               width: double.infinity,
  //                               height: 40,
  //                               child: state.result == IndicatorResult.noMore
  //                                   ? Text("没有数据")
  //                                   : Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: [
  //                                         CupertinoActivityIndicator(
  //                                           radius: 10,
  //                                           // color: Theme.of(context).colorScheme.primary,
  //                                         ),
  //                                         SizedBox(
  //                                           width: 10,
  //                                         ),
  //                                         Text(
  //                                             "${isRun ? "正在" : state.offset > 50 ? "松开" : "下滑"}加载上一章",
  //                                             style: TextStyle(fontSize: 15)),
  //                                       ],
  //                                     ),
  //                             ),
  //                           )
  //                         ],
  //                       );
  //                     }),
  //                 onLoad: () async {
  //                   // 上滑 ↑ 加载 下一章
  //                   await Future.delayed(Duration(seconds: 2));
  //                   provider.loadNextChapter(true);
  //                   provider.easycontroller.finishLoad();
  //                   provider.easycontroller.resetFooter();
  //                   // provider.isNextLoad = true;
  //                 },
  //                 onRefresh: () async {
  //                   // 下拉 ↓ 加载 上一章
  //                   await Future.delayed(Duration(seconds: 2));
  //                   provider.loadNextChapter(false);
  //                   provider.easycontroller.finishRefresh();
  //                   provider.easycontroller.resetHeader();
  //                 },
  //                 child: _buildMangaContent(provider, profile,
  //                     provider.contentList, provider.contentPrevList),
  //               ),
  //               if (profile.showMangaInfo)
  //                 Padding(
  //                   padding: EdgeInsets.only(
  //                     bottom: 15,
  //                     right: 10,
  //                   ),
  //                   // left: MediaQuery.of(context).size.width - 150),
  //                   child: Container(
  //                     height: 25,
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withOpacity(0.5),
  //                       borderRadius: BorderRadius.all(Radius.circular(5)),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         SizedBox(
  //                           width: 8,
  //                         ),
  //                         Text(
  //                           "${provider.searchItem.durChapter}",
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 12,
  //                             fontFamily: Profile.staticFontFamily,
  //                             textBaseline: TextBaseline.alphabetic,
  //                           ),
  //                         ),
  //                         SizedBox(width: 8),
  //                         StreamBuilder<int>(
  //                           builder: (context, snapshot) {
  //                             return Text(
  //                               "${snapshot.data} / ${provider.contentList.length}",
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 12,
  //                                 fontFamily: Profile.staticFontFamily,
  //                                 textBaseline: TextBaseline.alphabetic,
  //                               ),
  //                             );
  //                           },
  //                           initialData: 0,
  //                           stream: _streamController.stream,
  //                         ),
  //                         SizedBox(width: 8),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               if (provider.showMenu)
  //                 UIMangaMenu(
  //                   searchItem: widget.searchItem,
  //                 ),
  //               if (provider.showChapter)
  //                 UIChapterSelect(
  //                   searchItem: widget.searchItem,
  //                   loadChapter: provider.loadChapter,
  //                 ),
  //               if (provider.isLoading) UIChapterLoding(),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMangaContent(MangaPageProvider provider, Profile profile,
  //     List<MangaList> _contentList, List<MangaList> _contentPrevList) {
  //   // if (pageMangaContent != null && !provider.shouldUpdateManga)
  //   //   return pageMangaContent;
  //   final centerKey = ValueKey<String>("bottom-sliver-list");
  //   Axis direction;
  //   bool reverse;
  //   switch (profile.mangaDirection) {
  //     case Profile.mangaDirectionTopToBottom:
  //       direction = Axis.vertical;
  //       reverse = false;
  //       break;
  //     case Profile.mangaDirectionLeftToRight:
  //       direction = Axis.horizontal;
  //       reverse = false;
  //       break;
  //     case Profile.mangaDirectionRightToLeft:
  //       direction = Axis.horizontal;
  //       reverse = true;
  //       break;
  //     default:
  //       direction = Axis.vertical;
  //       reverse = false;
  //   }
  //   provider.shouldUpdateManga = false;
  //   pageMangaContent = InkWell(
  //     onTap: () {
  //       print("object");
  //       provider.showChapter = false;
  //       provider.showMenu = !provider.showMenu;
  //       provider.showSetting = false;
  //     },
  //     child: CustomScrollView(
  //       key: centerKey,
  //       // key: Key(
  //       //     "pageMangaContent" + provider.searchItem.durChapterIndex.toString()),
  //       // shrinkWrap: true,
  //       // scrollDirection: direction,
  //       // reverse: true,
  //       cacheExtent: 0.0,
  //       clipBehavior: Clip.none,
  //       controller: provider.controller,
  //       slivers: [
  //         SliverList(
  //           delegate: CustomScrollDelegate(
  //             (context, index) {
  //               return Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: _contentPrevList[index]
  //                     .photoItem
  //                     .map(
  //                       ((e) => UIFadeInImage(
  //                             item: e,
  //                             placeHolderHeight: 200,
  //                             // key: _imageKey[i],
  //                           )),
  //                     )
  //                     .toList(),
  //               );
  //             },
  //             scrollCallBack: (firstIndex, lastIndex, leadingScrollOffset,
  //                 trailingScrollOffset) {
  //               _streamController.add(lastIndex);
  //               // print(
  //               //     "firstIndex:${firstIndex},lastIndex:${lastIndex},leadingScrollOffset:${leadingScrollOffset},trailingScrollOffset:${trailingScrollOffset}");
  //             },
  //             itemCount: _contentPrevList.length,
  //           ),
  //         ),
  //         SliverList(
  //           key: centerKey,
  //           delegate: CustomScrollDelegate(
  //             (context, index) {
  //               return Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: _contentList[index]
  //                     .photoItem
  //                     .map(
  //                       ((e) => UIFadeInImage(
  //                             item: e,
  //                             placeHolderHeight: 200,
  //                             // key: _imageKey[i],
  //                           )),
  //                     )
  //                     .toList(),
  //               );
  //             },
  //             scrollCallBack: (firstIndex, lastIndex, leadingScrollOffset,
  //                 trailingScrollOffset) {
  //               _streamController.add(lastIndex);
  //               // print(
  //               //     "firstIndex:${firstIndex},lastIndex:${lastIndex},leadingScrollOffset:${leadingScrollOffset},trailingScrollOffset:${trailingScrollOffset}");
  //             },
  //             itemCount: _contentList.length,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //   return pageMangaContent;
  // }

  bool lastShowMenu;

  updateSystemChrome(bool showMenu, Profile profile) {
    if (showMenu == lastShowMenu) return;
    lastShowMenu = showMenu;
    if (showMenu) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } else if (!profile.showMangaStatus) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }
}
