import 'dart:ui';
import 'package:eso/fonticons_icons.dart';
import 'package:flutter/material.dart';

/// 搜索框
class SearchEdit extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  const SearchEdit({Key key, this.controller,
    this.hintText,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.onChanged,
    this.onSubmitted}): super(key: key);


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).primaryColor,
      cursorRadius: Radius.circular(2),
      selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).primaryColorDark.withOpacity(0.06), // Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
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
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 6),
          child: Icon(
            FIcons.search,
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
          ),
        ),
        prefixIconConstraints: BoxConstraints(),
      ),
      maxLines: 1,
      autofocus: autofocus,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyText1.color,
      ),
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}