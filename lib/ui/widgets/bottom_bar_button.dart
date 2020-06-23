import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {

  const BottomBarButton({Key key, this.child, this.icon, this.selected = false, this.onPressed}) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final Icon icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final _color = selected ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    return FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme(
            data: Theme.of(context).iconTheme.copyWith(color: _color, size: 22),
            child: icon,
          ),
          SizedBox(height: 2),
          DefaultTextStyle(
            style: TextStyle(fontSize: 12, color: _color),
            child: child,
          ),
        ],
      ),
    );
  }
}