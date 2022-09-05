import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/linux/kdialog_handler.dart';
import 'package:file_picker/src/linux/qarma_and_zenity_handler.dart';

abstract class DialogHandler {
  factory DialogHandler(String pathToExecutable) {
    pathToExecutable = pathToExecutable.toLowerCase();

    if (pathToExecutable.endsWith('kdialog')) {
      return KDialogHandler();
    } else if (pathToExecutable.endsWith('qarma') ||
        pathToExecutable.endsWith('zenity')) {
      return QarmaAndZenityHandler();
    }
    throw UnimplementedError(
      'DialogHandler for executable $pathToExecutable has not been implemented',
    );
  }

  /// Generates the command line arguments to open a dialog with the respective
  /// dialog tool (`kdialog`, `qarma`, or `zenity`).
  List<String> generateCommandLineArguments(
    String dialogTitle, {
    String fileFilter = '',
    String fileName = '',
    String initialDirectory = '',
    bool multipleFiles = false,
    bool pickDirectory = false,
    bool saveFile = false,
  });

  /// Converts the specified combination of [type] and [allowedExtensions] into
  /// the format required by the respective dialog tool (`kdialog`, `qarma`,
  /// or `zenity`) to filter for specific file types.
  ///
  /// [allowedExtensions] must only be used in combination with [type] equal to
  /// [FileType.custom].
  String fileTypeToFileFilter(FileType type, List<String>? allowedExtensions);

  /// Converts the result string (stdout) of `qarma`, `zenity` or `kdialog`
  /// into a [List<String>] of file paths.
  List<String> resultStringToFilePaths(String fileSelectionResult);
}
