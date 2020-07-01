import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String text;
  final Icon icon;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final TextStyle style;
  final int maxLines;
  final bool softWrap;
  final TextOverflow overflow;
  const IconText(this.text,
      {Key key,
      this.icon,
      this.iconSize,
      this.style,
      this.maxLines,
      this.softWrap,
      this.padding,
      this.overflow = TextOverflow.ellipsis})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? Text(text ?? '', style: style)
        : text == null || text.isEmpty
            ? icon
            : RichText(
                text: TextSpan(style: style, children: [
                  WidgetSpan(
                      child: IconTheme(
                    data: IconThemeData(
                        size: iconSize ??
                            (style == null || style.fontSize == null
                                ? 16
                                : style.fontSize + 1),
                        color: style == null ? null : style.color),
                    child: padding == null ? icon : Padding(
                      padding: padding,
                      child: icon,
                    ),
                  )),
                  TextSpan(text: text),
                ]),
                maxLines: maxLines,
                softWrap: softWrap ?? true,
                overflow: overflow ?? TextOverflow.clip,
              );
  }
}
