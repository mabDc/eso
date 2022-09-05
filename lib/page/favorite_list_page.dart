import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/ui/ui_favorite_item.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/profile.dart';
import 'package:eso/model/favorite_list_provider.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../global.dart';
import 'chapter_page.dart';

/// 收藏夹列表页
class FavoriteListPage extends StatelessWidget {
  final void Function(Widget, void Function()) invokeTap;
  final int type;
  final bool editMode;
  const FavoriteListPage(
      {this.type, this.editMode = false, Key key, this.invokeTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SortType sortType;
    void Function(SortType sortType) setSortType;
    final values = SortType.values;
    final profile = Provider.of<Profile>(context, listen: false);
    switch (type) {
      case API.NOVEL:
        sortType = values[profile.novelSortIndex];
        setSortType =
            (SortType sortType) => profile.novelSortIndex = sortType.index;
        break;
      case API.MANGA:
        sortType = values[profile.mangaSortIndex];
        setSortType =
            (SortType sortType) => profile.mangaSortIndex = sortType.index;
        break;
      case API.AUDIO:
        sortType = values[profile.audioSortIndex];
        setSortType =
            (SortType sortType) => profile.audioSortIndex = sortType.index;
        break;
      case API.VIDEO:
        sortType = values[profile.videoSortIndex];
        setSortType =
            (SortType sortType) => profile.videoSortIndex = sortType.index;
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
                      context.select(
                          (FavoriteListProvider provider) => provider.sortType);

                  return GestureDetector(
                    onTap: () {
                      Provider.of<FavoriteListProvider>(context, listen: false)
                          .sortType = tag[1];
                      setSortType(tag[1]);
                    },
                    child: Material(
                      color: _isSelect
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                                : Theme.of(context).textTheme.bodyLarge.color,
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
              child: _buildFavoriteList(context, profile),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFavoriteList(BuildContext context, Profile profile) {
    return Consumer<FavoriteListProvider>(
      builder: (context, provider, _) {
        var searchItems = provider.searchList;
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

        searchItems = searchItems
            .where((element) => element.group == profile.currentGroup)
            .toList();

        // profile.currentGroup

        final _size = MediaQuery.of(context).size;
        switch (profile.listMode) {
          case 0:
          case 1:
            return ListView.builder(
              itemBuilder: (context, index) {
                final searchItem = searchItems[index];
                VoidCallback openChapter = () => invokeTap(
                    ChapterPage(
                      searchItem: searchItem,
                      key: Key(searchItem.id.toString()),
                    ),
                    (() => provider.updateList()));
                VoidCallback openContent = () => Navigator.of(context)
                    .push(ContentPageRoute().route(searchItem))
                    .whenComplete(() => provider.updateList());
                return InkWell(
                  onTap: openContent,
                  onLongPress: openChapter,
                  child: FavortieItemWithList(
                    searchItem: searchItems[index],
                    type: profile.listMode,
                  ),
                );
              },
              itemCount: searchItems.length,
            );

          case 2:
          case 3:
          case 4:
            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 6),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: profile.listMode,
                childAspectRatio: profile.listAspectRatio == null ||
                        profile.listAspectRatio <= 0.0
                    ? 1.0
                    : profile.listAspectRatio,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: searchItems.length,
              itemBuilder: (context, index) {
                final searchItem = searchItems[index];
                // final longPress = _size.width > 600 ||
                //     Provider.of<Profile>(context, listen: true).switchLongPress;
                final longPress = false;

                VoidCallback openChapter = () => invokeTap(
                    ChapterPage(
                      searchItem: searchItem,
                      key: Key(searchItem.id.toString()),
                    ),
                    (() => provider.updateList()));

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

          default:
            return Container();
        }
      },
    );
  }
}

class FavortieItemWithList extends StatelessWidget {
  final SearchItem searchItem;
  final int type;
  const FavortieItemWithList(
      {@required this.searchItem, this.type = 0, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = searchItem.chaptersCount;
    final currentCount = searchItem.durChapterIndex + 1;
    final suffix = {
      API.NOVEL: "章",
      API.MANGA: "话",
      API.AUDIO: "首",
      API.VIDEO: "集",
    };

    return DefaultTextStyle(
      style: TextStyle(
          fontFamily: Profile.staticFontFamily,
          fontSize: 13,
          color: Theme.of(context).hintColor,
          height: 1.5),
      overflow: TextOverflow.ellipsis,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: type == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    height: 104,
                    child: UIImageItem(
                        cover: searchItem.cover,
                        // fit: BoxFit.contain,
                        hero: Utils.empty(searchItem.cover)
                            ? null
                            : '$searchItem.name.$searchItem.cover.$searchItem.id'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          searchItem.name.trim(),
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: Profile.staticFontFamily,
                            color: Theme.of(context).textTheme.bodyLarge.color,
                            fontSize: 15,
                          ),
                        ),
                        Text(searchItem.author),
                        Text((count - currentCount) <= 0
                            ? '已看完'
                            : "${count - currentCount}${suffix[searchItem.ruleContentType]}未看"),
                        Text("最新:${searchItem.chapter}"),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    searchItem.name.trim(),
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Profile.staticFontFamily,
                      color: Theme.of(context).textTheme.bodyLarge.color,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    // height: 300,
                    width: double.infinity,
                    child: UIImageItem(
                      initHeight: 200,
                      cover: searchItem.cover,
                      hero: Utils.empty(searchItem.cover)
                          ? null
                          : '$searchItem.name.$searchItem.cover.$searchItem.id',
                    ),
                  ),
                  SizedBox(height: 5),
                  Text((count - currentCount) <= 0
                      ? '已看完'
                      : "${count - currentCount}${suffix[searchItem.ruleContentType]}未看${' ' * 5}最新:${searchItem.chapter}"),
                ],
              ),
      ),
    );
  }
}

class UIFavoriteItem2 extends StatelessWidget {
  final SearchItem searchItem;

  const UIFavoriteItem2({
    @required this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = searchItem.chaptersCount.toString();
    final currentCount = searchItem.durChapterIndex + 1;
    final suffix = {
      API.NOVEL: "章",
      API.MANGA: "话",
      API.AUDIO: "首",
      API.VIDEO: "集",
    };
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
            child: Container(
          width: double.infinity,
          child: UIImageItem(cover: searchItem.cover),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: Offset(0, 1), blurRadius: 2, color: Colors.black12)
          ]),
        )),
        SizedBox(height: 6),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            '${searchItem.name}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            '${"0" * (count.length - currentCount.toString().length)}$currentCount${suffix[searchItem.ruleContentType]}/$count${suffix[searchItem.ruleContentType]}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: Profile.staticFontFamily,
              fontSize: 10,
            ),
          ),
        ),
        SizedBox(height: 6),
      ],
    );
  }
}
