// import 'dart:math';
// import 'dart:ui';
// import 'package:eso/database/chapter_item.dart';
// import 'package:eso/menu/menu.dart';
// import 'package:eso/menu/menu_chapter.dart';
// import 'package:eso/profile.dart';
// import 'package:eso/page/photo_view_page.dart';
// import 'package:text_composition/text_composition.dart';
// import 'package:eso/ui/ui_image_item.dart';
// import 'package:eso/utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
// import '../database/search_item_manager.dart';
// import '../database/search_item.dart';
// import '../model/chapter_page_provider.dart';
// import 'content_page_manager.dart';
// import 'langding_page.dart';

// class ChapterPage extends StatefulWidget {
//   final SearchItem searchItem;
//   const ChapterPage({this.searchItem, Key key}) : super(key: key);

//   @override
//   _ChapterPageState createState() => _ChapterPageState();
// }

// class _ChapterPageState extends State<ChapterPage> {
//   ScrollController _controller;

//   @override
//   void initState() {
//     _controller = ScrollController();
//     _controller.addListener(() {
//       print(_controller.position.maxScrollExtent);
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final searchItem = widget.searchItem;
//     return Material(
//       child: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           double w = constraints.maxWidth;
//           final shape = RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.elliptical(w / 2, 40),
//               topRight: Radius.elliptical(w / 2, 40),
//             ),
//           );
//           return DraggableScrollbar.rrect(
//             controller: _controller,
//             child: CustomScrollView(
//               controller: _controller,
//               slivers: <Widget>[
//                 SliverAppBar(
//                   actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {
//                     Navigator.of(context)
//                         .push(ContentPageRoute().route(searchItem));
//                   })],
//                   // title: Text(searchItem.origin),
//                   flexibleSpace: FlexibleSpaceBar(
//                     titlePadding: EdgeInsets.zero,
//                     title: Container(
//                       clipBehavior: Clip.antiAlias,
//                       child: Material(
//                         color: Theme.of(context).canvasColor,
//                         child: Center(child: Text(searchItem.name)),
//                       ),
//                       decoration: ShapeDecoration(shape: shape),
//                       height: 40,
//                     ),
//                     background: ArcBannerImage(
//                       searchItem.cover,
//                       height: 300,
//                       hero: '${searchItem.name}.${searchItem.cover}.${searchItem.id}',
//                     ),
//                   ),
//                   expandedHeight: 300,
//                   pinned: true,
//                   collapsedHeight: 40,
//                   toolbarHeight: 40,
//                 ),
//                 SliverToBoxAdapter(
//                   child: _buildDescription(w),
//                 ),
//                 SliverFixedExtentList(
//                   itemExtent: 100,
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) => Container(
//                       height: 100,
//                       child: Text("$index"),
//                     ),
//                     childCount: 10,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDescription(double w) {
//     return TextCompositionWidget(
//       paragraphs: widget.searchItem.description
//           .split(RegExp(r"^\s*|(\s{2,}|\n)\s*"))
//           .map((s) => s.trimLeft())
//           .toList(),
//       config: TextCompositionConfig(
//         fontSize: 12,
//         paragraphPadding: 8,
//         fontFamily: Profile.staticFontFamily,
//         fontColor: Theme.of(context).textTheme.headline6.color,
//       ),
//       width: w,
//     );
//   }
// }

// class ArcBannerImage extends StatelessWidget {
//   const ArcBannerImage(this.imageUrl, {this.hero, this.arcH = 30.0, this.height = 350.0});
//   final String imageUrl;
//   final double height, arcH;
//   final String hero;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: AlignmentDirectional.topCenter,
//       children: [
//         SizedBox(
//           width: double.infinity,
//           height: height,
//           child: UIImageItem(cover: imageUrl, radius: null, fit: BoxFit.cover),
//         ),
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//           child: Container(
//             color: Theme.of(context).bottomAppBarColor.withOpacity(0.8),
//             height: height,
//           ),
//         ),
//         Container(
//           height: height - 100,
//           margin: EdgeInsets.only(top: 20),
//           child: InkWell(
//             onTap: () => Utils.startPageWait(
//               context,
//               PhotoViewPage(
//                 items: [PhotoItem(imageUrl)],
//                 heroTag: hero,
//               ),
//             ),
//             child: UIImageItem(
//               cover: imageUrl,
//               initHeight: height - 100,
//               fit: BoxFit.cover,
//               hero: hero,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
