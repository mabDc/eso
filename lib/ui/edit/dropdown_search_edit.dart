import 'dart:ui';
import 'package:flutter/material.dart';

/// 搜索框
class SearchEdit extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final FocusNode focusNote;
  final Widget prefix;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;


  const SearchEdit({Key key, this.controller,
    this.hintText,
    this.autofocus = false,
    this.prefix,
    this.focusNote,
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
      focusNode: focusNote,
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
        prefixIcon: prefix,
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