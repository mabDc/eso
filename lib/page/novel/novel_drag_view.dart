import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/profile.dart';
import 'package:flutter/cupertino.dart';

/// 文字阅读 手势处理
class NovelDragView extends StatelessWidget {
  final Widget child;
  final NovelPageProvider provider;
  final Profile profile;

  const NovelDragView({Key key, this.provider, this.profile, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
        onHorizontalDragEnd: (DragEndDetails details) {
          // print("onHorizontalDragEnd");
          if (details.primaryVelocity.abs() > 100) {
            if (provider.showSetting) {
              provider.showSetting = false;
            } else if (provider.showMenu) {
              provider.showMenu = false;
            } else {
              if (details.primaryVelocity > 0) {
                provider.tapLastPage();
              } else {
                provider.tapNextPage();
              }
            }
          }
        },
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity.abs() > 100) {
            if (provider.showSetting) {
              provider.showSetting = false;
            } else if (provider.showMenu) {
              provider.showMenu = false;
            } else {
              if (details.primaryVelocity > 0) {
                provider.tapLastPage();
              } else {
                provider.tapNextPage();
              }
            }
          }
        }
    );
  }
}