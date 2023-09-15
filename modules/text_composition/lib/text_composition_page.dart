import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'text_composition.dart';

class TextCompositionPage extends StatefulWidget {
  TextCompositionPage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextComposition controller;

  @override
  TextCompositionPageState createState() => TextCompositionPageState();
}

class TextCompositionPageState extends State<TextCompositionPage>
    with TickerProviderStateMixin {
  @override
  void didUpdateWidget(TextCompositionPage oldWidget) {
    if (!identical(oldWidget.controller, widget.controller)) setUp();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(refresh);
    widget.controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  setUp() {
    if (!widget.controller.config.showStatus)
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    widget.controller.addListener(refresh);
    widget.controller.init((_controllers) {
      if (_controllers.length == TextComposition.TOTAL) return;
      for (var i = 0, len = TextComposition.TOTAL; i < len; i++) {
        _controllers.add(AnimationController(
          value: 1,
          duration: widget.controller.duration,
          vsync: this,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorStyle = TextStyle(color: widget.controller.config.fontColor);
    return Material(
      child: LayoutBuilder(
        builder: (context, dimens) => RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (widget.controller.isShowMenu) return;
            if (event.runtimeType.toString() == 'RawKeyUpEvent') return;
            if (event.data is RawKeyEventDataMacOs ||
                event.data is RawKeyEventDataLinux ||
                event.data is RawKeyEventDataWindows) {
              final logicalKey = event.data.logicalKey;
              print(logicalKey);
              if (logicalKey == LogicalKeyboardKey.arrowUp) {
                widget.controller.previousPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
                widget.controller.previousPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
                widget.controller.nextPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
                widget.controller.nextPage();
              } else if (logicalKey == LogicalKeyboardKey.home) {
                widget.controller.goToPage(widget.controller.firstIndex);
              } else if (logicalKey == LogicalKeyboardKey.end) {
                widget.controller.goToPage(widget.controller.lastIndex);
              } else if (logicalKey == LogicalKeyboardKey.enter ||
                  logicalKey == LogicalKeyboardKey.numpadEnter) {
                widget.controller.toggleMenuDialog(context);
              } else if (logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              }
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragCancel: () => widget.controller.isForward = null,
            onHorizontalDragUpdate: (details) =>
                widget.controller.turnPage(details, dimens, vertical: false),
            onHorizontalDragEnd: (details) => widget.controller.onDragFinish(),
            onVerticalDragCancel: () => widget.controller.isForward = null,
            onVerticalDragUpdate: (details) =>
                widget.controller.turnPage(details, dimens, vertical: true),
            onVerticalDragEnd: (details) => widget.controller.onDragFinish(),
            onTapUp: (details) {
              final size = MediaQuery.of(context).size;
              if (details.globalPosition.dx > size.width * 3 / 8 &&
                  details.globalPosition.dx < size.width * 5 / 8 &&
                  details.globalPosition.dy > size.height * 3 / 8 &&
                  details.globalPosition.dy < size.height * 5 / 8) {
                widget.controller.toggleMenuDialog(context);
              } else {
                if (widget.controller.isShowMenu) return;
                if (details.globalPosition.dx < size.width / 2) {
                  if (widget.controller.config.oneHand) {
                    widget.controller.nextPage();
                  } else {
                    widget.controller.previousPage();
                  }
                } else {
                  widget.controller.nextPage();
                }
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  decoration: getDecoration(
                    widget.controller.config.background,
                    widget.controller.config.backgroundColor,
                  ),
                  // color: widget.controller.config.backgroundColor,
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.controller.name ?? ""),
                      SizedBox(height: 10),
                      Text("这是底线（最后一页）", style: colorStyle),
                      SizedBox(height: 10),
                      Text("已读完", style: colorStyle),
                    ],
                  ),
                ),
                ...widget.controller.pages,
                if (widget.controller.isShowMenu && widget.controller.menuBuilder != null)
                  widget.controller.menuBuilder!(widget.controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
