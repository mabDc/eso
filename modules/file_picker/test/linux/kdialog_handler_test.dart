@TestOn('linux')

import 'package:file_picker/src/file_picker.dart';
import 'package:file_picker/src/linux/kdialog_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  final imageTestFile = '/tmp/test_linux.jpg';
  final pdfTestFile = '/tmp/test_linux.pdf';
  final yamlTestFile = '/tmp/test_linux.yml';

  group('fileTypeToFileFilter()', () {
    test('should return the file filter string for predefined file types', () {
      final dialogHandler = KDialogHandler();

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.any, null),
        equals(''),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.audio, null),
        equals('Audio File (*.aac *.midi *.mp3 *.ogg *.wav)'),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.image, null),
        equals('Image File (*.bmp *.gif *.jpeg *.jpg *.png)'),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.media, null),
        equals(
          'Media File (*.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.webm *.wmv *.bmp *.gif *.jpeg *.jpg *.png)',
        ),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.video, null),
        equals(
            'Video File (*.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.webm *.wmv)'),
      );
    });

    test('should return the file filter string for custom file extensions', () {
      final dialogHandler = KDialogHandler();

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.custom, ['dart']),
        equals('DART File (*.dart)'),
      );

      expect(
        dialogHandler.fileTypeToFileFilter(FileType.custom, ['dart', 'html']),
        equals('DART File, HTML File (*.dart *.html)'),
      );
    });
  });

  group('resultStringToFilePaths()', () {
    test('should interpret the result of picking a single file', () {
      final filePaths = KDialogHandler().resultStringToFilePaths(
        imageTestFile,
      );

      expect(filePaths.length, equals(1));
      expect(filePaths[0], imageTestFile);
    });

    test('should return an empty list if the file picker result was empty', () {
      final filePaths = KDialogHandler().resultStringToFilePaths('');

      expect(filePaths.length, equals(0));
    });

    test('should interpret the result of picking multiple files', () {
      final filePaths = KDialogHandler().resultStringToFilePaths(
        '$imageTestFile\n$pdfTestFile\n$yamlTestFile',
      );

      expect(filePaths.length, equals(3));
      expect(filePaths[0], equals(imageTestFile));
      expect(filePaths[1], equals(pdfTestFile));
      expect(filePaths[2], equals(yamlTestFile));
    });

    test('should interpret the result of file paths that contain blanks', () {
      final filePaths = KDialogHandler().resultStringToFilePaths(
        '$imageTestFile\n/tmp/ dir with blanks / file with blanks.txt\n/tmp/image.png',
      );

      expect(filePaths.length, equals(3));
      expect(filePaths[0], equals(imageTestFile));
      expect(
        filePaths[1],
        equals('/tmp/ dir with blanks / file with blanks.txt'),
      );
      expect(filePaths[2], equals('/tmp/image.png'));
    });

    test('should interpret the result of picking a directory', () {
      final filePaths = KDialogHandler().resultStringToFilePaths(
        '/home/john/studies',
      );

      expect(filePaths.length, equals(1));
      expect(filePaths[0], equals('/home/john/studies'));
    });
  });

  group('generateCommandLineArguments()', () {
    test('should generate the arguments for picking a single file', () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select a file:',
        multipleFiles: false,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals("""--title Select a file: --getopenfilename"""),
      );
    });

    test('should generate the arguments for the save-file dialog', () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select output file:',
        multipleFiles: false,
        pickDirectory: false,
        saveFile: true,
        fileName: 'test.out',
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--title Select output file: --getsavefilename ${p.absolute('test.out')}"""),
      );
    });

    test('should generate the arguments for picking multiple files', () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select files:',
        multipleFiles: true,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals(
          """--title Select files: --getopenfilename --multiple --separate-output""",
        ),
      );
    });

    test(
        'should generate the arguments for picking a single file with a custom file filter',
        () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select a file:',
        fileFilter: 'DART File, YML File (*.dart *.yml)',
        multipleFiles: false,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals(
          """--title Select a file: --getopenfilename . DART File, YML File (*.dart *.yml)""",
        ),
      );
    });

    test(
        'should generate the arguments for picking multiple files with a custom file filter',
        () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select HTML files:',
        fileFilter: 'HTML File (*.html)',
        multipleFiles: true,
        pickDirectory: false,
      );

      expect(
        cliArguments.join(' '),
        equals(
          """--title Select HTML files: --getopenfilename . HTML File (*.html) --multiple --separate-output""",
        ),
      );
    });

    test('should generate the arguments for picking a directory', () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select a directory:',
        pickDirectory: true,
      );

      expect(
        cliArguments.join(' '),
        equals("""--title Select a directory: --getexistingdirectory"""),
      );
    });

    test(
        'should generate the arguments for picking a file when an initial directory is given',
        () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select a file:',
        initialDirectory: '/etc/python3.8',
      );

      expect(
        cliArguments.join(' '),
        equals("""--title Select a file: --getopenfilename /etc/python3.8"""),
      );
    });

    test(
        'should generate the arguments for saving a file when an initial directory is given',
        () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Save as:',
        initialDirectory: '/home/user/Desktop/',
        saveFile: true,
      );

      expect(
        cliArguments.join(' '),
        equals("""--title Save as: --getsavefilename /home/user/Desktop/"""),
      );
    });

    test(
        'should generate the arguments for saving a file when an initial directory and the filename is given',
        () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Save as:',
        fileName: 'output.pdf',
        initialDirectory: '/tmp',
        saveFile: true,
      );

      expect(
        cliArguments.join(' '),
        equals("""--title Save as: --getsavefilename /tmp/output.pdf"""),
      );
    });

    test(
        'should set the KDialog option "startDir" to the current directory if a file filter is given but fileName and initialDir are empty',
        () {
      final cliArguments = KDialogHandler().generateCommandLineArguments(
        'Select a file:',
        fileFilter: 'HTML File (*.html)',
        fileName: '',
        initialDirectory: '',
      );

      expect(
        cliArguments.join(' '),
        equals(
            """--title Select a file: --getopenfilename . HTML File (*.html)"""),
      );
    });
  });
}
