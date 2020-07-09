import 'package:eso/model/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {

  const BottomBarButton({Key key, this.child, this.icon, this.color, this.splashColor, this.selected = false, VoidCallback onTap, VoidCallback onPressed}) :
        onPressed = onPressed ?? onTap,
        super(key: key);

  final VoidCallback onPressed;
  final Color splashColor;
  final Widget child;
  final Color color;
  final Icon icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final _color = color ?? selected ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    return ButtonTheme(
      minWidth: 40,
      child: FlatButton(
        splashColor: splashColor,
        highlightColor: Colors.transparent,
        padding: const EdgeInsets.all(8),
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
              style: TextStyle(fontSize: 14, color: _color, fontFamily: Profile.fontFamily),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}