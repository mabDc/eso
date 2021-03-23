// import 'dart:io';
//
// import 'package:eso/database/search_item.dart';
// import 'package:eso/model/novel_page_provider.dart';
// import 'package:eso/profile.dart';
// import 'package:eso/page/novel_auto_cache_page.dart';
// import 'package:eso/page/setting/font_family_page.dart';
// import 'package:eso/utils.dart';
// import 'package:eso/utils/cache_util.dart';
// import 'package:eso/utils/flutter_slider.dart';
// import 'package:eso/utils/text_input_formatter.dart';
// import 'package:file_chooser/file_chooser.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../fonticons_icons.dart';
// import '../global.dart';
//
// class UINovelMenu extends StatelessWidget {
//   final SearchItem searchItem;
//   final Profile profile;
//   const UINovelMenu({
//     this.searchItem,
//     this.profile,
//     Key key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     final bgColor = Theme.of(context).canvasColor.withOpacity(0.97);
//     final color = Theme.of(context).textTheme.bodyText1.color;
//     return Column(
//       children: <Widget>[
//         AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Text(searchItem.name),
//           brightness: brightness,
//           titleSpacing: 0,
//           actions: [
//             IconButton(
//               icon: Icon(FIcons.share_2),
//               onPressed: Provider.of<NovelPageProvider>(context, listen: false).share,
//             ),
//             _buildPopupMenu(context, bgColor, color),
//           ],
//         ),
//         SizedBox(height: 6),
//         // Wrap(
//         //   children: [
//         //     ElevatedButton(onPressed: provider.speak, child: Text('朗读')),
//         //     ElevatedButton(onPressed: provider.stop, child: Text('停止')),
//         //     ElevatedButton(onPressed: provider.prevPara, child: Text('上一段')),
//         //     ElevatedButton(onPressed: provider.nextPara, child: Text('下一段')),
//         //   ],
//         // ),
//         Spacer(),
//         _buildBottomRow(context, bgColor, color),
//       ],
//     );
//   }
//
//   Widget _buildPopupMenu(BuildContext context, Color bgColor, Color color) {
//     const TO_CLICPBOARD = 0;
//     const LAUCH = 1;
//     const ADD_ITEM = 3;
//     const REFRESH = 4;
//     const AUTO_CACHE = 5;
//     const CLEARCACHE = 6;
//     final primaryColor = Theme.of(context).primaryColor;
//     final provider = Provider.of<NovelPageProvider>(context, listen: false);
//     return PopupMenuButton<int>(
//       elevation: 20,
//       icon: Icon(FIcons.more_vertical, color: color),
//       color: bgColor,
//       onSelected: (int value) async {
//         switch (value) {
//           case AUTO_CACHE:
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => NovelAutoCachePage(
//                       searchItem: searchItem,
//                       provider: provider,
//                     )));
//             break;
//           case TO_CLICPBOARD:
//             final chapter = searchItem.chapters[searchItem.durChapterIndex];
//             final url = chapter.contentUrl ?? chapter.url;
//             if (url != null) {
//               Clipboard.setData(ClipboardData(text: url));
//               Utils.toast("已复制地址\n" + url);
//             } else {
//               Utils.toast("错误 地址为空");
//             }
//             break;
//           case LAUCH:
//             final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
//             final chapter = searchItem.chapters[searchItem.durChapterIndex];
//             final url = chapter.contentUrl ?? Utils.getUrl(rule.host, chapter.url);
//             if (url != null) {
//               launch(url);
//             } else {
//               Utils.toast("错误 地址为空");
//             }
//             break;
//           case ADD_ITEM:
//             (() async {
//               final success = await provider.addToFavorite();
//               if (null == success) {
//                 Utils.toast("已在收藏中", duration: Duration(seconds: 1));
//               } else if (success) {
//                 Utils.toast("添加收藏成功！", duration: Duration(seconds: 1));
//               } else {
//                 Utils.toast("添加收藏失败！", duration: Duration(seconds: 1));
//               }
//             })();
//             break;
//           case REFRESH:
//             provider.refreshCurrent();
//             break;
//           case CLEARCACHE:
//             provider.clearCurrent();
//             Utils.toast("清理成功");
//             break;
//           default:
//         }
//       },
//       itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
//         PopupMenuItem(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text('自动缓存'),
//               Icon(Icons.import_contacts, color: primaryColor),
//             ],
//           ),
//           value: AUTO_CACHE,
//         ),
//         PopupMenuItem(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text('复制原地址'),
//               Icon(FIcons.copy, color: primaryColor),
//             ],
//           ),
//           value: TO_CLICPBOARD,
//         ),
//         PopupMenuItem(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text('查看原页面'),
//               Icon(FIcons.external_link, color: primaryColor),
//             ],
//           ),
//           value: LAUCH,
//         ),
//         PopupMenuItem(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text('重新加载'),
//               Icon(FIcons.rotate_cw, color: primaryColor),
//             ],
//           ),
//           value: REFRESH,
//         ),
//         PopupMenuItem(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text('清理缓存'),
//               Icon(Icons.cleaning_services_outlined, color: primaryColor),
//             ],
//           ),
//           value: CLEARCACHE,
//         ),
//         PopupMenuItem(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text('加入收藏'),
//               Icon(
//                 FIcons.heart,
//                 color: primaryColor,
//               ),
//             ],
//           ),
//           value: ADD_ITEM,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBottomRow(BuildContext context, Color bgColor, Color color) {
//     final provider = Provider.of<NovelPageProvider>(context);
//     return Container(
//       width: double.infinity,
//       alignment: Alignment.bottomLeft,
//       decoration: BoxDecoration(color: bgColor),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: <Widget>[
//                 InkWell(
//                   child: Text(
//                     '章节',
//                     style: TextStyle(color: color),
//                   ),
//                   onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: FlutterSlider(
//                     values: [(searchItem.durChapterIndex + 1) * 1.0],
//                     max: searchItem.chaptersCount * 1.0,
//                     min: 1,
//                     step: FlutterSliderStep(step: 1),
//                     onDragCompleted: (handlerIndex, lowerValue, upperValue) {
//                       provider.loadChapter((lowerValue as double).toInt() - 1);
//                     },
//                     // disabled: provider.isLoading,
//                     handlerWidth: 6,
//                     handlerHeight: 14,
//                     handler: FlutterSliderHandler(
//                       decoration: BoxDecoration(),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(3),
//                           color: bgColor,
//                           border: Border.all(color: color.withOpacity(0.65), width: 1),
//                         ),
//                       ),
//                     ),
//                     trackBar: FlutterSliderTrackBar(
//                       inactiveTrackBar: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: color.withOpacity(0.5),
//                       ),
//                       activeTrackBar: BoxDecoration(
//                         borderRadius: BorderRadius.circular(4),
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                     touchSize: 30,
//                     tooltip: FlutterSliderTooltip(
//                       alwaysShowTooltip: true,
//                       disableAnimation: true,
//                       absolutePosition: true,
//                       positionOffset: FlutterSliderTooltipPositionOffset(
//                         left: -20,
//                         top: -12,
//                         right: 160 - MediaQuery.of(context).size.width,
//                       ),
//                       custom: (value) {
//                         final index = (value as double).toInt();
//                         return Container(
//                           width: MediaQuery.of(context).size.width,
//                           color: bgColor,
//                           padding: EdgeInsets.all(16),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   searchItem.chapters[index - 1].name,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: Profile.staticFontFamily,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 "$index / ${searchItem.chaptersCount}",
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: Profile.staticFontFamily,
//                                   color: color.withOpacity(0.7),
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 InkWell(
//                   child: Text(
//                     '共${searchItem.chaptersCount}章',
//                     style: TextStyle(color: color),
//                   ),
//                   onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
//                 ),
//               ],
//             ),
//           ),
//           SafeArea(
//             top: false,
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     child: Column(
//                       children: [
//                         Icon(Icons.arrow_back, color: color, size: 28),
//                         Text("上一章", style: TextStyle(color: color))
//                       ],
//                     ),
//                     onTap: () => provider.loadChapter(searchItem.durChapterIndex - 1),
//                   ),
//                   InkWell(
//                     child: Column(
//                       children: [
//                         Icon(Icons.format_list_bulleted, color: color, size: 28),
//                         Text("目录", style: TextStyle(color: color))
//                       ],
//                     ),
//                     onTap: () => provider.showChapter = !provider.showChapter,
//                   ),
//                   InkWell(
//                     child: Column(
//                       children: [
//                         Icon(Icons.text_format, color: color, size: 28),
//                         Text("调节", style: TextStyle(color: color))
//                       ],
//                     ),
//                     onTap: () {
//                       provider.showChapter = false;
//                       provider.showSetting = true;
//                     },
//                   ),
//                   InkWell(
//                     child: Column(
//                       children: [
//                         Icon(Icons.arrow_forward, color: color, size: 28),
//                         Text("下一章", style: TextStyle(color: color))
//                       ],
//                     ),
//                     onTap: () => provider.loadChapter(searchItem.durChapterIndex + 1),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAdjustEdit({
//     @required String inputFormattersRegExp,
//     @required ValueChanged<double> onIncDec,
//     @required ValueChanged<double> onChange,
//     @required double adjust,
//     @required String text,
//     String hint,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         InkWell(
//           child: Icon(Icons.remove),
//           onTap: () => onIncDec(-adjust),
//         ),
//         Container(
//           width: 40,
//           height: 32,
//           alignment: Alignment.center,
//           child: TextField(
//               keyboardType: TextInputType.number,
//               inputFormatters: <TextInputFormatter>[
//                 TextInputFormatterRegExp(RegExp(inputFormattersRegExp)),
//               ],
//               controller: TextEditingController(
//                 text: text,
//               ),
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: hint ?? text,
//                 isDense: true,
//                 contentPadding: EdgeInsets.only(bottom: 4, top: 4),
//               ),
//               textAlign: TextAlign.center,
//               textAlignVertical: TextAlignVertical.center,
//               textInputAction: TextInputAction.done,
//               onSubmitted: (value) => onChange(double.parse(value))),
//         ),
//         InkWell(
//           child: Icon(Icons.add),
//           onTap: () => onIncDec(adjust),
//         ),
//       ],
//     );
//   }
// }
