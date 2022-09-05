import 'package:file_picker/src/platform_file.dart';
import 'package:flutter/foundation.dart';

class FilePickerResult {
  const FilePickerResult(this.files);

  /// Picked files.
  final List<PlatformFile> files;

  /// If this pick contains only a single resource.
  bool get isSinglePick => files.length == 1;

  /// The length of picked files.
  int get count => files.length;

  /// A `List<String>` containing all paths from picked files.
  ///
  /// This may or not be available and will typically reference cached copies of
  /// original files (which can be accessed through its URI property).
  ///
  /// Only available on IO. Throws `UnsupportedError` on Web.
  List<String?> get paths => files
      .map((file) => kIsWeb
          ? throw UnsupportedError(
              'Picking paths is unsupported on Web. Please, use bytes property instead.')
          : file.path)
      .toList();

  /// A `List<String>` containing all names from picked files with its extensions.
  List<String?> get names => files.map((file) => file.name).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FilePickerResult && listEquals(other.files, files);
  }

  @override
  int get hashCode => files.hashCode;

  @override
  String toString() => 'FilePickerResult(files: $files)';
}
