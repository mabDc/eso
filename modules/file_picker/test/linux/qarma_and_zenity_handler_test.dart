@TestOn('linux')

import 'package:file_picker/src/file_picker.dart';
import 'package:file_picker/src/linux/qarma_and_zenity_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final imageTestFile = '/tmp/test_linux.jpg';
  final pdfTestFile = '/tmp/test_linux.pdf';
  final yamlTestFile = '/tmp/test_linux.yml';

  group('fileTypeToFileFilter()', () {
    test('should return the file filter string for predefined file types', () {
      final dialogHandler = QarmaAndZenityHandler();

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.any, null),
        equals(''),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.audio, null),
        equals('*.aac *.midi *.mp3 *.ogg *.wav'),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.image, null),
        equals('*.bmp *.gif *.jpeg *.jpg *.png'),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.media, null),
        equals(
          '*.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.webm *.wmv *.bmp *.gif *.jpeg *.jpg *.png',
        ),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.video, null),
        equals('*.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.webm *.wmv'),
      );
    });

    test('should return the file filter string for custom file extensions', () {
      final dialogHandler = QarmaAndZenityHandler();

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.custom, ['dart']),
        equals('*.dart'),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.custom, ['dart', 'html']),
        equals('*.dart *.html'),
      );
    });
  });

  group('resultStringToFilePaths()', () {
    test('should interpret the result of picking a single file', () {
      final filePaths = QarmaAndZenityHandler().resultStringToFilePaths(
        imageTestFile,
      );

      expect(filePaths.length, equals(1));
      expect(filePaths[0], imageTestFile);
    });

    test('should return an empty list if the file picker result was empty', () {
      final filePaths = QarmaAndZenityHandler().resultStringToFilePaths('');

      expect(filePaths.length, equals(0));
    });

    test('should interpret the result of picking multiple files', () {
      final filePaths = QarmaAndZenityHandler().resultStringToFilePaths(
        '$imageTestFile|$pdfTestFile|$yamlTestFile',
      );

      expect(filePaths.length, equals(3));
      expect(filePaths[0], equals(imageTestFile));
      expect(filePaths[1], equals(pdfTestFile));
      expect(filePaths[2], equals(yamlTestFile));
    });

    test(
        'should interpret the result of file names that contain vertical pipes',
        () {
      final filePaths = QarmaAndZenityHandler().resultStringToFilePaths(
        '$imageTestFile|/home/user/file-with-|-in-name.txt|/tmp/image.png',
      );

      expect(filePaths.length, equals(3));
      expect(filePaths[0], equals(imageTestFile));
      expect(filePaths[1], equals('/home/user/file-with-|-in-name.txt'));
      expect(filePaths[2], equals('/tmp/image.png'));
    });

    test('should interpret the result of picking a directory', () {
      final filePaths = QarmaAndZenityHandler().resultStringToFilePaths(
        '/home/john/studies',
      );

      expect(filePaths.length, equals(1));
      expect(filePaths[0], equals('/home/john/studies'));
    });
  });

  group('generateCommandLineArguments()', () {
    test('should generate the arguments for picking a single file', () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select a file:',
        multipleFiles: false,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals("""--file-selection --title Select a file:"""),
      );
    });

    test('should generate the arguments for the save-file dialog', () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select output file:',
        multipleFiles: false,
        pickDirectory: false,
        saveFile: true,
        fileName: 'test.out',
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--file-selection --title Select output file: --save --filename=test.out"""),
      );
    });

    test('should generate the arguments for picking multiple files', () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select files:',
        multipleFiles: true,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals("""--file-selection --title Select files: --multiple"""),
      );
    });

    test(
        'should generate the arguments for picking a single file with a custom file filter',
        () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select a file:',
        fileFilter: '*.dart *.yml',
        multipleFiles: false,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals(
          """--file-selection --title Select a file: --file-filter=*.dart *.yml""",
        ),
      );
    });

    test(
        'should generate the arguments for picking multiple files with a custom file filter',
        () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select HTML files:',
        fileFilter: '*.html',
        multipleFiles: true,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--file-selection --title Select HTML files: --file-filter=*.html --multiple"""),
      );
    });

    test('should generate the arguments for picking a directory', () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select a directory:',
        pickDirectory: true,
      );

      expect(
        cliArguments.join(' '),
        equals("""--file-selection --title Select a directory: --directory"""),
      );
    });

    test(
        'should generate the arguments for picking a file when an initial directory is given',
        () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Select a file:',
        initialDirectory: '/home/user/Desktop/',
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--file-selection --title Select a file: --filename=/home/user/Desktop/"""),
      );
    });

    test(
        'should generate the arguments for saving a file when an initial directory is given',
        () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Save as:',
        initialDirectory: '/home/user/Desktop/',
        saveFile: true,
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--file-selection --title Save as: --save --filename=/home/user/Desktop/"""),
      );
    });

    test(
        'should generate the arguments for saving a file when an initial directory and the filename is given',
        () {
      final cliArguments = QarmaAndZenityHandler().generateCommandLineArguments(
        'Save as:',
        fileName: 'output.pdf',
        initialDirectory: '/home/user/Desktop/',
        saveFile: true,
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--file-selection --title Save as: --save --filename=/home/user/Desktop/output.pdf"""),
      );
    });
  });
}
