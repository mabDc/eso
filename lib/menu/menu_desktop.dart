import 'package:flutter/material.dart' hide MenuItem;
import 'package:outline_material_icons/outline_material_icons.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import 'menu_item.dart';

enum MenuDecsktop {
  editSource,
  refresh,
}

List<MenuItem<MenuDecsktop>> EditDesktopMenus = [
  MenuItem<MenuDecsktop>(
    text: '编辑规则',
    icon: OMIcons.settingsEthernet,
    value: MenuDecsktop.editSource,
    color: Global.primaryColor,
  ),
  MenuItem<MenuDecsktop>(
    text: '刷新地址',
    icon: Icons.refresh,
    value: MenuDecsktop.refresh,
    color: Global.primaryColor,
  ),
];
