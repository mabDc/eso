import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'highlight.dart';

class HighLightCodeEditor extends StatefulWidget {
  final Key key;
  final String code;
  final bool readOnly;
  final EdgeInsets padding;
  final FocusNode focusNode;

  HighLightCodeEditor(this.key, this.code,
      {this.readOnly = false, this.padding, this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => HighLightCodeEditorState();
}

class HighLightCodeEditorState extends State<HighLightCodeEditor> {
  final String engineId = "_CODE_FORMAT_ENGINE_ID_";

  int _lastTextLength;
  CodeInputController codeTextController;
  IsolateQjs _jsEngine;
  int _lines = 0;
  ScrollController textScrollerController;
  ScrollController lineCodeScrollerController;

  CodeInputController get controller => codeTextController;

  @override
  void initState() {
    super.initState();
    var code = widget.code;
    codeTextController = CodeInputController(text: code);
    textScrollerController = ScrollController();
    lineCodeScrollerController = ScrollController();

    textScrollerController.addListener(_handleTextScroll);

    setLines(code);

    initJsEngine();
  }

  void initJsEngine() async {
    _jsEngine = IsolateQjs(stackSize: 1024 * 1024);

    var code = await rootBundle.loadString("assets/JsDecoder.js");
    _jsEngine.evaluate(code);
    code = '''
        function js_format(code){
          var jsdecoder = new JsDecoder();
          jsdecoder.s = code;
          return jsdecoder.decode();
        }
      ''';
    _jsEngine.evaluate(code);
  }

  @override
  Widget build(BuildContext context) {
    final w = 3 * MediaQuery.of(context).size.width;
    return Container(
      color: theme["root"]?.backgroundColor,
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            controller: lineCodeScrollerController,
            child: IntrinsicWidth(
              child: Text(
                List.generate(_lines, (i) => i + 1).join("\n"),
                style: TextStyle(
                  color: theme["root"]?.color,
                  fontSize: 12,
                  height: 1.5,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          SizedBox(width: 3),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(minWidth: w),
                child: IntrinsicWidth(
                  child: TextField(
                    focusNode: widget.focusNode,
                    scrollPhysics: ClampingScrollPhysics(),
                    scrollController: textScrollerController,
                    cursorColor: Colors.green,
                    style: TextStyle(
                      color: theme["root"]?.color,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    controller: codeTextController,
                    readOnly: widget.readOnly,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    expands: true,
                    maxLines: null,
                    onChanged: _onChange,
                    onAppPrivateCommand: (value, map) {
                      print(value);
                      print(map);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getCode() {
    return codeTextController.text;
  }

  void indent() {
    replaceSelection('    ');
  }

  Future format() async {
    JSInvokable function = await _jsEngine.evaluate("js_format");
    var code = await function.invoke([codeTextController.text]);
    codeTextController.value = TextEditingValue(text: code);
    function.free();
    setLines(code);
  }

  String get code => codeTextController.text;

  void setValue(String code) async {
    codeTextController.value = TextEditingValue(text: code);
  }

  Future replaceSelection(String code) async {
    String text = codeTextController.text;
    TextSelection textSelection = codeTextController.selection;
    if (textSelection.isValid) {
      String newText = text.replaceRange(textSelection.start, textSelection.end, code);
      final codeLength = code.length;
      codeTextController.text = newText;
      codeTextController.selection = textSelection.copyWith(
        baseOffset: textSelection.start + codeLength,
        extentOffset: textSelection.start + codeLength,
      );
    }
  }

  void clear() async {
    codeTextController.value = TextEditingValue.empty;
  }

  void _onChange(String value) {
    setLines(value);
    if (_lastTextLength == null ||
        (_lastTextLength != null && _lastTextLength < value.length)) {
      var currentChar = value.characters.elementAt(controller.selection.baseOffset - 1);
      if (currentChar == '\n') {
        _reindent();
      }
    }
    _lastTextLength = value.length;
  }

  void setLines(String code) {
    setState(() {
      _lines = code.split('\n').length;
    });
  }

  void _reindent() {
    print("输入的是换行符");
    int spaceNum = 0;
    for (int i = controller.selection.baseOffset - 2; i >= 0; i--) {
      var char = controller.text.characters.elementAt(i);
      if (char == ' ') {
        spaceNum++;
      } else if (char == '\n') {
        break;
      } else {
        spaceNum = 0;
      }
    }
    replaceSelection(' ' * spaceNum);
  }

  void _handleTextScroll() {
    if (textScrollerController.offset <=
        lineCodeScrollerController.position.maxScrollExtent) {
      lineCodeScrollerController.jumpTo(textScrollerController.offset);
    }
  }

  @override
  void dispose() {
    textScrollerController.removeListener(_handleTextScroll);
    textScrollerController.dispose();
    lineCodeScrollerController.dispose();
    codeTextController.dispose();
    _jsEngine.close();
    super.dispose();
  }
}
