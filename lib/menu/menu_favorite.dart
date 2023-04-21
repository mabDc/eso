import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import 'menu_item.dart';

enum MenuFavorite {
  addItem,
  editGroup,
  history,
  more_settings,
}

List<MenuItem<MenuFavorite>> favoriteMenus = [
  MenuItem<MenuFavorite>(
    text: '添加书籍',
    icon: OMIcons.addToPhotos,
    value: MenuFavorite.addItem,
    color: Global.primaryColor,
  ),
  // MenuItem<MenuFavorite>(
  //   text: '修改分组',
  //   icon: OMIcons.changeHistory,
  //   value: MenuFavorite.editGroup,
  //   color: Global.primaryColor,
  // ),
  MenuItem<MenuFavorite>(
    text: '历史浏览',
    icon: OMIcons.history,
    value: MenuFavorite.history,
    color: Global.primaryColor,
  ),
  MenuItem<MenuFavorite>(
    text: '更多设置',
    icon: OMIcons.unfoldMore,
    value: MenuFavorite.more_settings,
    color: Global.primaryColor,
  ),
];
