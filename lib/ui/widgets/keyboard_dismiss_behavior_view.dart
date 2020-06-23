import 'package:flutter/cupertino.dart';

/// 滚动时隐藏软键盘
class KeyboardDismissBehaviorView extends StatelessWidget {
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Widget child;
  const KeyboardDismissBehaviorView({Key key, this.child, this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag}): super(key: key);

  @override
  Widget build(BuildContext context) {
    if (keyboardDismissBehavior == null || keyboardDismissBehavior != ScrollViewKeyboardDismissBehavior.onDrag)
      return child ?? SizedBox();
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification ntf) {
        final FocusScopeNode focusScope = FocusScope.of(context);
        if (ntf is ScrollUpdateNotification && ntf.dragDetails != null && focusScope.hasFocus) {
          focusScope.unfocus();
          return false;
        }
        return true;
      },
      child: child,
    );
  }
}