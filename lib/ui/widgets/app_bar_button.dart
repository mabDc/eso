import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final double iconSize;
  final String tooltip;
  final double minWidth;
  final VoidCallback onPressed;

  const AppBarButton({Key key, Widget child, Widget icon, this.color, this.iconSize, this.tooltip, this.minWidth, VoidCallback onPressed, VoidCallback onTap}):
      child = child ?? icon,
      onPressed = onPressed ?? onTap,
      super(key: key);

  @override
  Widget build(BuildContext context) {
    final _btn = IconButton(
      iconSize: iconSize ?? Theme.of(context).appBarTheme.iconTheme.size,
      icon: child,
      tooltip: tooltip,
      color: color,
      onPressed: onPressed,
    );
    return minWidth == null ? _btn : ButtonTheme(
      minWidth: minWidth,
      child: _btn,
    );
  }
}
