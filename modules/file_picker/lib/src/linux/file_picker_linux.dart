import 'dart:async';
import 'package:file_picker/src/file_picker.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:file_picker/src/linux/dialog_handler.dart';
import 'package:file_picker/src/platform_file.dart';
import 'package:file_picker/src/utils.dart';

class FilePickerLinux extends FilePicker {
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
    final String executable = await _getPathToExecutable();
    final dialogHandler = DialogHandler(executable);

    final String fileFilter = dialogHandler.fileTypeToFileFilter(
      type,
      allowedExtensions,
    );

    final List<String> arguments = dialogHandler.generateCommandLineArguments(
      dialogTitle ?? defaultDialogTitle,
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

    final List<String> filePaths = dialogHandler.resultStringToFilePaths(
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
    final executable = await _getPathToExecutable();
    final List<String> arguments =
        DialogHandler(executable).generateCommandLineArguments(
      dialogTitle ?? defaultDialogTitle,
      initialDirectory: initialDirectory ?? '',
      pickDirectory: true,
    );
    return await runExecutableWithArguments(executable, arguments);
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
    final executable = await _getPathToExecutable();
    final dialogHandler = DialogHandler(executable);

    final String fileFilter = dialogHandler.fileTypeToFileFilter(
      type,
      allowedExtensions,
    );

    final List<String> arguments = dialogHandler.generateCommandLineArguments(
      dialogTitle ?? defaultDialogTitle,
      fileFilter: fileFilter,
      fileName: fileName ?? '',
      initialDirectory: initialDirectory ?? '',
      saveFile: true,
    );

    return await runExecutableWithArguments(executable, arguments);
  }

  /// Returns the path to the executables `qarma`, `zenity` or `kdialog` as a
  /// [String].
  /// On Linux, the CLI tools `qarma` or `zenity` can be used to open a native
  /// file picker dialog. It seems as if all Linux distributions have at least
  /// one of these two tools pre-installed (on Ubuntu `zenity` is pre-installed).
  /// On distribuitions that use KDE Plasma as their Desktop Environment,
  /// `kdialog` is used to achieve these functionalities.
  /// The future returns an error, if none of the executables was found on
  /// the path.
  Future<String> _getPathToExecutable() async {
    try {
      try {
        return await isExecutableOnPath('qarma');
      } on Exception {
        return await isExecutableOnPath('kdialog');
      }
    } on Exception {
      return await isExecutableOnPath('zenity');
    }
  }
}
