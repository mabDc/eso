import 'dart:convert';
import 'dart:io';

import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/global.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:text_composition/text_composition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:windows_speak/windows_speak.dart';

import '../fonticons_icons.dart';
import '../utils.dart';
import 'novel_auto_cache_page.dart';

class NovelPage extends StatelessWidget {
  final SearchItem searchItem;
  const NovelPage({Key key, this.searchItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContentProvider>(context);
    final bookName = "${searchItem.name}(${searchItem.origin})";
    final controller = TextComposition(
      config: TextCompositionConfig.fromJSON(Global.prefs.containsKey(TextConfigKey)
          ? jsonDecode(Global.prefs.get(TextConfigKey))
          : {}),
      loadChapter: provider.loadChapter,
      chapters: searchItem.chapters.map((e) => e.name).toList(),
      percent: () {
        final p = searchItem.durContentIndex / NovelContentTotal;
        final ch = (p * searchItem.chapters.length).floor();
        if (ch == searchItem.durChapterIndex) return p;
        return searchItem.durChapterIndex / searchItem.chapters.length;
      }(),
      onSave: (TextCompositionConfig config, double percent) async {
        Global.prefs.setString(TextConfigKey, jsonEncode(config.toJSON()));
        searchItem.durContentIndex = (percent * NovelContentTotal).floor();
        final index = (percent * searchItem.chapters.length).floor();
        HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
        if (searchItem.durChapterIndex != index) {
          searchItem.durChapterIndex = index;
          searchItem.durChapter = searchItem.chapters[index].name;
          // searchItem.durContentIndex = 1;
          await SearchItemManager.saveSearchItem();
        }
      },
      name: bookName,
      menuBuilder: (TextComposition composition) =>
          NovelMenu(searchItem: searchItem, composition: composition),
    );
    return TextCompositionPage(controller: controller);
  }
}

const NovelContentTotal = 100000000; // 10000 * 10000 <==> 一万章节 * 一万页
const TextConfigKey = "TextCompositionConfig";
int speakingCheck = -1;

class NovelMenu extends StatelessWidget {
  final SearchItem searchItem;
  final TextComposition composition;
  const NovelMenu({Key key, this.composition, this.searchItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
    final color = Theme.of(context).textTheme.bodyText1.color;
    return Column(
      children: <Widget>[
        AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(searchItem.name),
          brightness: brightness,
          titleSpacing: 0,
          actions: [
            IconButton(
              icon: Icon(FIcons.share_2),
              onPressed: () async {
                await FlutterShare.share(
                  title: '亦搜 eso',
                  text:
                      '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description.trim()}\n\n${searchItem.url}',
                  //linkUrl: '${searchItem.url}',
                  chooserTitle: '选择分享的应用',
                );
              },
            ),
            _buildPopupMenu(context, bgColor, color),
          ],
        ),
        SizedBox(height: 6),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(onPressed: speak, child: Text('朗读')),
            ElevatedButton(onPressed: stop, child: Text('停止')),
            ElevatedButton(onPressed: prevPage, child: Text('上一页')),
            ElevatedButton(onPressed: nextPage, child: Text('下一页')),
          ],
        ),
        Spacer(),
        _buildBottomRow(context, bgColor, color),
      ],
    );
  }

  Future<dynamic> _speak(int check) async {
    while (speakingCheck > 0 && speakingCheck == check) {
      final s = composition.textPages[composition.currentIndex]?.lines
          ?.map((e) => e.text)
          ?.join();
      if (s != null && s.isNotEmpty) {
        if (Global.isDesktop) {
          await WindowsSpeak.speak(s);
        } else {
          await FlutterTts().speak(s);
        }
      } else {
        break;
      }
      if (speakingCheck > 0 && speakingCheck == check) {
        composition.nextPage();
      } else {
        break;
      }
    }
  }

  speak() async {
    await stop();
    speakingCheck = DateTime.now().microsecondsSinceEpoch;
    _speak(speakingCheck);
  }

  Future<dynamic> stop() async {
    speakingCheck = -1;
    if (Global.isDesktop) {
      await WindowsSpeak.release();
    } else {
      await FlutterTts().stop();
    }
  }

  prevPage() async {
    await stop();
    composition.previousPage();
    speak();
  }

  nextPage() async {
    await stop();
    composition.nextPage();
    speak();
  }

  Widget _buildPopupMenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const ADD_ITEM = 3;
    const REFRESH = 4;
    const AUTO_CACHE = 5;
    const CLEARCACHE = 6;
    final primaryColor = Theme.of(context).primaryColor;

    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(FIcons.more_vertical, color: color),
      color: bgColor,
      onSelected: (int value) async {
        switch (value) {
          case AUTO_CACHE:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NovelAutoCachePage(searchItem: searchItem)));
            break;
          case TO_CLICPBOARD:
            final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
            final chapter = searchItem.chapters[searchItem.durChapterIndex];
            final url = chapter.contentUrl ?? Utils.getUrl(rule.host, chapter.url);
            if (url != null) {
              Clipboard.setData(ClipboardData(text: url));
              Utils.toast("已复制地址\n" + url);
            } else {
              Utils.toast("错误 地址为空");
            }
            break;
          case LAUCH:
            final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
            final chapter = searchItem.chapters[searchItem.durChapterIndex];
            final url = chapter.contentUrl ?? Utils.getUrl(rule.host, chapter.url);
            if (url != null) {
              launch(url);
            } else {
              Utils.toast("错误 地址为空");
            }
            break;
          case ADD_ITEM:
            () async {
              if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
                Utils.toast("已在收藏中", duration: Duration(seconds: 1));
              } else {
                final success = await SearchItemManager.addSearchItem(searchItem);
                if (success) {
                  Utils.toast("添加收藏成功！", duration: Duration(seconds: 1));
                } else {
                  Utils.toast("添加收藏失败！", duration: Duration(seconds: 1));
                }
              }
            }();
            break;
          case REFRESH:
            // 清理当前章节
            final cIndex = composition.textPages[composition.currentIndex]?.chIndex ??
                searchItem.durChapterIndex;
            final _fileCache =
                CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
            await _fileCache.requestPermission();
            await File(await _fileCache.cacheDir() + '$cIndex.txt').delete();
            Utils.toast("已删除当前章节缓存");
            // 加载当前章节
            composition.gotoChapter(cIndex);
            break;
          case CLEARCACHE:
            final _fileCache =
                CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
            await _fileCache.requestPermission();
            await _fileCache.clear();
            Utils.toast("清理成功");
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('自动缓存'),
              Icon(Icons.import_contacts, color: primaryColor),
            ],
          ),
          value: AUTO_CACHE,
        ),
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
              Text('加入收藏'),
              Icon(
                FIcons.heart,
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
                Text(
                  '章节',
                  style: TextStyle(color: color),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FlutterSlider(
                    values: [
                      1.0 +
                          (composition.textPages[composition.currentIndex]?.chIndex ??
                              searchItem.durChapterIndex)
                    ],
                    max: searchItem.chaptersCount * 1.0,
                    min: 1,
                    step: FlutterSliderStep(step: 1),
                    onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                      // provider.loadChapter((lowerValue as double).toInt() - 1);
                      composition.gotoChapter((lowerValue as double).toInt() - 1);
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
                            children: [
                              Expanded(
                                child: Text(
                                  searchItem.chapters[index - 1].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: composition.config.fontFamily,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                "$index / ${searchItem.chaptersCount}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: composition.config.fontFamily,
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
                Text(
                  '共${searchItem.chaptersCount}章',
                  style: TextStyle(color: color),
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
                    onTap: () => composition.gotoPreviousChapter(),
                  ),
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.format_list_bulleted, color: color, size: 28),
                        Text("目录", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () {
                      final x = composition.textPages[composition.currentIndex]?.chIndex;
                      if (x != null) searchItem.durChapterIndex = x;
                      showDialog(
                          context: context,
                          builder: (context) => UIChapterSelect(
                                searchItem: searchItem,
                                loadChapter: (index) {
                                  composition.gotoChapter(index);
                                  Navigator.of(context).pop();
                                },
                                color: bgColor,
                                fontColor: color,
                              ));
                    },
                  ),
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.text_format, color: color, size: 28),
                        Text("调节", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            width: 520,
                            child: configSettingBuilder(
                              context,
                              composition.config,
                              (Color color, void Function(Color color) onChange) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('选择颜色'),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: color,
                                        onColorChanged: onChange,
                                        showLabel: true,
                                        pickerAreaHeightPercent: 0.8,
                                        portraitOnly: true,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    child: Column(
                      children: [
                        Icon(Icons.arrow_forward, color: color, size: 28),
                        Text("下一章", style: TextStyle(color: color))
                      ],
                    ),
                    onTap: () => composition.gotoNextChapter(),
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
