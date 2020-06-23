import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 扩展了功能的文本框
///
/// 支持一键清空
class EditView extends StatefulWidget {
  EditView({
    Key key,
    this.value,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.maxLines,
    this.border,
    this.focusedBorder,
    this.isRow = true,
    this.dense = false,
    this.textAlign,
    this.style,
    this.hintStyle,
    this.inputFormatters,
    this.textInputAction,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.suffix,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onFocusChanged,
    this.onSubmitted
  }): super(key: key);

  final String value;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final InputBorder border;
  final InputBorder focusedBorder;
  final bool isRow;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final TextStyle style, hintStyle;
  final Widget suffix;
  /// 密码框？
  final bool obscureText;
  final bool dense;
  final int maxLength;
  final TextAlign textAlign;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction textInputAction;
  final VoidCallback onEditingComplete;
  final ValueChanged<bool> onFocusChanged;
  final ValueChanged<String> onSubmitted;

  @override
  State<StatefulWidget> createState() {
    return _EditViewState();
  }
}

class _EditViewState extends State<EditView> {
  TextEditingController _controller;
  FocusNode _focusNode;
  VoidCallback _focusListener;
  var isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.value != null)
      _controller.text = widget.value;
    if (widget.value != null && widget.value.isNotEmpty) {
      _controller.selection = TextSelection(
        baseOffset: widget.value == null ? 0 : widget.value.length,
        extentOffset: widget.value == null ? 0 : widget.value.length,
      );
    }
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.onFocusChanged != null) {
      _focusListener = () {
        widget.onFocusChanged(_focusNode.hasFocus);
        // print("focus node listener： ${_focusNode.hasFocus}, text: ${_controller.text}");
      };
      _focusNode.addListener(_focusListener);
    }
  }

  @override
  void dispose() {
    if (_focusListener != null)
      _focusNode.removeListener(_focusListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(EditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
      // print("didUpdateWidget: " + widget.value);
      if (widget.value != null && widget.value.isNotEmpty) {
        _controller.selection = TextSelection(
          baseOffset: widget.value == null ? 0 : widget.value.length,
          extentOffset: widget.value == null ? 0 : widget.value.length,
        );
      }
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    isEmpty = _controller.text.isEmpty;
    return TextField(
        key: widget.key,
        textAlign: widget.textAlign == null ? TextAlign.left : widget.textAlign,
        textAlignVertical: TextAlignVertical.center,
        controller: _controller,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        autocorrect: false,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        style: widget.style != null ? widget.style : TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
        strutStyle: StrutStyle(height: 1.45),
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted ?? widget.onChanged,
        onChanged: (v) {
          if (widget.onChanged != null)
            widget.onChanged(_controller.text);
          var _empty = _controller.text == null || _controller.text.isEmpty;
          if (_empty != isEmpty) {
            setState(() {
              isEmpty = _empty;
            });
          }
        },
        decoration: new InputDecoration(
          counterText: "",
          counterStyle: null, // const TextStyle(fontSize: 0.01),
          helperStyle: null,
          border: widget.border ?? InputBorder.none,
          enabledBorder: widget.border ?? InputBorder.none,
          disabledBorder: widget.border ?? InputBorder.none,
          errorBorder: widget.border ?? InputBorder.none,
          focusedBorder: widget.focusedBorder ?? widget.border ?? InputBorder.none,
          isDense: widget.dense,
          hintText: widget.hint,
          hintStyle: widget.hintStyle != null ? widget.hintStyle : TextStyle(color: Theme.of(context).hintColor),
          hintMaxLines: widget.maxLines == null ? (isEmpty ? 2 : null) : widget.maxLines,
          suffixIcon: widget.suffix ,
          suffix: _controller.text.isEmpty || !widget.enabled || widget.readOnly ? null : InkWell(
            child: Container(
              width: 16.0,
              height: 16.0,
              child: Icon(Icons.clear, color: Theme.of(context).dividerColor, size: 12.0),
            ),
            onTap: () {
              _controller.text = '';
              if (widget.onChanged != null)
                widget.onChanged('');
              setState(() {
                isEmpty = true;
              });
            },
          ),
        )
    );
  }
}