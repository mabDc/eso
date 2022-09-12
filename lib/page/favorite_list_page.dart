import 'package:eso/api/api.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/ui/ui_favorite_item.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/model/favorite_list_provider.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
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
    SortType sortType;
    void Function(SortType sortType) setSortType;
    final values = SortType.values;
    final profile = ESOTheme();
    switch (type) {
      case API.NOVEL:
        sortType = values[profile.novelSortIndex];
        setSortType = (SortType sortType) => profile.novelSortIndex = sortType.index;
        break;
      case API.MANGA:
        sortType = values[profile.mangaSortIndex];
        setSortType = (SortType sortType) => profile.mangaSortIndex = sortType.index;
        break;
      case API.AUDIO:
        sortType = values[profile.audioSortIndex];
        setSortType = (SortType sortType) => profile.audioSortIndex = sortType.index;
        break;
      case API.VIDEO:
        sortType = values[profile.videoSortIndex];
        setSortType = (SortType sortType) => profile.videoSortIndex = sortType.index;
        break;
      default:
    }
    const menuList = [
      ['收藏顺序', SortType.CREATE],
      ['更新时间', SortType.UPDATE],
      ['最后阅读', SortType.LASTREAD]
    ];
    return ChangeNotifierProvider<FavoriteListProvider>(
      create: (context) => FavoriteListProvider(type, sortType),
      builder: (context, child) => Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 12, bottom: 10),
            child: Wrap(
              spacing: 8,
              children: menuList.map(
                (tag) {
                  final _isSelect = tag[1] ==
                      context
                          .select((FavoriteListProvider provider) => provider.sortType);
                  return GestureDetector(
                    onTap: () {
                      Provider.of<FavoriteListProvider>(context, listen: false).sortType =
                          tag[1];
                      setSortType(tag[1]);
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
                          tag[0],
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
      ),
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
            final longPress = _size.width > 600 ||
                ESOTheme().switchLongPress;
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
