import 'dart:io';

import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/novel_auto_cache_page.dart';
import 'package:eso/page/setting/font_family_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:eso/utils/text_input_formatter.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../fonticons_icons.dart';
import '../global.dart';

class UINovelMenu extends StatelessWidget {
  final SearchItem searchItem;
  final Profile profile;
  const UINovelMenu({
    this.searchItem,
    this.profile,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
    final color = Theme.of(context).textTheme.bodyText1.color;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
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
              onPressed: Provider.of<NovelPageProvider>(context, listen: false).share,
            ),
            _buildPopupMenu(context, bgColor, color),
          ],
        ),
        Wrap(
          children: [
            RaisedButton(onPressed: provider.speak, child: Text('朗读')),
            RaisedButton(onPressed: provider.stop, child: Text('停止')),
            RaisedButton(onPressed: provider.prevPara, child: Text('上一段')),
            RaisedButton(onPressed: provider.nextPara, child: Text('下一段')),
          ],
        ),
        Spacer(),
        provider.showSetting
            ? _buildSetting(context, bgColor, color)
            : _buildBottomRow(context, bgColor, color),
      ],
    );
  }

  Widget _buildSetting(BuildContext context, Color bgColor, Color color) {
    final provider = Provider.of<NovelPageProvider>(context);
    final profile = Provider.of<Profile>(context);
    final colors = [
      [const Color(0xfff1f1f1), const Color(0xff373534)], //白底
      [const Color(0xfff5ede2), const Color(0xff373328)], //浅黄
      [const Color(0xFFF5DEB3), const Color(0xff373328)], //黄
      [const Color(0xffe3f8e1), const Color(0xff485249)], //绿
      [const Color(0xff999c99), const Color(0xff353535)], //浅灰
      [const Color(0xff33383d), const Color(0xffc5c4c9)], //黑
      [const Color(0xff010203), const Color(0x3fffffff)], //纯黑
    ];
    final styles = [
      ["无动画", Profile.novelNone],
      ["滚动", Profile.novelScroll],
      ["覆盖", Profile.novelCover],
      ["淡入", Profile.novelFade],
      // ["滑动", Profile.novelSlide],
      // ["覆盖", Profile.novelCover],
      // ["仿真", Profile.novelSimulation],
      // ["上下滑动", Profile.novelVerticalSlide],
      // ["左右滑动", Profile.novelHorizontalSlide],
    ];
    return IconTheme(
      data: IconThemeData(size: 22, color: color),
      child: Container(
        width: double.infinity,
        color: bgColor,
        padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("亮度", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
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
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Text("常亮"),
                  Switch(
                    value: profile.novelKeepOn,
                    onChanged: (value) {
                      profile.novelKeepOn = value;
                      provider.setKeepOn(value);
                    },
                  ),
                  Spacer(),
                  Text("状态栏"),
                  Switch(
                    value: profile.showNovelStatus,
                    onChanged: (value) => profile.showNovelStatus = value,
                  ),
                  Spacer(),
                  Text("章节信息"),
                  Switch(
                    value: profile.showNovelInfo,
                    onChanged: (value) => profile.showNovelInfo = value,
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("上下", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: _buildAdjustEdit(
                      inputFormattersRegExp: r'^\d{0,2}$',
                      onIncDec: (v) => profile.novelTopPadding += v,
                      onChange: (v) => profile.novelTopPadding = v,
                      adjust: 5,
                      text: profile.novelTopPadding.toStringAsFixed(0),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 50,
                    child: Text("左右", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: _buildAdjustEdit(
                      inputFormattersRegExp: r'^\d{0,2}$',
                      onIncDec: (v) => profile.novelLeftPadding += v,
                      onChange: (v) => profile.novelLeftPadding = v,
                      adjust: 5,
                      text: profile.novelLeftPadding.toStringAsFixed(0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("行高", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: _buildAdjustEdit(
                      inputFormattersRegExp: r'^\d?(\.\d?)?$',
                      onIncDec: (v) => profile.novelHeight += v,
                      onChange: (v) => profile.novelHeight = v,
                      adjust: 0.5,
                      text: profile.novelHeight.toStringAsFixed(1),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 50,
                    child: Text("段距", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: _buildAdjustEdit(
                      inputFormattersRegExp: r'^\d{0,2}$',
                      onIncDec: (v) => profile.novelParagraphPadding += v,
                      onChange: (v) => profile.novelParagraphPadding = v,
                      adjust: 5,
                      text: profile.novelParagraphPadding.toStringAsFixed(0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("字号", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: _buildAdjustEdit(
                      inputFormattersRegExp: r'^\d{0,2}$',
                      onIncDec: (v) => profile.novelFontSize += v,
                      onChange: (v) => profile.novelFontSize = v,
                      adjust: 2,
                      text: profile.novelFontSize.toStringAsFixed(0),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 50,
                    child: Text("缩进", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: _buildAdjustEdit(
                      inputFormattersRegExp: r'^(0|1|2|3|4)?$',
                      onIncDec: (v) => profile.novelIndentation += v.toInt(),
                      onChange: (v) => profile.novelIndentation = v.toInt(),
                      adjust: 1,
                      text: profile.novelIndentation.toString(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    child: Text("翻页", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: styles.map((style) {
                          final _selected = style[1] == profile.novelPageSwitch;
                          final Color _bgColor =
                              _selected ? Theme.of(context).primaryColor : null;
                          return Container(
                            height: 26,
                            width: 32.0 + (style[0] as String).length * 16,
                            margin: const EdgeInsets.only(right: 4),
                            child: FlatButton(
                              color: _bgColor,
                              textColor:
                                  _selected ? Theme.of(context).canvasColor : color,
                              child: Text(style[0]),
                              onPressed: () => profile.novelPageSwitch = style[1],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide(
                                    color: _selected ? _bgColor : color,
                                    width: Global.borderSize),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    child: Text("配色", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: colors
                          .map((color) => InkWell(
                                child: color[0].value == profile.novelBackgroundColor &&
                                        color[1].value == profile.novelFontColor
                                    ? Container(
                                        width: 32.0,
                                        height: 32.0,
                                        decoration: BoxDecoration(
                                            color: color[0],
                                            border: Border.all(
                                                color: Theme.of(context).canvasColor,
                                                width: 2),
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(blurRadius: 2)]),
                                      )
                                    : CircleAvatar(
                                        radius: 16.0,
                                        backgroundColor: color[0],
                                      ),
                                onTap: () => profile.setNovelColor(color[0], color[1]),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text("更多", style: TextStyle(color: color.withOpacity(0.7))),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 28,
                      child: FlatButton(
                        child: Text('字体管理'),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: FontFamilyPage(
                              option: FontFamilyPage.setNovel,
                              showAppbar: false,
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: color, width: Global.borderSize),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 28,
                      child: FlatButton(
                        child: Text('字色和背景'),
                        onPressed: () {
                          final fontColor = 0;
                          final backgroundColor = 1;
                          int option = fontColor;
                          return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: const EdgeInsets.all(6.0),
                              content: StatefulBuilder(builder: (context, _state) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 12),
                                        Text('配置'),
                                        Container(
                                          width: 118,
                                          child: RadioListTile(
                                            value: fontColor,
                                            groupValue: option,
                                            onChanged: (value) =>
                                                _state(() => option = value),
                                            title: Text(
                                              '字色',
                                              style: TextStyle(
                                                  fontSize:
                                                      option == fontColor ? 14 : 12),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 118,
                                          child: RadioListTile(
                                            value: backgroundColor,
                                            groupValue: option,
                                            onChanged: (value) =>
                                                _state(() => option = value),
                                            title: Text(
                                              '背景',
                                              style: TextStyle(
                                                  fontSize: option == backgroundColor
                                                      ? 14
                                                      : 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ColorPicker(
                                      pickerColor: Color(option == fontColor
                                          ? profile.novelFontColor
                                          : profile.novelBackgroundColor),
                                      onColorChanged: (Color color) {
                                        if (option == fontColor) {
                                          profile.novelFontColor = color.value;
                                        } else {
                                          profile.novelBackgroundColor = color.value;
                                        }
                                      },
                                      pickerAreaHeightPercent: 0.6,
                                    ),
                                    SlidePicker(
                                      pickerColor: Color(option == fontColor
                                          ? profile.novelFontColor
                                          : profile.novelBackgroundColor),
                                      onColorChanged: (Color color) {
                                        if (option == fontColor) {
                                          profile.novelFontColor = color.value;
                                        } else {
                                          profile.novelBackgroundColor = color.value;
                                        }
                                      },
                                      paletteType: PaletteType.rgb,
                                      showLabel: false,
                                      showIndicator: false,
                                      enableAlpha: false,
                                      indicatorBorderRadius: const BorderRadius.vertical(
                                        top: const Radius.circular(10.0),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: color, width: Global.borderSize),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 28,
                      child: FlatButton(
                        child: Text('图片'),
                        onPressed: () async {
                          if (Global.isDesktop) {
                            final f = await showOpenPanel(
                              confirmButtonText: '选择图片',
                              allowedFileTypes: <FileTypeFilterGroup>[
                                FileTypeFilterGroup(
                                  label: '图片',
                                  fileExtensions: <String>['jpg', 'jpeg', 'png', 'gif'],
                                ),
                                FileTypeFilterGroup(
                                  label: '其他',
                                  fileExtensions: <String>[],
                                ),
                              ],
                            );
                            if (f.canceled) {
                              Utils.toast('未选取图片');
                              return;
                            }
                            final image = f.paths.first;
                            final file = File(image);
                            final name = Utils.getFileNameAndExt(image);
                            final _cacheUtil =
                                CacheUtil(backup: true, basePath: "background");
                            try {
                              final p = await _cacheUtil.requestPermission();
                              if (!p) {
                                Utils.toast('读取图片需要存储权限');
                                return;
                              }
                            } catch (e) {
                              Utils.toast('读取图片需要存储权限');
                              return;
                            }
                            final _dir = await _cacheUtil.cacheDir();
                            await _cacheUtil.putFile(name, file);
                            Utils.toast('图片已保存到$_dir $name');
                            profile.novelBackgroundImage = _dir + name;
                          } else {
                            FilePickerResult imagePick =
                                await FilePicker.platform.pickFiles(type: FileType.image);
                            if (imagePick == null) {
                              Utils.toast('未选取图片');
                              return;
                            }
                            final image = imagePick.files.single;
                            if (image.extension != 'jpg' &&
                                image.extension != 'jpeg' &&
                                image.extension != 'png' &&
                                image.extension != 'gif') {
                              Utils.toast('只支持扩展名为jpg或jpeg或png或gif的图片');
                              return;
                            }

                            final file = File(image.path);
                            final name = Utils.getFileNameAndExt(image.path);
                            final _cacheUtil =
                                CacheUtil(backup: true, basePath: "background");
                            try {
                              final p = await _cacheUtil.requestPermission();
                              if (!p) {
                                Utils.toast('读取图片需要存储权限');
                                return;
                              }
                            } catch (e) {
                              Utils.toast('读取图片需要存储权限');
                              return;
                            }
                            final _dir = await _cacheUtil.cacheDir();
                            await _cacheUtil.putFile(name, file);
                            Utils.toast('图片已保存到$_dir $name');
                            profile.novelBackgroundImage = _dir + name;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: color, width: Global.borderSize),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const SELECTABLE = 2;
    const ADD_ITEM = 3;
    const REFRESH = 4;
    const AUTO_CACHE = 5;
    const CLEARCACHE = 6;
    final primaryColor = Theme.of(context).primaryColor;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(FIcons.more_vertical, color: color),
      color: bgColor,
      onSelected: (int value) async {
        switch (value) {
          case AUTO_CACHE:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NovelAutoCachePage(
                      searchItem: searchItem,
                      provider: provider,
                    )));
            break;
          case TO_CLICPBOARD:
            final chapter = searchItem.chapters[searchItem.durChapterIndex];
            final url = chapter.contentUrl ?? chapter.url;
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
          case SELECTABLE:
            if (provider.useSelectableText) {
              provider.useSelectableText = false;
            } else {
              provider.useSelectableText = true;
              provider.showSetting = false;
              provider.showMenu = false;
            }
            break;
          case ADD_ITEM:
            (() async {
              final success = await provider.addToFavorite();
              if (null == success) {
                Utils.toast("已在收藏中", duration: Duration(seconds: 1));
              } else if (success) {
                Utils.toast("添加收藏成功！", duration: Duration(seconds: 1));
              } else {
                Utils.toast("添加收藏失败！", duration: Duration(seconds: 1));
              }
            })();
            break;
          case REFRESH:
            provider.refreshCurrent();
            break;
          case CLEARCACHE:
            provider.clearCurrent();
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
              Text(provider.useSelectableText ? '退出复制模式' : '进入复制模式'),
              Icon(
                provider.useSelectableText ? Icons.flip_to_back : Icons.flip_to_front,
                color: primaryColor,
              ),
            ],
          ),
          value: SELECTABLE,
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
    final provider = Provider.of<NovelPageProvider>(context);
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
                    values: [(searchItem.durChapterIndex + 1) * 1.0],
                    max: searchItem.chaptersCount * 1.0,
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
                      disableAnimation: true,
                      absolutePosition: true,
                      positionOffset: FlutterSliderTooltipPositionOffset(
                        left: -20,
                        top: -20,
                        right: 160 - MediaQuery.of(context).size.width,
                      ),
                      custom: (value) {
                        final index = (value as double).toInt();
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          color: bgColor,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                searchItem.chapters[index - 1].name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Profile.staticFontFamily,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "$index / ${searchItem.chaptersCount}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Profile.staticFontFamily,
                                  color: color.withOpacity(0.7),
                                  fontSize: 20,
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
                    '共${searchItem.chaptersCount}章',
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
                        Icon(Icons.text_format, color: color, size: 28),
                        Text("调节", style: TextStyle(color: color))
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

  Widget _buildAdjustEdit({
    @required String inputFormattersRegExp,
    @required ValueChanged<double> onIncDec,
    @required ValueChanged<double> onChange,
    @required double adjust,
    @required String text,
    String hint,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          child: Icon(Icons.remove),
          onTap: () => onIncDec(-adjust),
        ),
        Container(
          width: 40,
          height: 32,
          alignment: Alignment.center,
          child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                TextInputFormatterRegExp(RegExp(inputFormattersRegExp)),
              ],
              controller: TextEditingController(
                text: text,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint ?? text,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 4, top: 4),
              ),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => onChange(double.parse(value))),
        ),
        InkWell(
          child: Icon(Icons.add),
          onTap: () => onIncDec(adjust),
        ),
      ],
    );
  }
}
