import 'package:flutter/services.dart';

class TextInputFormatterRegExp extends TextInputFormatter {
  TextInputFormatterRegExp(this.regExp) : assert(regExp != null);

  final RegExp regExp;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (regExp.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
