// import 'package:flutter/material.dart';
// import '../model/history_manager.dart';
// import '../page/search_result_page.dart';

// class SearchPageDelegate extends SearchDelegate<String> {
//   final HistoryManager historyManager;
//   SearchPageDelegate({this.historyManager})
//       : super(
//           searchFieldLabel: "请输入关键词",
//           keyboardType: TextInputType.text,
//           textInputAction: TextInputAction.search,
//         );

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     final theme = Theme.of(context);
//     return theme.copyWith(
//       primaryColor: Colors.white,
//       primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.black54),
//       inputDecorationTheme:
//       InputDecorationTheme(hintStyle: TextStyle(color: Colors.black54)),
//       textTheme: theme.textTheme.apply(bodyColor: Colors.black87),
//     );
//   }
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: AnimatedIcon(
//         icon: AnimatedIcons.menu_arrow,
//         progress: transitionAnimation,
//       ),
//       onPressed: () {
//         if (query.isEmpty) {
//           close(context, "from search");
//         } else {
//           query = "";
//           showSuggestions(context);
//         }
//       },
//     );
//   }
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     if (query.isEmpty) {
//       return <Widget>[];
//     } else {
//       return <Widget>[
//         IconButton(
//           icon: Icon(Icons.clear),
//           onPressed: () {
//             query = "";
//             showSuggestions(context);
//           },
//         ),
//       ];
//     }
//   }
//   @override
//   Widget buildResults(BuildContext context) {
//     query = query.trim();
//     if (!historyManager.searchHistory.contains(query)) {
//       historyManager.newSearch(query);
//     }
//     return SearchResultPage(query: query);
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 8),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(
//             height: 50,
//             child: Row(
//               children: <Widget>[
//                 Expanded(child: Text("搜索历史")),
//                 IconButton(
//                   icon: Icon(Icons.delete_sweep),
//                   onPressed: () {
//                     (() async {
//                       await historyManager.clearHistory();
//                       query = query;
//                       showSuggestions(context);
//                     })();
//                   },
//                 )
//               ],
//             ),
//           ),
//           Wrap(
//               spacing: 8,
//               children: historyManager.searchHistory
//                   .map((keyword) => RaisedButton(
//                         child: Text('$keyword'),
//                         onPressed: () {
//                           query = '$keyword';
//                           showResults(context);
//                         },
//                       ))
//                   .toList()),
//         ],
//       ),
//     );
//   }
// }
