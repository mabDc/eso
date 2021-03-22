// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:text_composition/curl.dart';
//
// import 'text_composition.dart';
//
// class PageTurn extends StatefulWidget {
//   PageTurn({
//     Key? key,
//     this.duration = const Duration(milliseconds: 300),
//     this.cuton = 8,
//     this.cutoff = 92,
//     this.backgroundColor = const Color(0xFFFFFFCC),
//     required this.textComposition,
//     this.initialIndex = 0,
//     this.lastPage = const Center(
//       child: const Text("已经是最后一页"),
//     ),
//     this.showDragCutoff = true,
//   }) : super(key: key);
//
//   final Color backgroundColor;
//   final TextComposition textComposition;
//   final Duration duration;
//   final int initialIndex;
//   final Widget? lastPage;
//   final bool showDragCutoff;
//   final int cutoff;
//   final int cuton;
//
//   @override
//   PageTurnState createState() => PageTurnState();
// }
//
// class PageTurnState extends State<PageTurn> with TickerProviderStateMixin {
//   int pageNumber = 0;
//   List<Widget> pages = [];
//
//   List<AnimationController> _controllers = [];
//   bool? _isForward;
//
//   @override
//   void didUpdateWidget(PageTurn oldWidget) {
//     if (oldWidget.textComposition != widget.textComposition) {
//       _setUp();
//     }
//     if (oldWidget.duration != widget.duration) {
//       _setUp();
//     }
//     if (oldWidget.backgroundColor != widget.backgroundColor) {
//       _setUp();
//     }
//     super.didUpdateWidget(oldWidget);
//   }
//
//   @override
//   void dispose() {
//     _controllers.forEach((c) => c.dispose());
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _setUp();
//   }
//
//   void _setUp() {
//     _controllers.clear();
//     pages.clear();
//
//     for (var i = 0; i < widget.textComposition.pageCount; i++) {
//       final _controller = AnimationController(
//         value: 1,
//         duration: widget.duration,
//         vsync: this,
//       );
//       _controllers.add(_controller);
//       var _child = CustomPaint(
//         painter: PageTurnEffectWithTextPage(
//           amount: _controller,
//           backgroundColor: widget.backgroundColor,
//           pageIndex: i,
//           page: widget.textComposition.pages[i],
//           style: widget.textComposition.style,
//           titleStyle: widget.textComposition.titleStyle,
//         ),
//       );
//       pages.add(_child);
//     }
//     pages = pages.reversed.toList();
//     pageNumber = widget.initialIndex;
//   }
//
//   bool get _isLastPage => pages.length - 1 == pageNumber;
//
//   bool get _isFirstPage => pageNumber == 0;
//
//   void _turnPage(DragUpdateDetails details, BoxConstraints dimens) {
//     final _ratio = details.delta.dx / dimens.maxWidth;
//     if (_isForward == null) {
//       if (details.delta.dx > 0) {
//         _isForward = false;
//       } else {
//         _isForward = true;
//       }
//     }
//     if (_isForward!) {
//       _controllers[pageNumber].value += _ratio;
//     } else {
//       _controllers[pageNumber - 1].value += _ratio;
//     }
//   }
//
//   Future<void> _onDragFinish() async {
//     if (_isForward != null) {
//       if (_isForward!) {
//         if (!_isLastPage &&
//             _controllers[pageNumber].value <= (widget.cutoff / 100 + 0.03)) {
//           await nextPage();
//         } else {
//           await _controllers[pageNumber].forward();
//         }
//       } else {
//         if (!_isFirstPage &&
//             _controllers[pageNumber - 1].value >= (widget.cuton / 100 + 0.05)) {
//           await previousPage();
//         } else {
//           if (_isFirstPage) {
//             await _controllers[pageNumber].forward();
//           } else {
//             await _controllers[pageNumber - 1].reverse();
//           }
//         }
//       }
//     }
//     _isForward = null;
//   }
//
//   Future<void> nextPage() async {
//     if (_isLastPage) return;
//     if (widget.textComposition.showAnimation)
//       _controllers[pageNumber].reverse();
//     else
//       _controllers[pageNumber].value = 0;
//     if (mounted)
//       setState(() {
//         pageNumber++;
//       });
//   }
//
//   Future<void> previousPage() async {
//     if (_isFirstPage) return;
//     if (widget.textComposition.showAnimation)
//       _controllers[pageNumber - 1].forward();
//     else
//       _controllers[pageNumber - 1].value = 1;
//     if (mounted)
//       setState(() {
//         pageNumber--;
//       });
//   }
//
//   Future<void> goToPage(int index) async {
//     if (mounted) {
//       if (index > pageNumber) {
//         _controllers[index - 1].reverse();
//       } else {
//         _controllers[index].forward();
//       }
//       setState(() {
//         pageNumber = index;
//       });
//       for (var i = 0; i < _controllers.length; i++) {
//         if (i < index - 1) {
//           _controllers[i].value = 0;
//         } else if (i > index) {
//           _controllers[i].value = 1;
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int i = 0;
//     return Material(
//       child: LayoutBuilder(
//         builder: (context, dimens) => RawKeyboardListener(
//           focusNode: new FocusNode(),
//           autofocus: true,
//           onKey: (event) {
//             if (event.runtimeType.toString() == 'RawKeyUpEvent') return;
//             if (event.data is RawKeyEventDataMacOs ||
//                 event.data is RawKeyEventDataLinux ||
//                 event.data is RawKeyEventDataWindows) {
//               final logicalKey = event.data.logicalKey;
//               print(logicalKey);
//               if (logicalKey == LogicalKeyboardKey.arrowUp) {
//                 previousPage();
//               } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
//                 previousPage();
//               } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
//                 nextPage();
//               } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
//                 nextPage();
//               } else if (logicalKey == LogicalKeyboardKey.home) {
//                 goToPage(0);
//               } else if (logicalKey == LogicalKeyboardKey.end) {
//                 goToPage(pages.length - 1);
//               } else if (logicalKey == LogicalKeyboardKey.enter ||
//                   logicalKey == LogicalKeyboardKey.numpadEnter) {
//                 //
//               } else if (logicalKey == LogicalKeyboardKey.escape) {
//                 Navigator.of(context).pop();
//               }
//             }
//           },
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onHorizontalDragCancel: () => _isForward = null,
//             onHorizontalDragUpdate: (details) => _turnPage(details, dimens),
//             onHorizontalDragEnd: (details) => _onDragFinish(),
//             child: Stack(
//               fit: StackFit.expand,
//               children: <Widget>[
//                 if (widget.lastPage != null) widget.lastPage!,
//                 ...pages.map((p) {
//                   i++;
//                   final pn = pages.length - pageNumber;
//                   final ret = Offstage(
//                       offstage: !(i >= pn - 2 && i <= pn + 1), child: p);
//                   return ret;
//                 }).toList(),
//                 Positioned.fill(
//                   child: Flex(
//                     direction: Axis.horizontal,
//                     children: <Widget>[
//                       Flexible(
//                         flex: 50 - widget.cuton,
//                         child: GestureDetector(
//                           behavior: HitTestBehavior.opaque,
//                           onTap: previousPage,
//                         ),
//                       ),
//                       Flexible(
//                         flex: widget.cutoff - 50,
//                         child: GestureDetector(
//                           behavior: HitTestBehavior.opaque,
//                           onTap: nextPage,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
