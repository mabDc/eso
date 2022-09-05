![fluter_file_picker](https://user-images.githubusercontent.com/27860743/64064695-b88dab00-cbfc-11e9-814f-30921b66035f.png)
<p align="center">
 <a href="https://pub.dartlang.org/packages/file_picker">
    <img alt="File Picker" src="https://img.shields.io/pub/v/file_picker.svg">
  </a>
 <a href="https://github.com/Solido/awesome-flutter">
    <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square">
  </a>
 <a href="https://codemagic.io/apps/5ce89f4a9b46f5000ca89638/5ce89f4a9b46f5000ca89637/latest_build">
    <img alt="Build Status" src="https://api.codemagic.io/apps/5ee2d379c2d4737a756cbd00/5ee2d379c2d4737a756cbcff/status_badge.svg">
  </a>
 <a href="https://www.buymeacoffee.com/gQyz2MR">
    <img alt="Buy me a coffee" src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg">
  </a>
  <a href="https://github.com/miguelpruivo/flutter_file_picker/issues"><img src="https://img.shields.io/github/issues/miguelpruivo/flutter_file_picker">
  </a>
  <img src="https://img.shields.io/github/license/miguelpruivo/flutter_file_picker">
  <a href="https://github.com/miguelpruivo/flutter_file_picker/actions/workflows/main.yml">
    <img alt="CI pipeline status" src="https://github.com/miguelpruivo/flutter_file_picker/actions/workflows/main.yml/badge.svg">
  </a>
</p>

# File Picker
A package that allows you to use the native file explorer to pick single or multiple files, with extensions filtering support.

## Currently supported features
* Uses OS default native pickers
* Supports multiple platforms (Mobile, Web, Desktop and Flutter GO)
* Pick files using  **custom format** filtering — you can provide a list of file extensions (pdf, svg, zip, etc.)
* Pick files from **cloud files** (GDrive, Dropbox, iCloud)
* Single or multiple file picks
* Different default type filtering (media, image, video, audio or any)
* Picking directories
* Load file data immediately into memory (`Uint8List`) if needed; 
* Open a save-file / save-as dialog (a dialog that lets the user specify the drive, directory, and name of a file to save)

If you have any feature that you want to see in this package, please feel free to issue a suggestion. 🎉

## Compatibility Chart

| API                   | Android            | iOS                | Linux              | macOS              | Windows            | Web                |
| --------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| clearTemporaryFiles() | :white_check_mark: | :white_check_mark: | :x:                | :x:                | :x:                | :x:                |
| getDirectoryPath()    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x:                |
| pickFiles()           | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| saveFile()            | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x:                |

See the [API section of the File Picker Wiki](https://github.com/miguelpruivo/flutter_file_picker/wiki/api) or the [official API reference on pub.dev](https://pub.dev/documentation/file_picker/latest/file_picker/FilePicker-class.html) for further details.


## Documentation
See the **[File Picker Wiki](https://github.com/miguelpruivo/flutter_file_picker/wiki)** for every detail on about how to install, setup and use it.

### File Picker Wiki

1. [Installation](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/Installation)
2. [Setup](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/Setup)
   * [Android](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/Setup#android)
   * [iOS](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/Setup#ios)
   * [Web](https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#--web)
   * [Desktop (go-flutter)](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/Setup/_edit#desktop-go-flutter)
3. [API](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/api)
   * [Filters](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/API#filters)
   * [Parameters](https://github.com/miguelpruivo/flutter_file_picker/wiki/API#parameters)
   * [Methods](https://github.com/miguelpruivo/plugins_flutter_file_picker/wiki/API#methods)
4. [FAQ](https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ)
5. [Troubleshooting](https://github.com/miguelpruivo/flutter_file_picker/wiki/Troubleshooting)

## Usage
Quick simple usage example:

#### Single file
```dart
FilePickerResult? result = await FilePicker.platform.pickFiles();

if (result != null) {
  File file = File(result.files.single.path);
} else {
  // User canceled the picker
}
```
#### Multiple files
```dart
FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

if (result != null) {
  List<File> files = result.paths.map((path) => File(path)).toList();
} else {
  // User canceled the picker
}
```
#### Multiple files with extension filter
```dart
FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['jpg', 'pdf', 'doc'],
);
```
#### Pick a directory
```dart
String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

if (selectedDirectory == null) {
  // User canceled the picker
}
```
#### Save-file / save-as dialog
```dart
String? outputFile = await FilePicker.platform.saveFile(
  dialogTitle: 'Please select an output file:',
  fileName: 'output-file.pdf',
);

if (outputFile == null) {
  // User canceled the picker
}
```
### Load result and file details
```dart
FilePickerResult? result = await FilePicker.platform.pickFiles();

if (result != null) {
  PlatformFile file = result.files.first;

  print(file.name);
  print(file.bytes);
  print(file.size);
  print(file.extension);
  print(file.path);
} else {
  // User canceled the picker
}
```
#### Pick and upload a file to Firebase Storage with Flutter Web
```dart
FilePickerResult? result = await FilePicker.platform.pickFiles();

if (result != null) {
  Uint8List fileBytes = result.files.first.bytes;
  String fileName = result.files.first.name;
  
  // Upload file
  await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes);
}
```

For full usage details refer to the **[Wiki](https://github.com/miguelpruivo/flutter_file_picker/wiki)** above.

## Example App
#### Android
![Demo](https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/screenshots/example.gif)
#### iOS
![DemoMultiFilters](https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/screenshots/example_ios.gif)
#### MacOS
![DemoMacOS](https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/screenshots/example_macos.png)
#### Linux
![DemoLinux](https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/screenshots/example_linux.png)
#### Windows
![DemoWindows](https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/screenshots/example_windows.png)

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).



