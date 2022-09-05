import 'package:flutter/material.dart' hide MenuItem;
import 'package:outline_material_icons/outline_material_icons.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import 'menu_item.dart';

enum MenuVideoPlayer {
  openRaw,
  copyUrl,
  other_players,
  dlna,
}

List<MenuItem<MenuVideoPlayer>> videoPlayerMenus = [
  MenuItem<MenuVideoPlayer>(
    text: '查看源网页',
    icon: Icons.open_in_browser,
    value: MenuVideoPlayer.openRaw,
    color: Global.primaryColor,
  ),
  MenuItem<MenuVideoPlayer>(
    text: '复制视频地址',
    icon: Icons.copy,
    value: MenuVideoPlayer.copyUrl,
    color: Global.primaryColor,
  ),
  MenuItem<MenuVideoPlayer>(
    text: '使用其他播放器打开',
    icon: Icons.open_in_new,
    value: MenuVideoPlayer.other_players,
    color: Global.primaryColor,
  ),
  MenuItem<MenuVideoPlayer>(
    text: 'DLNA投屏',
    icon: Icons.airplay,
    value: MenuVideoPlayer.dlna,
    color: Global.primaryColor,
  ),
  // MenuItem<MenuVideoPlayer>(
  //   text: '倍速',
  //   icon: Icons.slow_motion_video_outlined,
  //   value: MenuVideoPlayer.other_players,
  //   color: Global.primaryColor,
  // ),
];
