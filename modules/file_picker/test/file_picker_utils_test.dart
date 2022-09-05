@TestOn('linux || mac-os')

import 'dart:io';
import 'package:file_picker/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  final appTestFilePath = '/tmp/test_utils.app';
  final imageTestFile = '/tmp/test_utils.jpg';
  final pdfTestFile = '/tmp/test_utils.pdf';
  final yamlTestFile = '/tmp/test_utils.yml';

  setUpAll(
    () => setUpTestFiles(
        appTestFilePath, imageTestFile, pdfTestFile, yamlTestFile),
  );

  tearDownAll(
    () => tearDownTestFiles(
        appTestFilePath, imageTestFile, pdfTestFile, yamlTestFile),
  );

  group('createPlatformFile()', () {
    test('should return an instance of PlatformFile', () async {
      final imageFile = File(imageTestFile);
      final bytes = imageFile.readAsBytesSync();
      final readStream = imageFile.openRead();

      final platformFile =
          await createPlatformFile(imageFile, bytes, readStream);

      expect(platformFile.bytes, equals(bytes));
      expect(platformFile.name, equals('test_utils.jpg'));
      expect(platformFile.readStream, equals(readStream));
      expect(platformFile.size, equals(bytes.length));
    });

    test(
        'should not throw an exception when picking .app files on macOS (.app files on macOS are actually directories but they are treated as files, similar to .exe files on Windows)',
        () async {
      final appFile = File(appTestFilePath);

      final platformFile = await createPlatformFile(appFile, null, null);

      expect(platformFile.bytes, equals(null));
      expect(platformFile.name, equals('test_utils.app'));
      expect(platformFile.readStream, equals(null));
      expect(
        platformFile.size,
        equals(0),
        reason: 'Expect size to be 0 because .app files are directories.',
      );
    });
  });

  group('filePathsToPlatformFiles()', () {
    test('should transform a list of file paths into a list of PlatformFiles',
        () async {
      final filePaths = [imageTestFile, pdfTestFile, yamlTestFile];

      final platformFiles =
          await filePathsToPlatformFiles(filePaths, false, false);

      expect(platformFiles.length, equals(filePaths.length));

      final imageFile = platformFiles.firstWhere(
        (element) => element.name == 'test_utils.jpg',
      );
      expect(imageFile.extension, equals('jpg'));
      expect(imageFile.name, equals('test_utils.jpg'));
      expect(imageFile.path, equals(imageTestFile));
      expect(imageFile.size, equals(4073378));

      final pdfFile = platformFiles.firstWhere(
        (element) => element.name == 'test_utils.pdf',
      );
      expect(pdfFile.extension, equals('pdf'));
      expect(pdfFile.name, equals('test_utils.pdf'));
      expect(pdfFile.path, equals(pdfTestFile));
      expect(pdfFile.size, equals(7478));

      final yamlFile = platformFiles.firstWhere(
        (element) => element.name == 'test_utils.yml',
      );
      expect(yamlFile.extension, equals('yml'));
      expect(yamlFile.name, equals('test_utils.yml'));
      expect(yamlFile.path, equals(yamlTestFile));
      expect(yamlFile.size, equals(213));
    });

    test(
        'should transform an empty list of file paths into an empty list of PlatformFiles',
        () async {
      final filePaths = <String>[];

      final platformFiles = await filePathsToPlatformFiles(
        filePaths,
        false,
        false,
      );

      expect(platformFiles.length, equals(filePaths.length));
    });
  });
}
