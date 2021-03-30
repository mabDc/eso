// import 'package:eso/profile.dart';
// import 'package:flutter/material.dart';

// class UIChapterSeparate extends StatelessWidget {
//   final Color color;
//   final bool isLastChapter;
//   final bool isLoading;
//   final String chapterName;
//   const UIChapterSeparate({
//     this.color,
//     this.chapterName,
//     this.isLastChapter,
//     this.isLoading,
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.topLeft,
//       padding: EdgeInsets.only(
//         top: 100,
//         left: 32,
//         right: 10,
//         bottom: MediaQuery.of(context).size.height - 220,
//       ),
//       child: Text(
//         "当前章节\n$chapterName\n\n" +
//             (isLastChapter ? "已经是最后一章" : isLoading ? "正在加载..." : "继续滑动加载下一章"),
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           fontFamily: Profile.staticFontFamily,
//           height: 2,
//           color: color,
//         ),
//       ),
//     );
//   }
// }
