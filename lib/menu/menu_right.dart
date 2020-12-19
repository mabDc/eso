import 'menu_item.dart';

enum MenuRight {
  copy,
  cut,
  paste,
  all,
  clear,
}

const List<MenuItem<MenuRight>> rightMenus = [
  MenuItem<MenuRight>(text: '复制', value: MenuRight.copy),
  MenuItem<MenuRight>(text: '剪切', value: MenuRight.cut),
  MenuItem<MenuRight>(text: '粘贴', value: MenuRight.paste),
  MenuItem<MenuRight>(text: '全选', value: MenuRight.all),
  MenuItem<MenuRight>(text: '清空', value: MenuRight.clear),
];
