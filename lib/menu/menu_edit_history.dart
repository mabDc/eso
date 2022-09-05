import 'package:flutter/material.dart' hide MenuItem;
import 'package:outline_material_icons/outline_material_icons.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import 'menu_item.dart';

enum MenuHistory {
  all,
  revert,
  delete,
}

List<MenuItem<MenuHistory>> EditHistoryMenus = [
  MenuItem<MenuHistory>(
    text: '全选',
    icon: OMIcons.adjust,
    value: MenuHistory.all,
    color: Global.primaryColor,
  ),
  MenuItem<MenuHistory>(
    text: '反选',
    icon: Icons.album,
    value: MenuHistory.revert,
    color: Global.primaryColor,
  ),
  MenuItem<MenuHistory>(
    text: '删除所选',
    icon: OMIcons.deleteSweep,
    value: MenuHistory.delete,
    color: Global.primaryColor,
  ),
];
