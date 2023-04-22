import 'package:eso/api/api.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/ui/ui_favorite_item.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/model/favorite_list_provider.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../global.dart';
import 'chapter_page.dart';

/// 收藏夹列表页
class FavoriteListPage extends StatelessWidget {
  final void Function(Widget) invokeTap;
  final int type;
  const FavoriteListPage({this.type, Key key, this.invokeTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SortType sortType;
    // void Function(SortType sortType) setSortType;
    // final values = SortType.values;
    // final profile = ESOTheme();
    // switch (type) {
    //   case API.NOVEL:
    //     sortType = values[profile.novelSortIndex];
    //     setSortType = (SortType sortType) => profile.novelSortIndex = sortType.index;
    //     break;
    //   case API.MANGA:
    //     sortType = values[profile.mangaSortIndex];
    //     setSortType = (SortType sortType) => profile.mangaSortIndex = sortType.index;
    //     break;
    //   case API.AUDIO:
    //     sortType = values[profile.audioSortIndex];
    //     setSortType = (SortType sortType) => profile.audioSortIndex = sortType.index;
    //     break;
    //   case API.VIDEO:
    //     sortType = values[profile.videoSortIndex];
    //     setSortType = (SortType sortType) => profile.videoSortIndex = sortType.index;
    //     break;
    //   default:
    // }

    return ChangeNotifierProvider<FavoriteListProvider>(
      create: (context) => FavoriteListProvider(type),
      builder: (context, child) {
        final provider = Provider.of<FavoriteListProvider>(context, listen: true);
        final menuList = [
          // ['收藏顺序', SortType.CREATE],
          // ['更新时间', SortType.UPDATE],
          // ['最后阅读', SortType.LASTREAD],
          "全部",
          ...provider.tags,
          "+",
        ];
        return Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 12, bottom: 4, top: 8),
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: menuList.map(
                  (tag) {
                    final _isSelect = tag == provider.selectTag;
                    return GestureDetector(
                      onLongPress: () {
                        // 编辑分组内容
                        if (tag != "全部" && tag != "+")
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.zero,
                                title: Text(tag),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        final _c = context;
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("删除分组"),
                                                content: Text("$tag"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        provider.removeTag(tag);
                                                        Navigator.of(context).pop();
                                                        Navigator.of(_c).pop();
                                                      },
                                                      child: Text("确定"))
                                                ],
                                              );
                                            });
                                      },
                                      child: Text(
                                        "删除该分组",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        if (provider.selectTag == tag) {
                                          provider.updateList();
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("生效")),
                                ],
                                content: Container(
                                  width: 330,
                                  child: ListView(
                                    itemExtent: 60,
                                    children: [
                                      for (var item in provider.allSearchList)
                                        StatefulBuilder(
                                          builder: (BuildContext context, setState) {
                                            final select = item.tags.contains(tag);
                                            return ListTile(
                                              onTap: () {
                                                if (select) {
                                                  item.tags.remove(tag);
                                                  item.save();
                                                } else {
                                                  item.tags.add(tag);
                                                  item.save();
                                                }
                                                setState(() {});
                                              },
                                              title: Text(
                                                "${item.name}",
                                                maxLines: 1,
                                              ),
                                              subtitle: Text(
                                                "@${item.author}[${item.origin}]",
                                                maxLines: 1,
                                              ),
                                              trailing: Icon(
                                                  Icons.check_circle_outline_outlined,
                                                  color: select
                                                      ? Theme.of(context).primaryColor
                                                      : Theme.of(context).highlightColor),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                      },
                      onTap: () {
                        if (tag == "+") {
                          final TextEditingController controller =
                              TextEditingController();
                          var onPressed = () {
                            final tag = controller.text.trim();
                            if (tag.isEmpty ||
                                tag == "+" ||
                                tag == "全部" ||
                                provider.tags.contains(tag)) {
                              Utils.toast("分组不能为空或重复");
                            } else {
                              provider.addToTag(tag);
                              Navigator.of(context).pop();
                              Future.delayed(Duration(seconds: 1), controller.dispose);
                            }
                            ;
                          };
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: TextField(
                                controller: controller,
                                onSubmitted: (value) => onPressed(),
                              ),
                              title: Text("添加分组"),
                              actions: [
                                TextButton(
                                  child: Text("确定"),
                                  onPressed: onPressed,
                                ),
                              ],
                            ),
                          );
                          // provider.addToTag("");
                        } else {
                          provider.changeToTag(tag);
                        }
                        // Provider.of<FavoriteListProvider>(context, listen: false).sortType =
                        //     tag[1];
                        // setSortType(tag[1]);
                      },
                      child: Material(
                        color: _isSelect
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            side: BorderSide(
                                width: Global.borderSize,
                                color: _isSelect
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).dividerColor)),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: _isSelect
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context).textTheme.bodyText1.color,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await SearchItemManager.refreshAll();
                  return;
                },
                child: _buildFavoriteGrid(context),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildFavoriteGrid(BuildContext context) {
    return Consumer<FavoriteListProvider>(
      builder: (context, provider, _) {
        final searchItems = provider.searchList;
        if (searchItems.length == 0) {
          return EmptyListMsgView(
              text: Column(
            children: [
              Text("还没有收藏哦!"),
              SizedBox(height: 16),
              Text("小提示：使用发现或搜索来获取您需要的内容", style: TextStyle(fontSize: 10))
            ],
          ));
        }

        final _size = MediaQuery.of(context).size;

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 6),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.55,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: searchItems.length,
          itemBuilder: (context, index) {
            final searchItem = searchItems[index];
            final longPress = _size.width > 600 || ESOTheme().switchLongPress;
            VoidCallback openChapter = () => invokeTap(ChapterPage(
                  searchItem: searchItem,
                  key: Key(searchItem.id.toString()),
                ));
            VoidCallback openContent = () => Navigator.of(context)
                .push(ContentPageRoute().route(searchItem))
                .whenComplete(() => provider.updateList());
            return InkWell(
              child: Container(
                padding: const EdgeInsets.all(6),
                child: UIFavoriteItem(searchItem: searchItem),
              ),
              onTap: longPress ? openChapter : openContent,
              onLongPress: longPress ? openContent : openChapter,
            );
          },
        );
      },
    );
  }
}
