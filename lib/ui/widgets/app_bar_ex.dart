import 'package:eso/fonticons_icons.dart';
import 'package:eso/ui/widgets/app_bar_button.dart';
import 'package:flutter/material.dart';

/// 扩展一个 AppBar 方便自定义
class AppBarEx extends StatelessWidget implements PreferredSizeWidget {
  AppBarEx({
    Key key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shape,
    this.backgroundColor,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  }) : assert(automaticallyImplyLeading != null),
        assert(elevation == null || elevation >= 0.0),
        assert(primary != null),
        assert(titleSpacing != null),
        assert(toolbarOpacity != null),
        assert(bottomOpacity != null),
        preferredSize = Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);

  final Color backgroundColor;
  final Widget leading;
  final Widget title;
  final List<Widget> actions;
  final PreferredSizeWidget bottom;
  final double elevation;
  final ShapeBorder shape;
  final Brightness brightness;
  final IconThemeData iconTheme;
  final IconThemeData actionsIconTheme;
  final TextTheme textTheme;
  final bool primary;
  final bool centerTitle;
  final double titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final Widget flexibleSpace;
  final bool automaticallyImplyLeading;
  final bool excludeHeaderSemantics;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ?? buildLeading(context),
      title: title,
      backgroundColor: backgroundColor,
      actions: actions ?? <Widget>[],
      bottom: bottom,
      elevation: elevation,
      shape: shape,
      brightness: brightness,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      textTheme: textTheme,
      primary: primary,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      flexibleSpace: flexibleSpace,
      excludeHeaderSemantics: excludeHeaderSemantics,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  static Widget buildLeading(BuildContext context, {Color color, VoidCallback onPressed}) {
    final bool canPop = ModalRoute
        .of(context)
        ?.canPop ?? false;
    return canPop ? AppBarButton(
      icon: Icon(FIcons.chevron_left, color: color),
      tooltip: MaterialLocalizations
          .of(context)
          .backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    ) : null;
  }
}