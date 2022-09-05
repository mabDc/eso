import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/file_picker_io.dart';
import 'package:file_picker/src/file_picker_macos.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:file_picker/src/linux/file_picker_linux.dart';
import 'package:file_picker/src/windows/stub.dart'
    if (dart.library.io) 'package:file_picker/src/windows/file_picker_windows.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String defaultDialogTitle = 'File Picker';

enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

enum FilePickerStatus {
  picking,
  done,
}

/// The interface that implementations of file_picker must implement.
///
/// Platform implementations should extend this class rather than implement it as `file_picker`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FilePicker] methods.
abstract class FilePicker extends PlatformInterface {
  FilePicker() : super(token: _token);

  static final Object _token = Object();

  static late FilePicker _instance = FilePicker._setPlatform();

  static FilePicker get platform => _instance;

  static set platform(FilePicker instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  factory FilePicker._setPlatform() {
    if (Platform.isAndroid || Platform.isIOS) {
      return FilePickerIO();
    } else if (Platform.isLinux) {
      return FilePickerLinux();
    } else if (Platform.isWindows) {
      return filePickerWithFFI();
    } else if (Platform.isMacOS) {
      return FilePickerMacOS();
    } else {
      throw UnimplementedError(
        'The current platform "${Platform.operatingSystem}" is not supported by this plugin.',
      );
    }
  }

  /// Retrieves the file(s) from the underlying platform
  ///
  /// Default [type] set to [FileType.any] with [allowMultiple] set to `false`.
  /// Optionally, [allowedExtensions] might be provided (e.g. `[pdf, svg, jpg]`.).
  ///
  /// If [withData] is set, picked files will have its byte data immediately available on memory as `Uint8List`
  /// which can be useful if you are picking it for server upload or similar. However, have in mind that
  /// enabling this on IO (iOS & Android) may result in out of memory issues if you allow multiple picks or
  /// pick huge files. Use [withReadStream] instead. Defaults to `true` on web, `false` otherwise.
  ///
  /// If [withReadStream] is set, picked files will have its byte data available as a [Stream<List<int>>]
  /// which can be useful for uploading and processing large files. Defaults to `false`.
  ///
  /// If you want to track picking status, for example, because some files may take some time to be
  /// cached (particularly those picked from cloud providers), you may want to set [onFileLoading] handler
  /// that will give you the current status of picking.
  ///
  /// If [allowCompression] is set, it will allow media to apply the default OS compression.
  /// Defaults to `true`.
  ///
  /// If [lockParentWindow] is set, the child window (file picker window) will
  /// stay in front of the Flutter window until it is closed (like a modal
  /// window). This parameter works only on Windows desktop.
  ///
  /// [dialogTitle] can be optionally set on desktop platforms to set the modal window title. It will be ignored on
  /// other platforms.
  ///
  /// [initialDirectory] can be optionally set to an absolute path to specify
  /// where the dialog should open. Only supported on Linux, macOS, and Windows.
  ///
  /// The result is wrapped in a [FilePickerResult] which contains helper getters
  /// with useful information regarding the picked [List<PlatformFile>].
  ///
  /// For more information, check the [API documentation](https://github.com/miguelpruivo/flutter_file_picker/wiki/api).
  ///
  /// Returns `null` if aborted.
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
  }) async =>
      throw UnimplementedError('pickFiles() has not been implemented.');

  /// Asks the underlying platform to remove any temporary files created by this plugin.
  ///
  /// This typically relates to cached files that are stored in the cache directory of
  /// each platform and it isn't required to invoke this as the system should take care
  /// of it whenever needed. However, this will force the cleanup if you want to manage those on your own.
  ///
  /// This method is only available on mobile platforms (Android & iOS).
  ///
  /// Returns `true` if the files were removed with success, `false` otherwise.
  Future<bool?> clearTemporaryFiles() async => throw UnimplementedError(
      'clearTemporaryFiles() has not been implemented.');

  /// Selects a directory and returns its absolute path.
  ///
  /// On Android, this requires to be running on SDK 21 or above, else won't work.
  /// Note: Some Android paths are protected, hence can't be accessed and will return `/` instead.
  ///
  /// [dialogTitle] can be set to display a custom title on desktop platforms. It will be ignored on Web & IO.
  ///
  /// If [lockParentWindow] is set, the child window (file picker window) will
  /// stay in front of the Flutter window until it is closed (like a modal
  /// window). This parameter works only on Windows desktop.
  ///
  /// [initialDirectory] can be optionally set to an absolute path to specify
  /// where the dialog should open. Only supported on Linux and macOS.
  ///
  /// Returns a [Future<String?>] which resolves to  the absolute path of the selected directory,
  /// if the user selected a directory. Returns `null` if the user aborted the dialog or if the
  /// folder path couldn't be resolved.
  ///
  /// Note: on Windows, throws a `WindowsException` with a detailed error message, if the dialog
  /// could not be instantiated or the dialog result could not be interpreted.
  /// Note: Some Android paths are protected, hence can't be accessed and will return `/` instead.
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async =>
      throw UnimplementedError('getDirectoryPath() has not been implemented.');

  Future<PlatformFile?> getContentPath(String? path) async =>
      throw UnimplementedError('getDirectoryPath() has not been implemented.');

  /// Opens a save file dialog which lets the user select a file path and a file
  /// name to save a file.
  ///
  /// This function does not actually save a file. It only opens the dialog to
  /// let the user choose a location and file name. This function only returns
  /// the **path** to this (non-existing) file.
  ///
  /// This method is only available on desktop platforms (Linux, macOS &
  /// Windows).
  ///
  /// [dialogTitle] can be set to display a custom title on desktop platforms.
  ///
  /// [fileName] can be set to a non-empty string to provide a default file
  /// name. Throws an `IllegalCharacterInFileNameException` under Windows if the
  /// given [fileName] contains forbidden characters.
  ///
  /// [initialDirectory] can be optionally set to an absolute path to specify
  /// where the dialog should open. Only supported on Linux, macOS, and Windows.
  ///
  /// The file type filter [type] defaults to [FileType.any]. Optionally,
  /// [allowedExtensions] might be provided (e.g. `[pdf, svg, jpg]`.). Both
  /// parameters are just a proposal to the user as the save file dialog does
  /// not enforce these restrictions.
  ///
  /// If [lockParentWindow] is set, the child window (file picker window) will
  /// stay in front of the Flutter window until it is closed (like a modal
  /// window). This parameter works only on Windows desktop.
  ///
  /// Returns `null` if aborted. Returns a [Future<String?>] which resolves to
  /// the absolute path of the selected file, if the user selected a file.
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) async =>
      throw UnimplementedError('saveFile() has not been implemented.');
}
