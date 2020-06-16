import 'package:flutter/material.dart';

/// 支持设置大小和背景色的 Bar
class SizedBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget child;
  final Color color;
  final double width, height;
  final BoxConstraints constraints;
  final Decoration decoration;

  const SizedBar({Key key, this.color, this.width = double.infinity, this.height = 50.0, this.constraints, this.decoration, this.child}): super(key: key);

  @override
  State<StatefulWidget> createState() => _SizedBarState();

  @override
  Size get preferredSize {
    if (child is PreferredSizeWidget) {
      return (child as PreferredSizeWidget).preferredSize;
    } else
      return Size(width, height);
  }
}

class _SizedBarState extends State<SizedBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      width: widget.width,
      height: widget.height,
      constraints: widget.constraints,
      decoration: widget.decoration,
      child: widget.child,
    );
  }
}
