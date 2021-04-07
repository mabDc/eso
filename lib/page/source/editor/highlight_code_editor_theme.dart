import 'package:flutter/material.dart';

const FontWeight fontWeight = FontWeight.w400;

// HTML
const Color tagColor = Color(0xFFF79AA5); // tag
const Color quoteColor = Color(0xFF6CD07A); // ""

// CSS
const Color attrColor = Color(0xFFCBBA7D); // CSS selectors
const Color propertyColor = Color(0xFF8CDCFE); // property
const Color idColor = Color(0xFFCBBA7D);
const Color classColor = Color(0xFFCBBA7D);

// JS
const Color keywordColor = Color(0xFF3E9CD6); // keywords (function, ...)
const Color methodsColor = Color(0xFFDCDC9D); // methods built in
const Color titlesColor = Color(0xFFDCDC9D); // titles (function's title)

/// The theme used by code_editor and created by code_editor. This is the default theme of the editor.
///
/// You can create your own or use
/// others themes by looking at :
///
/// `import 'package:flutter_highlight/themes/'`.
const myTheme = {
  'root': TextStyle(
    backgroundColor: Color(0xff2E3152),
    color: Color(0xffdddddd),
  ),
  'keyword': TextStyle(color: keywordColor),
  'params': TextStyle(color: Color(0xffde935f)),
  'selector-tag': TextStyle(color: attrColor),
  'selector-id': TextStyle(color: idColor),
  'selector-class': TextStyle(color: classColor),
  'regexp': TextStyle(color: Color(0xffcc6666)),
  'literal': TextStyle(color: Colors.white),
  'section': TextStyle(color: Colors.white),
  'link': TextStyle(color: Colors.white),
  'subst': TextStyle(color: Color(0xffdddddd)),
  'string': TextStyle(color: quoteColor),
  'title': TextStyle(color: titlesColor),
  'name': TextStyle(color: tagColor),
  'type': TextStyle(color: tagColor),
  'attribute': TextStyle(color: propertyColor),
  'symbol': TextStyle(color: tagColor),
  'bullet': TextStyle(color: tagColor),
  'built_in': TextStyle(color: methodsColor),
  'addition': TextStyle(color: tagColor),
  'variable': TextStyle(color: tagColor),
  'template-tag': TextStyle(color: tagColor),
  'template-variable': TextStyle(color: tagColor),
  'comment': TextStyle(color: Color(0xff777777)),
  'quote': TextStyle(color: Color(0xff777777)),
  'deletion': TextStyle(color: Color(0xff777777)),
  'meta': TextStyle(color: Color(0xff777777)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
};
