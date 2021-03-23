// import 'package:eso/database/search_item.dart';
// import 'package:eso/model/novel_page_provider.dart';
// import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class NovelAutoCachePage extends StatelessWidget {
//   final SearchItem searchItem;
//   final NovelPageProvider provider;
//
//   const NovelAutoCachePage({
//     Key key,
//     @required this.searchItem,
//     @required this.provider,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final scrollController = ScrollController();
//     final chapters = searchItem.chapters;
//     final cacheIndex = provider.cacheChapterIndex;
//     const cacheText = const Text("已缓存", style: TextStyle(color: Colors.green));
//     const noCacheText = const Text("未缓存", style: TextStyle(color: Colors.grey));
//     return ChangeNotifierProvider<NovelPageProvider>.value(
//       value: provider,
//       child: Consumer<NovelPageProvider>(
//         builder: (context, provider, _) => Scaffold(
//           appBar: AppBar(
//             titleSpacing: 0,
//             title: Text(
//               '${searchItem.origin} - ${searchItem.name}',
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14),
//             ),
//             actions: [
//               IconButton(
//                 onPressed: () => provider.exportCache(isShare: true),
//                 icon: Icon(Icons.share),
//                 tooltip: "导出并分享已缓存章节",
//               ),
//               IconButton(
//                 onPressed: () => provider.exportCache(isSaveLocal: true),
//                 icon: Icon(Icons.exit_to_app),
//                 tooltip: "导出已缓存章节",
//               ),
//               IconButton(
//                 onPressed: provider.toggleAutoCache,
//                 icon: Icon(provider.autoCacheDoing ? Icons.stop : Icons.play_arrow),
//                 tooltip: provider.autoCacheDoing ? "取消缓存" : "开始缓存",
//               ),
//             ],
//           ),
//           body: Container(
//             padding: EdgeInsets.all(2),
//             child: DraggableScrollbar.semicircle(
//               controller: scrollController,
//               labelTextBuilder: (double offset) => Text("${offset ~/ 30 + 1}"),
//               child: ListView.builder(
//                 controller: scrollController,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 cacheExtent: 30,
//                 itemCount: searchItem.chaptersCount + 1,
//                 itemBuilder: (BuildContext context, int i) {
//                   if (i == 0) {
//                     return TextField(
//                       maxLines: 10,
//                       minLines: 1,
//                       controller: provider.exportChapterName,
//                       decoration: InputDecoration(
//                         hintText: "序号(\$index) 名称(\$name) 可空",
//                         labelText: "自定义导出章节名格式",
//                       ),
//                       autofocus: false,
//                     );
//                   }
//                   final index = i - 1;
//                   return Container(
//                     height: 30,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             chapters[index].name ?? 0,
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                         cacheIndex.contains(index) ? cacheText : noCacheText,
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
