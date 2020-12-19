import 'dart:ui';
import 'package:eso/fonticons_icons.dart';
import 'package:eso/menu/menu_right.dart';
import 'package:eso/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final FocusNode focusNode;
  final Widget prefix;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  const SearchTextField({
    Key key,
    this.controller,
    this.hintText,
    this.autofocus = false,
    this.prefix,
    this.focusNode,
    this.textInputAction = TextInputAction.search,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller != null && onChanged != null) {
      controller.addListener(() => onChanged(controller.text));
    }
    return FieldRightPopupMenu(
      controller: controller,
      child: TextField(
        controller: controller,
        cursorColor: Theme.of(context).primaryColor,
        cursorRadius: Radius.circular(2),
        selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
        focusNode: focusNode,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).primaryColorDark.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5),
            fontSize: 13,
          ),
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 7, top: 7),
          prefixIcon: prefix ??
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Icon(
                  FIcons.search,
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
                ),
              ),
          prefixIconConstraints: BoxConstraints(),
          suffixIconConstraints: BoxConstraints(maxHeight: 24),
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(4, 1, 8, 1),
            child: InkWell(
              child: Container(
                width: 16.0,
                height: 16.0,
                child:
                    Icon(Icons.clear, color: Theme.of(context).dividerColor, size: 14.0),
              ),
              onTap: () {
                controller.text = '';
              },
            ),
          ),
        ),
        maxLines: 1,
        autofocus: autofocus,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyText1.color,
        ),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
      ),
    );
  }
}

class FieldRightPopupMenu extends StatelessWidget {
  final Widget child;
  final TextEditingController controller;
  const FieldRightPopupMenu({
    this.controller,
    this.child,
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!Global.isDesktop) return child;
    return Menu<MenuRight>(
      child: child,
      onSecondaryTapDown: true,
      items: rightMenus,
      onSelect: (value) async {
        final _sel = controller.selection;
        switch (value) {
          case MenuRight.copy:
            if (_sel != null && _sel.end > _sel.start) {
              final _data = controller.text.substring(_sel.start, _sel.end);
              Clipboard.setData(ClipboardData(text: _data));
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _data.length + _sel.start));
            }
            break;
          case MenuRight.paste:
            final _data = await Clipboard.getData(Clipboard.kTextPlain);
            if (_data != null && _sel != null) {
              controller.text = controller.text.substring(0, _sel.start) +
                  _data.text +
                  controller.text.substring(_sel.end);
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _data.text.length + _sel.start));
            }
            break;
          case MenuRight.all:
            controller.selection =
                TextSelection(baseOffset: 0, extentOffset: controller.text.length);
            break;
          case MenuRight.cut:
            if (_sel != null && _sel.end > _sel.start) {
              Clipboard.setData(
                  ClipboardData(text: controller.text.substring(_sel.start, _sel.end)));
              controller.text = controller.text.substring(0, _sel.start) +
                  controller.text.substring(_sel.end);
              controller.selection =
                  TextSelection.fromPosition(TextPosition(offset: _sel.start));
            }
            break;
          case MenuRight.clear:
            controller.text = "";
            break;
          default:
            controller.selection = _sel;
            break;
        }
      },
    );
  }
}
