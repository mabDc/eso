import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/utils.dart';

class FilePickerMacOS extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    final String executable = await isExecutableOnPath('osascript');
    final String fileFilter = fileTypeToFileFilter(
      type,
      allowedExtensions,
    );
    final List<String> arguments = generateCommandLineArguments(
      escapeDialogTitle(dialogTitle ?? defaultDialogTitle),
      fileFilter: fileFilter,
      initialDirectory: initialDirectory ?? '',
      multipleFiles: allowMultiple,
      pickDirectory: false,
    );

    final String? fileSelectionResult = await runExecutableWithArguments(
      executable,
      arguments,
    );
    if (fileSelectionResult == null) {
      return null;
    }

    final List<String> filePaths = resultStringToFilePaths(
      fileSelectionResult,
    );
    final List<PlatformFile> platformFiles = await filePathsToPlatformFiles(
      filePaths,
      withReadStream,
      withData,
    );

    return FilePickerResult(platformFiles);
  }

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    final String executable = await isExecutableOnPath('osascript');
    final List<String> arguments = generateCommandLineArguments(
      escapeDialogTitle(dialogTitle ?? defaultDialogTitle),
      initialDirectory: initialDirectory ?? '',
      pickDirectory: true,
    );

    final String? directorySelectionResult = await runExecutableWithArguments(
      executable,
      arguments,
    );
    if (directorySelectionResult == null) {
      return null;
    }

    return resultStringToFilePaths(directorySelectionResult).first;
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) async {
    final String executable = await isExecutableOnPath('osascript');
    final String fileFilter = fileTypeToFileFilter(
      type,
      allowedExtensions,
    );
    final List<String> arguments = generateCommandLineArguments(
      escapeDialogTitle(dialogTitle ?? defaultDialogTitle),
      fileFilter: fileFilter,
      fileName: fileName ?? '',
      initialDirectory: initialDirectory ?? '',
      saveFile: true,
    );

    final String? saveFileResult = await runExecutableWithArguments(
      executable,
      arguments,
    );
    if (saveFileResult == null) {
      return null;
    }

    return resultStringToFilePaths(saveFileResult).first;
  }

  String fileTypeToFileFilter(FileType type, List<String>? allowedExtensions) {
    switch (type) {
      case FileType.any:
        return '';
      case FileType.audio:
        return '"aac", "midi", "mp3", "ogg", "wav"';
      case FileType.custom:
        return '"", "' + allowedExtensions!.join('", "') + '"';
      case FileType.image:
        return '"bmp", "gif", "jpeg", "jpg", "png"';
      case FileType.media:
        return '"avi", "flv", "mkv", "mov", "mp4", "mpeg", "webm", "wmv", "bmp", "gif", "jpeg", "jpg", "png"';
      case FileType.video:
        return '"avi", "flv", "mkv", "mov", "mp4", "mpeg", "webm", "wmv"';
      default:
        throw Exception('unknown file type');
    }
  }

  List<String> generateCommandLineArguments(
    String dialogTitle, {
    String fileFilter = '',
    String fileName = '',
    String initialDirectory = '',
    bool multipleFiles = false,
    bool pickDirectory = false,
    bool saveFile = false,
  }) {
    final arguments = ['-e'];

    String argument = 'choose ';
    if (pickDirectory) {
      argument += 'folder ';
    } else {
      argument += 'file ';

      if (saveFile) {
        argument += 'name ';

        if (fileName.isNotEmpty) {
          argument += 'default name "$fileName" ';
        }
      } else {
        if (fileFilter.isNotEmpty) {
          argument += 'of type {$fileFilter} ';
        }

        if (multipleFiles) {
          argument += 'with multiple selections allowed ';
        }
      }
    }

    if (initialDirectory.isNotEmpty) {
      argument += 'default location "$initialDirectory" ';
    }

    argument += 'with prompt "$dialogTitle"';
    arguments.add(argument);

    return arguments;
  }

  String escapeDialogTitle(String dialogTitle) => dialogTitle
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\\n');

  /// Transforms the result string (stdout) of `osascript` into a [List] of
  /// POSIX file paths.
  List<String> resultStringToFilePaths(String fileSelectionResult) {
    if (fileSelectionResult.trim().isEmpty) {
      return [];
    }

    final paths = fileSelectionResult
        .trim()
        .split(', alias ')
        .map((String path) => path.trim())
        .where((String path) => path.isNotEmpty)
        .toList();

    if (paths.length == 1 && paths.first.startsWith('file ')) {
      // The first token of the first path is "file" in case of the save file
      // dialog
      paths[0] = paths[0].substring(5);
    } else if (paths.isNotEmpty && paths.first.startsWith('alias ')) {
      // The first token of the first path is "alias" in case of the
      // file/directory picker dialog
      paths[0] = paths[0].substring(6);
    }

    return paths.map((String path) {
      final pathElements = path.split(':').where((e) => e.isNotEmpty).toList();
      final volumeName = pathElements[0];
      return ['/Volumes', volumeName, ...pathElements.sublist(1)].join('/');
    }).toList();
  }
}
