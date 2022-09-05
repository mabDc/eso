@TestOn('linux')

import 'package:file_picker/src/linux/dialog_handler.dart';
import 'package:file_picker/src/linux/kdialog_handler.dart';
import 'package:file_picker/src/linux/qarma_and_zenity_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DialogHandler Factory', () {
    test('should return an instance of KDialogHandler for kdialog', () {
      expect(
        DialogHandler('/usr/bin/kdialog'),
        isInstanceOf<KDialogHandler>(),
      );
    });

    test('should return an instance of QarmaAndZenityHandler for qarma', () {
      expect(
        DialogHandler('/snap/bin/qarma'),
        isInstanceOf<QarmaAndZenityHandler>(),
      );
    });

    test('should return an instance of QarmaAndZenityHandler for zenity', () {
      expect(
        DialogHandler('/usr/share/zenity'),
        isInstanceOf<QarmaAndZenityHandler>(),
      );
    });

    test('should throw an exception for unknown executables', () {
      expect(
        () => DialogHandler('/usr/bin/osascript'),
        throwsUnimplementedError,
      );
    });
  });
}
