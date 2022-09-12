import 'package:eso/database/search_item.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import '../page/manga_page.dart';

class UIMangaMenu extends StatelessWidget {
  final SearchItem searchItem;
  const UIMangaMenu({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.96);
    final color = Theme.of(context).textTheme.bodyText1.color;
    final provider = Provider.of<MangaPageProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: _buildTopRow(context, bgColor, color),
        ),
        provider.showSetting
            ? _buildSetting(context, bgColor, color)
            : _buildBottomRow(context, bgColor, color),
      ],
    );
  }

  Widget _buildSetting(BuildContext context, Color bgColor, Color color) {
    final provider = Provider.of<MangaPageProvider>(context);
    final profile = ESOTheme();
    return IconTheme(
      data: IconThemeData(size: 18, color: color),
      child: Container(
        width: double.infinity,
        color: bgColor,
        padding: EdgeInsets.fromLTRB(0, 4, 0, 16),
        child: Column(
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Text("亮度"),
                  SizedBox(width: 10),
                  Expanded(
                    child: FlutterSlider(
                      values: [provider.brightness * 100],
                      max: 100,
                      min: 0,
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        provider.brightness = lowerValue / 100;
                      },
                      // disabled: provider.isLoading,
                      handlerWidth: 6,
                      handlerHeight: 14,
                      handler: FlutterSliderHandler(
                        decoration: BoxDecoration(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: bgColor,
                            border: Border.all(color: color.withOpacity(0.65), width: 1),
                          ),
                        ),
                      ),
                      trackBar: FlutterSliderTrackBar(
                        inactiveTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: color.withOpacity(0.5),
                        ),
                        activeTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      tooltip: FlutterSliderTooltip(
                        disableAnimation: true,
                        custom: (value) => Container(
                          padding: EdgeInsets.all(8),
                          color: bgColor,
                          child: Text((value as double).toStringAsFixed(0)),
                        ),
                        positionOffset:
                            FlutterSliderTooltipPositionOffset(left: -20, right: -20),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("常亮"),
                  Switch(
                    value: profile.mangaKeepOn,
                    onChanged: (value) {
                      profile.mangaKeepOn = value;
                      provider.setKeepOn(value);
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Text("方向"),
                  SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      child: Text("上->下", style: TextStyle(color: color)),
                      onPressed: () {
                        profile.mangaDirection = ESOTheme.mangaDirectionTopToBottom;
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: color),
                      ))),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      child: Text("左->右", style: TextStyle(color: color)),
                      onPressed: () {
                        profile.mangaDirection = ESOTheme.mangaDirectionLeftToRight;
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: color),
                      ))),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      child: Text("右->左", style: TextStyle(color: color)),
                      onPressed: () {
                        profile.mangaDirection = ESOTheme.mangaDirectionRightToLeft;
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: color),
                      ))),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              alignment: Alignment.center,
              child: SwitchListTile(
                value: profile.mangaLandscape,
                onChanged: (value) {
                  profile.mangaLandscape = value;
                  provider.setLandscape(value);
                },
                title: Text("横屏"),
              ),
            ),
            Container(
              height: 50,
              alignment: Alignment.center,
              child: SwitchListTile(
                value: profile.showMangaStatus,
                onChanged: (value) => profile.showMangaStatus = value,
                title: Text("显示状态栏"),
              ),
            ),
            Container(
              height: 50,
              alignment: Alignment.center,
              child: SwitchListTile(
                value: profile.showMangaInfo,
                onChanged: (value) => profile.showMangaInfo = value,
                title: Text("显示章节信息"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, Color bgColor, Color color) {
    return AppBar(
      titleSpacing: 0,
      title: Text(searchItem.name),
      actions: [
        IconButton(
            icon: Icon(FIcons.share_2),
            tooltip: "分享",
            onPressed: Provider.of<MangaPageProvider>(context, listen: false).share),
        _buildPopupmenu(context, bgColor, color),
      ],
    );
  }

  Widget _buildPopupmenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const ADD_ITEM = 2;
    const REFRESH = 3;
    const CLEARCACHE = 4;
    final primaryColor = Theme.of(context).primaryColor;
    final provider = Provider.of<MangaPageProvider>(context, listen: false);
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(FIcons.more_vertical, color: color),
      color: bgColor,
      onSelected: (int value) async {
        switch (value) {
          case TO_CLICPBOARD:
            final chapter = searchItem.chapters[searchItem.durChapterIndex];
            final url = chapter.contentUrl ?? chapter.url;
            if (url != null) {
              Clipboard.setData(ClipboardData(text: url));
              Utils.toast("已复制地址\n" + url);
            } else {
              Utils.toast("地址为空");
            }
            break;
          case LAUCH:
            final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
            final chapter = searchItem.chapters[searchItem.durChapterIndex];
            final url = chapter.contentUrl ?? Utils.getUrl(rule.host, chapter.url);
            if (url != null) {
              launch(url);
            } else {
              Utils.toast("地址为空");
            }
            break;
          case ADD_ITEM:
            (() async {
              if (provider.isFavorite) {
                await provider.removeFormFavorite();
                Utils.toast("取消收藏成功！");
                return;
              }
              final success = await provider.addToFavorite();
              if (null == success) {
                Utils.toast("已在收藏中");
              } else if (success) {
                Utils.toast("添加收藏成功！");
              } else {
                Utils.toast("添加收藏失败！");
              }
            })();
            break;
          case REFRESH:
            provider.refreshCurrent();
            break;
          case CLEARCACHE:
            provider.clearCurrent();
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('复制原地址'),
              Icon(FIcons.copy, color: primaryColor),
            ],
          ),
          value: TO_CLICPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('查看原页面'),
              Icon(FIcons.external_link, color: primaryColor),
            ],
          ),
          value: LAUCH,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('重新加载'),
              Icon(FIcons.rotate_cw, color: primaryColor),
            ],
          ),
          value: REFRESH,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('清理缓存'),
              Icon(Icons.cleaning_services_outlined, color: primaryColor),
            ],
          ),
          value: CLEARCACHE,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(provider.isFavorite ? "取消收藏" : '加入收藏'),
              Icon(
                provider.isFavorite ? FIcons.trash : FIcons.heart,
                color: primaryColor,
              ),
            ],
          ),
          value: ADD_ITEM,
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, Color bgColor, Color color) {
    final provider = Provider.of<MangaPageProvider>(context);
    return Container(
      width: double.infinity,
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                InkWell(
                  child: Text(
                    '章节',
                    style: TextStyle(color: color),
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FlutterSlider(
                    values: [(searchItem.durChapterIndex + 1).toDouble()],
                    max: searchItem.chaptersCount.toDouble(),
                    min: 1,
                    step: FlutterSliderStep(step: 1),
                    onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                      provider.loadChapter((lowerValue as double).toInt() - 1);
                    },
                    // disabled: provider.isLoading,
                    handlerWidth: 6,
                    handlerHeight: 14,
                    handler: FlutterSliderHandler(
                      decoration: BoxDecoration(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: bgColor,
                          border: Border.all(color: color.withOpacity(0.65), width: 1),
                        ),
                      ),
                    ),
                    trackBar: FlutterSliderTrackBar(
                      inactiveTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: color.withOpacity(0.5),
                      ),
                      activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    touchSize: 30,
                    tooltip: FlutterSliderTooltip(
                      alwaysShowTooltip: true,
                      disableAnimation: true,
                      absolutePosition: true,
                      positionOffset: FlutterSliderTooltipPositionOffset(
                        left: -20,
                        top: -12,
                        right: 160 - MediaQuery.of(context).size.width,
                      ),
                      custom: (value) {
                        final index = (value as double).toInt();
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          color: bgColor,
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  searchItem.chapters[index - 1].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: ESOTheme.staticFontFamily,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                "$index / ${searchItem.chaptersCount}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: ESOTheme.staticFontFamily,
                                  color: color.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  child: Text(
                    '共${searchItem.chaptersCount}话',
                    style: TextStyle(color: color),
                  ),
                  onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_back, color: color, size: 28),
                        Text("上一章", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
                  ),
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.format_list_bulleted, color: color, size: 28),
                        Text("目录", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => provider.showChapter = !provider.showChapter,
                  ),
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.settings, color: color, size: 28),
                        Text("设置", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () {
                      provider.showChapter = false;
                      provider.showSetting = true;
                    },
                  ),
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_forward, color: color, size: 28),
                        Text("下一章", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
