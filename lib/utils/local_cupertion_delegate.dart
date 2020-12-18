import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/cupertino.dart';

/// Flutter IOS端输入框长按报错The getter 'cutButtonLabel' was called on null，解决
class LocalizationsCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const LocalizationsCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  SynchronousFuture<_DefaultCupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<_DefaultCupertinoLocalizations>(
        _DefaultCupertinoLocalizations(locale.languageCode));
  }

  @override
  bool shouldReload(LocalizationsCupertinoDelegate old) => false;

  ///全局静态的代理
  static LocalizationsCupertinoDelegate delegate = LocalizationsCupertinoDelegate();
}

class _DefaultCupertinoLocalizations extends CupertinoLocalizations {
  _DefaultCupertinoLocalizations(this._languageCode) : assert(_languageCode != null);

  final DefaultCupertinoLocalizations _en = const DefaultCupertinoLocalizations();
  final String _languageCode;

  final Map<String, Map<String, String>> _dict = <String, Map<String, String>>{
    'en': <String, String>{
      'alert': 'Alert',
      'copy': 'Copy',
      'paste': 'Paste',
      'cut': 'Cut',
      'selectAll': 'Select all',
      'today': 'today'
    },
    'zh': <String, String>{
      'alert': '警告',
      'copy': '复制',
      'paste': '粘贴',
      'cut': '剪切',
      'selectAll': '选择全部',
      'today': '今天'
    }
  };

  @override
  String get alertDialogLabel => _get('alert');

  @override
  String get anteMeridiemAbbreviation => _en.anteMeridiemAbbreviation;

  @override
  String get postMeridiemAbbreviation => _en.postMeridiemAbbreviation;

  @override
  String get copyButtonLabel => _get('copy');

  @override
  String get cutButtonLabel => _get('cut');

  @override
  String get pasteButtonLabel => _get('paste');

  @override
  String get selectAllButtonLabel => _get('selectAll');

  @override
  DatePickerDateOrder get datePickerDateOrder => _en.datePickerDateOrder;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder => _en.datePickerDateTimeOrder;

  @override
  String datePickerDayOfMonth(int dayIndex) => _en.datePickerDayOfMonth(dayIndex);

  @override
  String datePickerHour(int hour) => _en.datePickerHour(hour);

  @override
  String datePickerHourSemanticsLabel(int hour) => _en.datePickerHourSemanticsLabel(hour);

  @override
  String datePickerMediumDate(DateTime date) => _en.datePickerMediumDate(date);

  @override
  String datePickerMinute(int minute) => _en.datePickerMinute(minute);

  @override
  String datePickerMinuteSemanticsLabel(int minute) =>
      _en.datePickerMinuteSemanticsLabel(minute);

  @override
  String datePickerMonth(int monthIndex) => _en.datePickerMonth(monthIndex);

  @override
  String datePickerYear(int yearIndex) => _en.datePickerYear(yearIndex);

  @override
  String timerPickerHour(int hour) => _en.timerPickerHour(hour);

  @override
  String timerPickerHourLabel(int hour) => _en.timerPickerHourLabel(hour);

  @override
  String timerPickerMinute(int minute) => _en.timerPickerMinute(minute);

  @override
  String timerPickerMinuteLabel(int minute) => _en.timerPickerMinuteLabel(minute);

  @override
  String timerPickerSecond(int second) => _en.timerPickerSecond(second);

  @override
  String timerPickerSecondLabel(int second) => _en.timerPickerSecondLabel(second);

  String _get(String key) {
    return _dict[_languageCode][key];
  }

  @override
  String get todayLabel => _get("today");

  @override
  String get modalBarrierDismissLabel => _en.modalBarrierDismissLabel;

  @override
  String tabSemanticsLabel({int tabIndex, int tabCount}) {
    return _en.tabSemanticsLabel(tabIndex: tabCount, tabCount: tabCount);
  }

  @override
  List<String> get timerPickerHourLabels => throw UnimplementedError();

  @override
  List<String> get timerPickerMinuteLabels => throw UnimplementedError();

  @override
  List<String> get timerPickerSecondLabels => throw UnimplementedError();

  @override
  String get searchTextFieldPlaceholderLabel => '';
}
