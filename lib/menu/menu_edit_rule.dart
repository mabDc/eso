import 'package:flutter/material.dart' hide MenuItem;
import 'package:outline_material_icons/outline_material_icons.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import 'menu_item.dart';

enum MenuEditRule {
  login,
  import,
  yiciyuan,
  copy,
  copy_origin,
  share_origin,
  preview,
  delete,
  help,
}

List<MenuItem<MenuEditRule>> editRuleMenus = [
  MenuItem<MenuEditRule>(
    text: '登录',
    icon: OMIcons.supervisedUserCircle,
    value: MenuEditRule.login,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '从剪贴板导入',
    icon: Icons.paste,
    value: MenuEditRule.import,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '阅读或异次元',
    icon: FIcons.book_open,
    value: MenuEditRule.yiciyuan,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '导出到剪贴板',
    icon: OMIcons.computer,
    value: MenuEditRule.copy,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '复制原始文本',
    icon: OMIcons.fileCopy,
    value: MenuEditRule.copy_origin,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '分享原始文本',
    icon: FIcons.share_2,
    value: MenuEditRule.share_origin,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '预览',
    icon: OMIcons.category,
    value: MenuEditRule.preview,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '删除',
    icon: OMIcons.deleteSweep,
    value: MenuEditRule.delete,
    color: Global.primaryColor,
  ),
  MenuItem<MenuEditRule>(
    text: '帮助',
    icon: OMIcons.helpOutline,
    value: MenuEditRule.help,
    color: Global.primaryColor,
  ),
];
