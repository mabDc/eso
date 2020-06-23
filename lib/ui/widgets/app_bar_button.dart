import 'package:eso/fonticons_icons.dart';
import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const AppBarButton({Key key, Widget child, Widget icon, this.color, this.tooltip, this.onPressed}):
      child = child ?? icon,
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: Theme.of(context).appBarTheme.iconTheme.size,
      icon: child,
      tooltip: tooltip,
      color: color,
      onPressed: onPressed,
    );
  }
}
