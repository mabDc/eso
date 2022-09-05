import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/linux/dialog_handler.dart';
import 'package:path/path.dart' as p;

class KDialogHandler implements DialogHandler {
  @override
  List<String> generateCommandLineArguments(
    String dialogTitle, {
    String fileFilter = '',
    String fileName = '',
    String initialDirectory = '',
    bool multipleFiles = false,
    bool pickDirectory = false,
    bool saveFile = false,
  }) {
    final arguments = ['--title', dialogTitle];

    if (saveFile && !pickDirectory) {
      arguments.add('--getsavefilename');
    } else if (!saveFile && !pickDirectory) {
      arguments.add('--getopenfilename');
    } else {
      arguments.add('--getexistingdirectory');
    }

    // Start directory for the dialog
    if (fileName.isNotEmpty && initialDirectory.isNotEmpty) {
      arguments.add(p.join(initialDirectory, fileName));
    } else if (fileName.isNotEmpty) {
      arguments.add(p.absolute(fileName));
    } else if (initialDirectory.isNotEmpty) {
      arguments.add(initialDirectory);
    }

    if (!pickDirectory && fileFilter.isNotEmpty) {
      // In order to specify a filter, a start directory has to be specified
      if (fileName.isEmpty && initialDirectory.isEmpty) {
        arguments.add('.');
      }
      arguments.add(fileFilter);
    }

    if (multipleFiles) {
      arguments.addAll(['--multiple', '--separate-output']);
    }

    return arguments;
  }

  @override
  String fileTypeToFileFilter(
    FileType type,
    List<String>? allowedExtensions,
  ) {
    switch (type) {
      case FileType.any:
        return '';
      case FileType.audio:
        return 'Audio File (*.aac *.midi *.mp3 *.ogg *.wav)';
      case FileType.custom:
        return allowedExtensions!
                .map((ext) => ext.toUpperCase())
                .join(' File, ') +
            ' File (*.' +
            allowedExtensions.join(' *.') +
            ')';
      case FileType.image:
        return 'Image File (*.bmp *.gif *.jpeg *.jpg *.png)';
      case FileType.media:
        return 'Media File (*.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.webm *.wmv *.bmp *.gif *.jpeg *.jpg *.png)';
      case FileType.video:
        return 'Video File (*.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.webm *.wmv)';
      default:
        throw Exception('unknown file type');
    }
  }

  @override
  List<String> resultStringToFilePaths(String fileSelectionResult) {
    if (fileSelectionResult.trim().isEmpty) {
      return [];
    }

    return fileSelectionResult
        .split('\n')
        .map((String path) => path.startsWith('/') ? path : '/' + path)
        .toList();
  }
}
