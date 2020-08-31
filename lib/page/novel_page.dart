import 'dart:ui';

import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/novel/novel_route_view.dart';
import 'package:eso/page/novel/novel_none_view.dart';
import 'package:eso/page/novel/novel_scroll_view.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_novel_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// import 'package:eso_plugin/eso_plugin.dart';

/// 文字阅读页面
class NovelPage extends StatefulWidget {
  final SearchItem searchItem;
  const NovelPage({this.searchItem, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NovelPageState(this.searchItem);
}

class _NovelPageState extends State<NovelPage> {
  final SearchItem searchItem;
  _NovelPageState(this.searchItem): super();

  // VolumeChangeEvent onVolumeInc, onVolumeDec;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // EsoPlugin.captureVolumeKeyboard(false, onVolumeInc: onVolumeInc,
    //     onVolumeDec: onVolumeDec);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context, listen: false);
    final FocusNode _backNode = new FocusNode();
    final height = MediaQuery.of(context).size.height - 100;
    return ChangeNotifierProvider<NovelPageProvider>(
      create: (BuildContext context) => NovelPageProvider(
        searchItem: searchItem,
        keepOn: profile.novelKeepOn,
        profile: profile,
        height: height,
      ),
      builder: (context, child) => Scaffold(
        backgroundColor: Color(profile.novelBackgroundColor),
        body: Consumer2<NovelPageProvider, Profile>(
          builder: (BuildContext context, NovelPageProvider provider,
              Profile profile, _) {
            if (provider.paragraphs == null) {
              return LandingPage(color: Color(profile.novelBackgroundColor));
            }
            final _lightens =
            Global.lightness(Color(profile.novelBackgroundColor));

            // 音量键翻页 仅安卓
            // if(Platform.isAndroid){
            //   if (onVolumeDec == null) onVolumeDec = (v) {
            //     provider.tapNextPage();
            //   };
            //   if (onVolumeInc == null) onVolumeInc = (v) {
            //     provider.tapLastPage();
            //   };
            // }

            // final _volumeSwitchPage = provider.showChapter || provider.showMenu || provider.showSetting;
            // EsoPlugin.captureVolumeKeyboard(!_volumeSwitchPage,
            //     onVolumeInc: onVolumeInc, onVolumeDec: onVolumeDec);

            return RawKeyboardListener(
              focusNode: _backNode,
              onKey: (event) {
                if (event.runtimeType.toString()!=provider.enPress){
                  provider.enPress = event.runtimeType.toString();
                  // 按下时触发
                  if (event.runtimeType.toString()=='RawKeyUpEvent') return;

                  if(event.data is RawKeyEventDataMacOs){
                    RawKeyEventDataMacOs data = event.data;
                    print(data.keyCode);
                    switch(data.keyCode){
                      case 123:// 方向键左
                        provider.tapLastPage();
                        break;
                      case 124:// 方向键右
                        provider.tapNextPage();
                        break;
                      case 53:// esc
                        Navigator.pop(context);
                        break;
                      case 27:// -
                        provider.switchChapter(
                            profile, searchItem.durChapterIndex - 1);
                        break;
                      case 24:// +
                        provider.switchChapter(
                            profile, searchItem.durChapterIndex + 1);
                        break;
                      case 36: //enter
                        provider.showMenu = !provider.showMenu;
                        break;
                    }
                  }
                }
              },
              child: GestureDetector(
                child: Stack(
                  children: <Widget>[
                    AnnotatedRegion<SystemUiOverlayStyle>(
                      value: _lightens > 128 ||
                          _lightens < 3 // 亮度小于3说明是纯黑背景，大晚上的，顶部的时间如果高亮就亮瞎眼了
                          ? SystemUiOverlayStyle.dark
                          : SystemUiOverlayStyle.light,
                      child: ColoredBox(
                        color: Color(profile.novelBackgroundColor),
                        child: _buildContent(provider, profile),
                      ),
                    ),
                    if (provider.showChapter || provider.showMenu || provider.showSetting)
                      WillPopScope(
                        onWillPop: () async {
                          provider.showChapter = false;
                          provider.showSetting = false;
                          provider.showMenu = false;
                          return false;
                        },
                        child: SizedBox(),
                      ),
                    if (provider.showMenu)
                      UINovelMenu(searchItem: searchItem, profile: profile),
                    if (provider.showChapter)
                      UIChapterSelect(
                        searchItem: searchItem,
                        loadChapter: (index) {
                          provider.switchChapter(profile, index);
                        },
                      ),
                    if (provider.isLoading)
                      Opacity(
                        opacity: 0.8,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).canvasColor,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 42, vertical: 20),
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
                      ),
                  ],
                ),
                onTapUp: (TapUpDetails details) {
                  if (provider.showMenu || provider.showSetting) {
                    provider.showMenu = false;
                    provider.showSetting = false;
                    return;
                  }

                  final size = MediaQuery.of(context).size;
                  final _centerX = size.width * (1 / 4);
                  final _centerR = size.width - _centerX;
                  final _centerY = 100;
                  final _centerB = size.height - size.height * (1 / 3);

                  if (details.globalPosition.dx > _centerX &&
                      details.globalPosition.dx < _centerR &&
                      details.globalPosition.dy > _centerY &&
                      details.globalPosition.dy < _centerB) {
                    provider.showMenu = !provider.showMenu;
                    provider.showSetting = false;
                  } else {
                    provider.showChapter = false;
                    if (!provider.showSetting && !provider.showMenu) {
                      if (details.globalPosition.dx > size.width * 0.5) {
                        provider.tapNextPage();
                      } else if (details.globalPosition.dx < size.width * 0.5) {
                        provider.tapLastPage();
                      }
                    }
                  }
                },
              ),
            );

            //return ;
          },
        ),
      ),
    );
  }

  Widget _buildContent(NovelPageProvider provider, Profile profile) {
    switch (profile.novelPageSwitch) {
      case Profile.novelScroll:
        return NovelScrollView(profile: profile, provider: provider, searchItem: searchItem);
      case Profile.novelNone:
        return NovelNoneView(profile: profile, provider: provider, searchItem: searchItem);
      case Profile.novelCover:
      case Profile.novelFade:
        return NovelRoteView(profile: profile, provider: provider, searchItem: searchItem);
      default:
        return Center(child: Text("换页方式暂不支持\n请选择其他方式"));
    }
  }

}