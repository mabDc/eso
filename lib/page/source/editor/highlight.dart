/*
 * @Description: Code highlight controller
 * @Author: ekibun
 * @Date: 2020-08-01 17:42:06
 * @LastEditors: ekibun
 * @LastEditTime: 2020-08-02 12:39:26
 */
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';

import 'highlight_code_editor_theme.dart';

Map<String, TextStyle> theme = myTheme;

List<TextSpan> _convert(String code) {
  var nodes = highlight.parse(code, language: 'javascript').nodes;
  List<TextSpan> spans = [];
  var currentSpans = spans;
  List<List<TextSpan>> stack = [];

  _traverse(Node node) {
    if (node.value != null) {
      currentSpans.add(node.className == null
          ? TextSpan(text: node.value)
          : TextSpan(text: node.value, style: theme[node.className]));
    } else if (node.children != null) {
      List<TextSpan> tmp = [];
      currentSpans.add(TextSpan(children: tmp, style: theme[node.className]));
      stack.add(currentSpans);
      currentSpans = tmp;

      node.children?.forEach((n) {
        _traverse(n);
        if (n == node.children?.last) {
          currentSpans = stack.isEmpty ? spans : stack.removeLast();
        }
      });
    }
  }

  if (nodes != null) {
    for (var node in nodes) {
      _traverse(node);
    }
  }

  return spans;
}

class CodeInputController extends TextEditingController {
  CodeInputController({String text}) : super(text: text);

  TextSpan oldSpan = TextSpan();
  Future<void> spanCall;

  @override
  TextSpan buildTextSpan({ BuildContext context, TextStyle style, @required bool withComposing}) {
    String oldText = oldSpan.toPlainText();
    String newText = value.text;
    if (oldText == newText) return oldSpan;
    (spanCall?.timeout(Duration.zero) ?? Future.delayed(Duration.zero))
        .then((_) => spanCall = compute(_convert, value.text).then((lsSpan) {
              TextSpan newSpan = TextSpan(style: style, children: lsSpan);
              if (newSpan.toPlainText() == value.text) oldSpan = newSpan;
              notifyListeners();
            }))
        .catchError((_) => {});

    List<InlineSpan> beforeSpans = [];
    int splitAt = value.selection.start;
    if (splitAt < 0) splitAt = newText.length ~/ 2;
    int start = 0;
    InlineSpan leftSpan;
    oldSpan.children?.indexWhere((element) {
      String elementText = element.toPlainText();
      if (start + elementText.length > splitAt ||
          !newText.startsWith(elementText, start)) {
        leftSpan = element;
        return true;
      }
      beforeSpans.add(element);
      start += elementText.length;
      return false;
    });
    List<InlineSpan> endSpans = [];
    int end = 0;
    InlineSpan rightSpan;
    oldSpan.children?.sublist(beforeSpans.length)?.lastIndexWhere((element) {
      String elementText = element.toPlainText();
      if (splitAt + end + elementText.length >= newText.length ||
          !newText.substring(start, newText.length - end).endsWith(elementText)) {
        rightSpan = element;
        return true;
      }
      endSpans.add(element);
      end += elementText.length;
      return false;
    });

    return TextSpan(style: style, children: [
      ...beforeSpans,
      TextSpan(
          style: leftSpan != null && leftSpan == rightSpan ? leftSpan.style : style,
          text: newText.substring(start, max(start, newText.length - end))),
      ...endSpans.reversed
    ]);
  }
}
