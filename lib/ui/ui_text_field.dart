import 'dart:ui';
import 'package:eso/fonticons_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 搜索框
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
    return TextField(
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
              child: Icon(Icons.clear, color: Theme.of(context).dividerColor, size: 14.0),
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
    );
  }
}

// class FieldRightPopupMenu extends StatelessWidget {
//   final Widget child;
//   final TextEditingController controller;
//   const FieldRightPopupMenu({
//     this.controller,
//     this.child,
//     Key key,
//   }) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     if (!Global.isDesktop) return child;
//     const COPY = 0;
//     const CUT = 1;
//     const PASTE = 2;
//     const ALL = 3;
//     const CLEAR = 4;

//     return GestureDetector(
//       child: child,
//       onSecondaryTapDown: (v) {
//         // if (v.kind != PointerDeviceKind.mouse) return;
//         final _sel = controller.selection;
//         showMenu<int>(
//           context: context,
//           position: RelativeRect.fromLTRB(
//             v.globalPosition.dx,
//             v.globalPosition.dy,
//             v.globalPosition.dx + 60,
//             0,
//           ),
//           items: [
//             {'title': '复制', 'type': COPY},
//             {'title': '剪切', 'type': CUT},
//             {'title': '粘贴', 'type': PASTE},
//             {'title': '全选', 'type': ALL},
//             {'title': '清空', 'type': CLEAR},
//           ]
//               .map((e) => PopupMenuItem<int>(
//                     child: Text(e['title']),
//                     value: e['type'],
//                   ))
//               .toList(),
//         ).then((int value) async {
//           if (value == null) {
//             controller.selection = _sel;
//             return;
//           }
//           switch (value) {
//             case COPY:
//               if (_sel != null && _sel.end > _sel.start) {
//                 final _data = controller.text.substring(_sel.start, _sel.end);
//                 Clipboard.setData(ClipboardData(text: _data));
//                 controller.selection = TextSelection.fromPosition(
//                     TextPosition(offset: _data.length + _sel.start));
//               }
//               break;
//             case PASTE:
//               final _data = await Clipboard.getData(Clipboard.kTextPlain);
//               if (_data != null && _sel != null) {
//                 controller.text = controller.text.substring(0, _sel.start) +
//                     _data.text +
//                     controller.text.substring(_sel.end);
//                 controller.selection = TextSelection.fromPosition(
//                     TextPosition(offset: _data.text.length + _sel.start));
//               }
//               break;
//             case ALL:
//               controller.selection =
//                   TextSelection(baseOffset: 0, extentOffset: controller.text.length);
//               break;
//             case CUT:
//               if (_sel != null && _sel.end > _sel.start) {
//                 Clipboard.setData(
//                     ClipboardData(text: controller.text.substring(_sel.start, _sel.end)));
//                 controller.text = controller.text.substring(0, _sel.start) +
//                     controller.text.substring(_sel.end);
//                 controller.selection =
//                     TextSelection.fromPosition(TextPosition(offset: _sel.start));
//               }
//               break;
//             case CLEAR:
//               controller.text = "";
//               break;
//           }
//         });
//       },
//     );
//   }
// }
