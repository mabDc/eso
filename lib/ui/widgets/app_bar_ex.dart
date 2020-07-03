import 'package:eso/fonticons_icons.dart';
import 'package:eso/ui/widgets/app_bar_button.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

/// 扩展一个 AppBar 方便自定义
class AppBarEx extends StatelessWidget implements PreferredSizeWidget {
  AppBarEx({
    Key key,
    this.leading,
    this.automaticallyImplyLeading = true,
    Widget title,
    String titleText,
    String subTitleText,
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
    this.titleSpacing = 0, //NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  })  : assert(automaticallyImplyLeading != null),
        assert(elevation == null || elevation >= 0.0),
        assert(primary != null),
        assert(titleSpacing != null),
        assert(toolbarOpacity != null),
        assert(bottomOpacity != null),
        title = title ?? buildTitle(title: titleText, subTitle: subTitleText),
        preferredSize =
            Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
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

  static Widget buildLeading(BuildContext context,
      {Color color, VoidCallback onPressed}) {
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    return canPop
        ? AppBarButton(
            icon: Icon(FIcons.chevron_left, color: color),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            iconSize: 24,
            onPressed: onPressed ?? () => Navigator.maybePop(context),
          )
        : null;
  }

  static Widget buildTitle(
      {String title,
      String subTitle,
      Color color,
      CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    final _subTitle = Utils.empty(subTitle)
        ? null
        : Text(
            subTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: color),
          );
    final _title = Utils.empty(title)
        ? null
        : Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: color, fontSize: 18),
          );
    if (_subTitle == null) return _title;
    if (_title == null) return _subTitle;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment ?? CrossAxisAlignment.start,
      children: [
        _title,
        _subTitle,
      ],
    );
  }
}
