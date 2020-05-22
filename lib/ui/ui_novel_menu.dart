import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:eso/utils/text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class UINovelMenu extends StatelessWidget {
  final SearchItem searchItem;
  const UINovelMenu({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
    final color = Theme.of(context).textTheme.bodyText1.color;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
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
    final provider = Provider.of<NovelPageProvider>(context);
    final profile = Provider.of<Profile>(context);
    final buttonWidth =
        (MediaQuery.of(context).size.width - 120 - 4 * 36 - 60) / 4 + 2 * 36;
    return IconTheme(
      data: IconThemeData(size: 18, color: color),
      child: Container(
        width: double.infinity,
        height: 220,
        color: bgColor,
        padding: EdgeInsets.fromLTRB(25, 4, 25, 16),
        child: Row(
          children: [
            Container(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("亮度", style: TextStyle(color: color.withOpacity(0.7))),
                  Text("字号", style: TextStyle(color: color.withOpacity(0.7))),
                  Text("高度", style: TextStyle(color: color.withOpacity(0.7))),
                  Text("背景", style: TextStyle(color: color.withOpacity(0.7))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
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
                                  border: Border.all(
                                      color: color.withOpacity(0.65), width: 1),
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
                              positionOffset: FlutterSliderTooltipPositionOffset(
                                  left: -20, right: -20),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("常亮"),
                        Switch(
                          value: profile.novelKeepOn,
                          onChanged: (value) {
                            profile.novelKeepOn = value;
                            provider.setKeepOn(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: buttonWidth,
                          child: OutlineButton(
                            child: Text("小", style: TextStyle(color: color)),
                            onPressed: () => profile.novelFontSize -= 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: color),
                            ),
                          ),
                        ),
                        Container(
                          width: buttonWidth,
                          child: OutlineButton(
                            child: Text("大", style: TextStyle(color: color)),
                            onPressed: () => profile.novelFontSize += 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: color),
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              border: Border.all(color: color.withOpacity(0.3))),
                          alignment: Alignment.center,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              TextInputFormatterRegExp(RegExp(r'^\d{0,2}$')),
                            ],
                            controller: TextEditingController(
                              text: profile.novelFontSize.toStringAsFixed(0),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: profile.novelFontSize.toStringAsFixed(0),
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                profile.novelFontSize = double.parse(value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        [3.0, Icons.drag_handle],
                        [2.5, Icons.menu],
                        [2.0, Icons.view_headline],
                        [1.5, Icons.format_align_justify],
                      ]
                          .map<Widget>(
                            (e) => InkWell(
                              onTap: () => profile.novelHeight = e[0],
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(18)),
                                    border: Border.all(color: color.withOpacity(0.3))),
                                alignment: Alignment.center,
                                child: Icon(e[1]),
                                //     Transform.rotate(
                                //   angle: pi / 2,
                                //   child: Icon(Icons.pause),
                                // ),
                              ),
                            ),
                          )
                          .toList()
                            ..add(
                              Container(
                                width: 60,
                                height: 36,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                    border: Border.all(color: color.withOpacity(0.3))),
                                alignment: Alignment.center,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    TextInputFormatterRegExp(RegExp(r'^\d?(\.\d?)?$')),
                                  ],
                                  controller: TextEditingController(
                                    text: profile.novelHeight.toStringAsFixed(1),
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: profile.novelHeight.toStringAsFixed(1),
                                  ),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (value) =>
                                      profile.novelHeight = double.parse(value),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          [0xfff1f1f1, 0xff373534], //白底
                          [0xfff5ede2, 0xff373328], //浅黄
                          [0xFFF5DEB3, 0xff373328], //黄
                          [0xffe3f8e1, 0xff485249], //绿
                          [0xff999c99, 0xff353535], //浅灰
                          [0xff33383d, 0xffc5c4c9], //黑
                        ]
                            .map<Widget>(
                              (color) => InkWell(
                                child: CircleAvatar(
                                  radius: 18.0,
                                  backgroundColor: Color(color[0]),
                                ),
                                onTap: () => profile.setNovelColor(color[0], color[1]),
                              ),
                            )
                            .toList()
                        // ..add(Container(
                        //   width: 60,
                        //   height: 30,
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.all(Radius.circular(16)),
                        //       border: Border.all(color: color.withOpacity(0.3))),
                        //   alignment: Alignment.center,
                        //   child: Text("更多"),
                        // ))
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

  Widget _buildTopRow(BuildContext context, Color bgColor, Color color) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(color: bgColor),
      padding: EdgeInsets.fromLTRB(12, 4 + MediaQuery.of(context).padding.top, 12, 4),
      child: Row(
        children: <Widget>[
          InkWell(
            child: Icon(Icons.arrow_back_ios, color: color, size: 26),
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${searchItem.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, color: color),
                ),
                Text(
                  '${searchItem.author}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.75)),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            child: Icon(Icons.share, color: color, size: 26),
            onTap: Provider.of<NovelPageProvider>(context, listen: false).share,
          ),
          _buildPopupmenu(context, bgColor, color),
        ],
      ),
    );
  }

  Widget _buildPopupmenu(BuildContext context, Color bgColor, Color color) {
    const TO_CLICPBOARD = 0;
    const LAUCH = 1;
    const SELECTABLE = 2;
    const ADD_ITEM = 3;
    const REFRESH = 4;
    final primaryColor = Theme.of(context).primaryColor;
    final provider = Provider.of<NovelPageProvider>(context, listen: false);
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.more_vert, color: color, size: 26),
      color: bgColor,
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case TO_CLICPBOARD:
            Clipboard.setData(
                ClipboardData(text: searchItem.chapters[searchItem.durChapterIndex].url));
            Toast.show(
                "已复制地址\n" + searchItem.chapters[searchItem.durChapterIndex].url, context);
            break;
          case LAUCH:
            launch(searchItem.chapters[searchItem.durChapterIndex].url);
            break;
          case SELECTABLE:
            provider.useSelectableText = !provider.useSelectableText;
            break;
          case ADD_ITEM:
            // TODO: 收藏
            Toast.show("功能未完成，请返回详情页操作", context, duration: 1);
            break;
          case REFRESH:
            // TODO: 重新加载
            Toast.show("功能未完成，请返回详情页操作", context, duration: 1);
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
              Icon(Icons.content_copy, color: primaryColor),
            ],
          ),
          value: TO_CLICPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('查看原页面'),
              Icon(Icons.launch, color: primaryColor),
            ],
          ),
          value: LAUCH,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('重新加载'),
              Icon(Icons.refresh, color: primaryColor),
            ],
          ),
          value: REFRESH,
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
                Icons.add_to_photos,
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
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
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
        ],
      ),
    );
  }
}
