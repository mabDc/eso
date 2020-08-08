import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/ui/widgets/app_bar_button.dart';
import 'package:flutter/material.dart';

class NovelAutoCachePage extends StatelessWidget {
  final SearchItem searchItem;
  final NovelPageProvider provider;

  const NovelAutoCachePage({
    Key key,
    @required this.searchItem,
    @required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    // final bgColor = Theme.of(context).canvasColor.withOpacity(0.1);
    // final color = Theme.of(context).textTheme.bodyText1.color;
    final chapters = searchItem.chapters;
    final cacheIndex = provider.cacheChapterIndex;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${searchItem.origin} - ${searchItem.name}',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        actions: [
          AppBarButton(
            onPressed: provider.exportCache,
            icon: Icon(Icons.exit_to_app),
            tooltip: "导出已缓存章节",
          ),
          AppBarButton(
            onPressed: provider.toggleAutoCache,
            icon: Icon(Icons.play_arrow),
            tooltip: "开始缓存",
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: searchItem.chaptersCount,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(chapters[index].name ?? 0),
                  cacheIndex.contains(index)
                      ? Text(
                          "已缓存",
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          "未缓存",
                          style: TextStyle(color: Colors.grey),
                        ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// import 'package:eso/database/search_item.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class NovelCacheManagePage extends StatelessWidget {
//   final SearchItem searchItem;
//   const NovelCacheManagePage({
//     Key key,
//     this.searchItem,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final top = MediaQuery.of(context).padding.top;
//     final containerHeight = 50.0;
//     final bgColor = Theme.of(context).canvasColor.withOpacity(0.1);
//     final color = Theme.of(context).textTheme.bodyText1.color;
//     final chapters = searchItem.chapters;
//     return Scaffold(
//       body: ChangeNotifierProvider<_CacheManage>(
//           create: (_) => _CacheManage(seachItem: searchItem),
//           builder: (context, child) {
//             final provider = Provider.of<_CacheManage>(context, listen: false);
//             return Stack(
//               children: [
//                 Container(
//                   padding: EdgeInsets.only(top: top),
//                   height: containerHeight,
//                   color: Colors.amberAccent,
//                   child: buildTopBar(context, color),
//                 ),
//                 ListView.builder(
//                   padding: EdgeInsets.only(top: top + containerHeight),
//                   itemCount: searchItem.chaptersCount,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(chapters[index].name ?? 0),
//                         Text("已缓存"),
//                       ],
//                     );
//                   },
//                 ),
//               ],
//             );
//           }),
//     );
//   }

//   Widget buildTopBar(BuildContext context, Color color) {
//     return Row(
//       children: [
//         Container(
//           child: IconButton(
//             padding: EdgeInsets.zero,
//             icon: Icon(Icons.arrow_back_ios, size: 20),
//             onPressed: () => Navigator.of(context).pop(),
//             color: color,
//             tooltip: "返回",
//           ),
//         ),
//         Expanded(
//           child: Text(
//             '${searchItem.origin} - ${searchItem.name}',
//             style: TextStyle(color: color),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//             textAlign: TextAlign.center,
//           ),
//         ),
//         Container(
//           width: 50,
//           child: IconButton(
//             padding: EdgeInsets.zero,
//             onPressed: null,
//             color: color,
//             icon: Icon(Icons.file_download),
//           ),
//         ),
//       ],
//     );
//   }
// }
