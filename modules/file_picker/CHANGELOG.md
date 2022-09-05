## 4.5.1

#### Web
Adds `display:none` to the internal input element to fix a display issue in specific scenario's.

## 4.5.0

#### Desktop (Windows)
Changes the implementation of `getDirectoryPath()` on Windows to provide a modern dialog that looks the same as a file picker dialog ([#915](https://github.com/miguelpruivo/flutter_file_picker/issues/915)).

## 4.4.0

#### Desktop (Linux, macOS, and Windows)
Adds the additional parameter `initialDirectory` to configure the initial directory where the dialog should be opened. This parameter is supported for all three dialogs (pick files, pick directory, and save file). The only exception is that the parameter does not work on Windows for the function `getDirectoryPath()`. Please note that this feature has not been implemented for Android and iOS.

## 4.3.3

#### Desktop (Linux)
Introduces two fixes for the KDE Plasma Linux implementation which uses `kdialog` to open the file picker dialogs. Firstly, the selection of multiple files is fixed so that file paths with blanks/spaces are handled correctly. Secondly, file type filters are implemented. Thank you @w1th0utnam3.

## 4.3.2

#### Desktop (Windows)
Fixes the issue under Windows that the save-file dialog did not open if the specified file name contained an illegal character. Windows prohibits the usage of [reserved characters in file names](https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions). Now the exception `IllegalCharacterInFileNameException` is thrown if the specified file name contains forbidden characters
([#926](https://github.com/miguelpruivo/flutter_file_picker/issues/926)).

## 4.3.1

#### Desktop (Linux)
Adds KDE Plasma's `kdialog` arguments, allowing `filepicker` to invoke `kdialog` for file system manipulation using shell scripts on distributions that use KDE Plasma as their Desktop Environment and don't ship `zenity` or `qarma`.

## 4.3.0

##### Desktop (Windows)
Adds the parameter `lockParentWindow` for Windows desktop. This parameter makes the file picker dialog behave like a modal window. That is, the file picker always stays in front of the Flutter window until it is closed. Thank you @vinicios-cervantes.

## 4.2.8

##### Desktop (Windows)
Fixes the issue under Windows that the user could not select more than about 256 files (depending on the length of the file paths) because the buffer size for storing the selected file paths was too small. ([#918](https://github.com/miguelpruivo/flutter_file_picker/issues/918)).


## 4.2.7

##### Desktop (macOS & Windows)
Fixes the issue under Windows that the user could select all file types even though a file type filter was enabled. This error existed because the user could select the entry `All Files (*.*)` in the file type filter dropdown. Also, fixes the bug under macOS that users could select files without file extension even when one of the pre-defined file type filters (audio, image, video, or media) was enabled. ([#871](https://github.com/miguelpruivo/flutter_file_picker/issues/871)).

## 4.2.6

##### Android
Fixes linting error during builds ([#851](https://github.com/miguelpruivo/flutter_file_picker/issues/851)).

## 4.2.5

##### Desktop (macOS)
Fixes the issue of picking filenames that contain a comma followed by a space ([#890](https://github.com/miguelpruivo/flutter_file_picker/issues/890)).

## 4.2.4

##### iOS
Improves error handling when device can't fetch files due to low storage space ([#885](https://github.com/miguelpruivo/flutter_file_picker/issues/885)).

## 4.2.3

##### iOS
Fixed an issue that was creating a crash when media in PHPickerViewController in iOs was tapped several times very fast, we check that _result is not empty to avoid the crash. No Github issue created.

## 4.2.2+1

##### Android
Reverts Android `READ_EXTERNAL_STORAGE` permission removal.

## 4.2.2

##### Android
Removes `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>` permission from the platform implementation Manifest since may not be required for some applications and devs can manually add it to their own application if needed ([#864](https://github.com/miguelpruivo/flutter_file_picker/issues/864)).

## 4.2.1

##### Android
Fixes an issue where `onFileLoading` would be called while picking directories ([#863](https://github.com/miguelpruivo/flutter_file_picker/issues/863)).

## 4.2.0

Adds the `identifier` property to the `PlatformFile` which references the original file identifier for both iOS & Android ([#804](https://github.com/miguelpruivo/flutter_file_picker/issues/804)).

## 4.1.6
##### Desktop (macOS)
Fixes the issue that users could not pick `.app` files on macOS because FilePicker tried to determine the file size of `.app` files. On macOS, these special kind of files are actually Unix directories in a special format ([read more on StackExchange](https://apple.stackexchange.com/a/112213)). Now, if a file is picked, which is actually a directory, then the file size will be zero. ([#856](https://github.com/miguelpruivo/flutter_file_picker/issues/856))

## 4.1.5
##### Web
- Fixes an issue that would prevent the call to return when both `withReadStream` and `allowMultiple` were set. ([#843](https://github.com/miguelpruivo/flutter_file_picker/issues/843)).
- Addresses an issue in the example app.

## 4.1.4
##### Android
Addresses an issue where multiple media files couldn't be picked in some 3rd party explorers ([#846](https://github.com/miguelpruivo/flutter_file_picker/issues/846)). Thank you @innim98.

## 4.1.3
##### iOS
Fixes an issue where Live Photos were being picked as `.pvt` packages (since iOS 15). From now on, if `allowCompression` is set to `true`, Live Photos will automatically be converted to static JPEG pictures. ([#835](https://github.com/miguelpruivo/flutter_file_picker/issues/835)) 

## 4.1.2
##### Desktop (Linux)
Fixes the issue that on Linux the file type filter `FileType.any` did not allow the selection of files without file extension. ([#836](https://github.com/miguelpruivo/flutter_file_picker/issues/836))

## 4.1.1
##### iOS
Fixes an issue that would result in picker being dismissed by pulling down the modal sheet without an event. ([#828](https://github.com/miguelpruivo/flutter_file_picker/issues/828))

##### Web
Addresses an issue when comparing files on Web would result in an error due to `path` not being accessible. ([#822](https://github.com/miguelpruivo/flutter_file_picker/issues/822)) 

## 4.1.0
Extends API by new function `saveFiles()` for opening a save-file dialog as requested in [#799](https://github.com/miguelpruivo/flutter_file_picker/issues/799). This feature is only supported on desktop platforms (Linux, macOS, and Windows).

## 4.0.3
Makes the `path` getter nullable to match with its property ([#823](https://github.com/miguelpruivo/flutter_file_picker/issues/823)).

## 4.0.2
##### Desktop (Windows)
Fixes custom extension filter. Thank you @jgoyvaerts.

## 4.0.1
##### General
Overrides equality and toString for `platform_file` and `file_picker_result` for better comparison different results. Thank you @Nolence.
##### iOS
- Changes the presentation type of the picker from `UIModalPresentationCurrentContext` to `UIModalPresentationAutomatic` ([#813](https://github.com/miguelpruivo/flutter_file_picker/issues/813)).

##### Web
- Fixes regression of [#746](https://github.com/miguelpruivo/flutter_file_picker/issues/746).
- Updates exception text when trying to access `path` on Web. Thank you @maxzod.

## 4.0.0
### Desktop support added for all platforms (MacOS, Linux & Windows) ([#271](https://github.com/miguelpruivo/flutter_file_picker/issues/271)) 🎉
From now on, you'll be able to use file_picker with all your platforms, a big thanks to @philenius, which made this possible and allowed the [flutter_file_picker_desktop](https://github.com/philenius/flutter_file_picker_desktop) to be merged with this one.

Have in mind that because of platforms differences, that the following API methods aren't available to use on Desktop:
- The `onFileLoading()` isn't necessary, hence, `FilePickerStatus` won't change, since it hasn't any effect on those;
- `clearTemporaryFiles()` isn't necessary since those files aren't created — the platforms will always use a reference to the original file;
- There is a new optional parameter `dialogTitle` which can be used to set the title of the modal dialog when picking the files;

##### Web
Adds `onFileLoading()` to Web. ([#766](https://github.com/miguelpruivo/flutter_file_picker/issues/766)).

## 3.0.4
##### Android
- Addresses an issue where an invalid custom file extension wouldn't throw an error when it should. Thank you @Jahn08.
- Fixes `getDirectoryPath()` [#745](https://github.com/miguelpruivo/flutter_file_picker/issues/745). Thank you @tomm1e.

## 3.0.3

#### Web
- Removes analysis_options.yaml from the plugin and fixes the _Don't import implementation files from another package_ warning (#746).
#### Android
- Addresses an issue where bytes might be missing after first picking when `withData` is set to `true`. ([#616](https://github.com/miguelpruivo/flutter_file_picker/issues/616)).

#### Desktop (GO)
- Patches README import path. (Thank you @voynichteru)

## 3.0.2+2
- Fixes [#725](https://github.com/miguelpruivo/flutter_file_picker/issues/725).

## 3.0.2
##### General
- `name` and `size` properties are now non-nullable types.
##### Docs
- Updates README;
- Updates API docs;

##### Example
- Updates Android example app to V2;
##### Android
- Removes deprecated call warnings;

##### Other
- Adds analysis_options.yaml with linter rule to surpress warnings from generated_plugin_registrant.

## 3.0.1
#### Android
- Use MediaStore Opener (which goes through the gallery) instead of default explorer. (Thank you @tmthecoder).

#### Web
- Add event when canceling the picker. (Thank you @letranloc).

#### Other
- Updates example app to null safety.

## 3.0.0
Adds null safety support ([#510](https://github.com/miguelpruivo/flutter_file_picker/issues/510)).
## 2.1.7
### iOS
- Fixes an issue where a crash could happen when picking a lot of media files in low memory devices ([#606](https://github.com/miguelpruivo/flutter_file_picker/issues/606)).
- Updates `preferredAssetRepresentationMode`. Thank you @nrikiji.

## 2.1.6
- Addresses an issue on iOS 14 and later where events `onFileLoading` events weren't being provided ([#577](https://github.com/miguelpruivo/flutter_file_picker/issues/577)). 

## 2.1.5+1
- Web: Updates `size` property from `PlatformFile` to be in bytes instead of kb;
- Applies minor refactor to example app. Thank you @Abhishek01039;

## 2.1.5
iOS & Android: Updates `size` property from `PlatformFile` to be in bytes instead of kb.

## 2.1.4
iOS: Fixes iOS ViewController which is nil when UIWindow.rootViewController have changed. ([#525](https://github.com/miguelpruivo/flutter_file_picker/issues/525)). Thank you @devcxm. 

## 2.1.3
Android: Updates file name handling method. ([#487](https://github.com/miguelpruivo/flutter_file_picker/issues/487))

## 2.1.2
Desktop (Go): Fixed desktop plugin implementation. Thank you @DenchikBY. ([#382](https://github.com/miguelpruivo/flutter_file_picker/issues/382#issuecomment-744055654))

## 2.1.1
iOS: Fixes an issue that could result in a crash when selecting a media item twice. ([#518](https://github.com/miguelpruivo/flutter_file_picker/issues/518))

## 2.1.0
Adds `withReadStream` that allows bigger files to be streamed read into a `Stream<List<int>>`. Thanks @redsolver.

## 2.0.13
Updates `extension` helper getter to use the `name` property instead of `path`, since the latest isn't available on the Web, hence, the extension wouldn't be as well. Thank you @markgrancapal.

## 2.0.12
Android:

- Fixes an issue that could result in some files not being properly retrieved due to special characters on their names. ([#472](https://github.com/miguelpruivo/flutter_file_picker/issues/472))
- Fixes a NPE that could happen with some devices. ([#482](https://github.com/miguelpruivo/flutter_file_picker/issues/482))


## 2.0.11
iOS: Fixes `FileType.audio` exports to support ipod-library content (non DRM protected). From now on, a cached asset (m4a) will be exported from the selected music file in the Music app, so it can later be used. Fixes ([#441](https://github.com/miguelpruivo/flutter_file_picker/issues/441)).

## 2.0.10
Adds missing extension to `name` property of `PlatformFile`. ([#444](https://github.com/miguelpruivo/flutter_file_picker/issues/444))

## 2.0.9+1
Minor fix on CHANGELOG regarding version `2.0.9`.

## 2.0.9
Android: Updates package visibility to fully support Android 11 (SDK 30 and later). ([#440](https://github.com/miguelpruivo/flutter_file_picker/issues/440))

*Note: If you have build issues from now on because `<queries>` aren't recognized, you'll need to update your build.gradle to use one of the [following patched versions](https://github.com/miguelpruivo/flutter_file_picker/wiki/Troubleshooting#android).* 

## 2.0.8+1
- iOS: Updates media picker to launch in app context (instead of modal).
- Minor update to README file.

## 2.0.8
Fixes an issue on iOS 14, where canceling with swipe gestures, could result in cancel event not being dispatched. ([#431](https://github.com/miguelpruivo/flutter_file_picker/issues/431)).

## 2.0.7
Fixes [#425](https://github.com/miguelpruivo/flutter_file_picker/issues/425) and updates iOS to use NSDocumentDirectory on iOS 12 or lower. Thanks @allanwolski. 

## 2.0.6
iOS: Fixes iOS 14 media picker (image & video) (#405, #407).

## 2.0.5
Android: Fixes [#402](https://github.com/miguelpruivo/flutter_file_picker/issues/402).

## 2.0.4
Desktop (Go): Fixes directory pick on Linux.

## 2.0.3
Android: Fixes out of memory issue on some devices when picking big files.

## 2.0.2+2
Fixes multi-pick example on README.

## 2.0.2+1
iOS: Fixes conditional import for backwards compatibility with Xcode 11.

## 2.0.2
Web: Adds mobile Safari support and other minor improvements.
iOS: Adds conditional import for backwards compatibility with Xcode 11.

## 2.0.1+2
iOS: Addresses an issue that could prevent users from viewing picked media elements (pictures/videos) from gallery on iOS 14.

## 2.0.1+1
Fixes README screenshots.

## 2.0.1
iOS: Updates picker to use new PHPickerController for both single and multi media (image/video) picks (iOS 14 and above only).

## 2.0.0
**Breaking Changes**
- Unifies all platforms (IO, Web and Desktop) in a single plugin (file_picker) that can be used seamlessly across all. Both [file_picker_interface](https://pub.dev/packages/file_picker_platform_interface) and [file_picker_web](https://pub.dev/packages/file_picker_web) are no longer mantained from now on.
- You'll now have to use `FilePicker.platform.pickFiles()` and extract the files from `FilePickerResult`;
- Because platforms are unified and mixing `File` instances from dart:io and dart:html required stubbing and bloated code, it's no longer available as helper method so you'll have to instanciate a `File` with the picked paths;

**New features**
- Simplified usage, now you only need to use `FilePicker.platform.pickFiles()` with desired parameters which will return a `FilePickerResult` with a `List<PlatformFile>` containing the picked data;
- Added classes `FilePickerResult` and `PlatformFile` classes with helper getters;
- On Android all picked files are scoped cached which should result in most of files being available. Caching process is only made once, so once done, the picked instance should be the same;
- On iOS picking audio now supports multiple and cloud picks;
- Added parameter `withData` that allows file data to be immediately available on memory as `Uint8List` (part of `PlatformFile` instance). This is particularly helpful on web or if you are going to upload to somehwere else;
- Major refactor with some clean-up and improvements;

**Removed**
- Single methods such as `getFilePath()`, `getMultiFilePath()`, `getFile()` and `getMultiFile()` are no longer availble in favor o `pickFiles()`;

## 1.13.3
Go: Updates MacOS directory picker to applescript (thank you @trister1997).

## 1.13.2
Android: fixes picking paths from Downloads directory on versions below Android Q.

## 1.13.1
Android: adds support to non-legacy picking on Android Q or above (thank you @lakshyab1995).

## 1.13.0+1
Fixes an issue that could prevent `1.13.0` from being built due to missing `allowCompression` property.

## 1.13.0
Adds `allowCompression` property that will define if media (video & image) files are allowed to be compressed by OS when picked. On Android this has no effect as it already returns the original file or an integral copy.

## 1.12.0
Adds `getDirectoryPath()` desktop (go) implementation.

## 1.11.0+3
Updates tearDown() call order on Android's implementation.

## 1.11.0+2
Updates README file (iOS preview).

## 1.11.0+1
Updates README file.

## 1.11.0
Adds `onFileLoading` handler for every picking method that will provide picking status: `FilePickerStatus.loading` and `FilePickerStatus.done` so you can, for example, display a custom loader.

## 1.10.0
Adds `getDirectoryPath()` method that allows you to select and pick directory paths. Android, requires SDK 21 or above for this to work, and iOS requires iOS 11 or above. 

## 1.9.0+1
Adds a temporary workaround on Android where it can trigger `onRequestPermissionsResult` twice, related to Flutter issue [49365](https://github.com/flutter/flutter/issues/49365) for anyone affected in Flutter versions below 1.14.6.

## 1.9.0
Adds `clearTemporaryFiles()` that allows you to explicitly remove cached files — on Android applies typically to those picked from remote providers, on iOS _all_ picked files are cached.

## 1.8.0+2
Updates podspec to use only PhotoGallery from DKImagePickerController (thanks @jamesdixon!)

## 1.8.0+1
Minor fix on `getFile()` method — should affect only those on 1.8.0.

## 1.8.0
Adds `FileType.media` that will allow you to pick video and images at the same time. On iOS, this will let you pick directly from Photos app (gallery), if you want to use Files app, you _must_ use `FileType.custom` with desired extensions.

## 1.7.1
Updates iOS multi gallery picker dependency and adds a modal loading while fetching exporting assets.

## 1.7.0
**Breaking change**

Added support for multi-picks of videos and photos from Photos app on iOS through [DKImagePicker](https://github.com/zhangao0086/DKImagePickerController) — use any of the `getMulti` methods with `FileType.image` or `FileType.video`. From now on, you'll need to add `use_frameworks!` in your ios/Podfile.

## 1.6.3+2
* Fixes a crash on Android when a file has an id that can't be resolved and uses a name instead (#221);
* Minor fix on Go (Desktop) - Windows (thanks @marchellodev);

## 1.6.3+1
Addresses an issue with plugin calls on Go (Desktop) - Linux & Windows

## 1.6.3
Addresses an issue with plugin calls on Go (Desktop) - MacOS

## 1.6.2
Updates Go (Desktop) to support multiple extension filters.

## 1.6.1
Addresses an issue that could result in permission handler resolving requests from other activities.

## 1.6.0

* Adds multiple file extension filter support. From now on, you _must_ provide a `List` of extensions with type `FileType.custom` when restricting types while picking.
* Other minor improvements;

## 1.5.1

* iOS: Fixes an issue that could result in a crash when selecting files (with repeated taps) from 3rd party remote providers (Google Drive, Dropbox etc.);
* Go: Updates channel name;
* Adds check that ensures that you one uses `FileType.custom` when providing a custom file extension filter;

## 1.5.0+2
Updates channel name on iOS.

## 1.5.0+1
Adds temporary workaround for (#49365)(https://github.com/flutter/flutter/issues/49365) until 1.14.6 lands on stable channel.

## 1.5.0

* **Breaking change:** Refactored `FileType` to match lower camelCase Dart guideline (eg. `FileType.ALL` now is `FileType.all`);
* Added support for new [Android plugins APIs](https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration) (Android V2 embedding);

## 1.4.3+2
Updates dependencies.

## 1.4.3+1
Removes checked flutter_export_environment.sh from example app.

## 1.4.3

**Bug fix**
 * Fixes an issue that could result in a crash when tapping multiple times in the same media file while picking, on some iOS devices (#171).

## 1.4.2+1
Updates go-flutter dependencies.

## 1.4.2

**Bug fix**
 * Fixes an issue that could cause a crash when picking video files in iOS 13 or above due to SDK changes.
 * Updates Go-Flutter with go 1.13.

## 1.4.1

**Bug fix:** Fixes an issue that could result in some cached files, picked from Google Photos (remote file), to have the name set as `null`.

## 1.4.0+1

**Bug fix:** Fixes an issue that could prevent internal storage files from being properly picked. 

## 1.4.0

**New features**
 * Adds Desktop support throught **[go-flutter](https://github.com/go-flutter-desktop/go-flutter)**, you can see detailed instructions on how to get in runing [here](https://github.com/go-flutter-desktop/hover).
 * Adds Desktop example, to run it just do `hover init` and then `hover run` within the plugin's example folder (you must have go and hover installed, check the previous point).
 * Similar to `getFile`, now there is also a `getMultiFile` which behaves the same way, but returning a list of files instead.

**Improvements**
 * Updates Android SDK deprecated code.
 * Sometimes when a big file was being picked from a remote directory (GDrive for example), the UI could be blocked. Now this shouldn't happen anymore.

## 1.3.8

**Bug fix:** Fixes an issue that could cause a crash when picking files with very long names.

**Changes:** Updates Android target API to 29.

## 1.3.7

**Rollback - Breaking change:** Re-adds runtime verification for external storage read permission. Don't forget to add the permission to the `AndroidManifest.xml` file as well. More info in the README file.

**Bug fix:** Fixes a crash that could cause some Android API to crash when multiple files were selected from external storage.

## 1.3.6

**Improvements**
 * Removes the Android write permissions requirement.
 * Minor improvements in the example app.
 * Now the exceptions are rethrown in case the user wants to handle them, despite that already being done in the plugin call.

## 1.3.5

**Bug fix:** Fixes an issue that could prevent users to pick files from the iCloud Drive app, on versions below iOS 11. 

## 1.3.4+1

**Rollback:** Removes a local dependency that shouldn't have been committed with `1.3.4` which would cause Android build to fail.

## 1.3.4

**Bug fix:** Protects the `registrar.activity()` in the Android side of being accessed when it's `null`.

## 1.3.3

**Bug fixes**
 * Fixes an issue where sometimes a single file path was being returned as a `List` instead of `String`.
 * `requestCode` in Android intents are now restricted to 16 bits.

## 1.3.2

**Bug fix:** Returns a `null` value in the `getFile()` when the picker is canceled.

## 1.3.1

**Bug fix:** Fixes an issue on Android, where other activity would try to call `FilePicker`'s result object when it shouldn't.  

## 1.3.0

**Breaking changes**
 * `FileType.CAMERA` is no longer available, if you need it, you can use this package along with [image_picker](https://pub.dartlang.org/packages/image_picker).
 
**New features**
 * You can now pick multiple files by using the `getMultiFilePath()` method which will return a `Map<String,String>` with all paths from selected files, where the key matches the file name and the value its path. Optionally, it also supports filtering by file extension, otherwise all files will be selectable. Nevertheless, you should keep using `getFilePath()` for single path picking.
 * You can now use `FileType.AUDIO` to pick audio files. In iOS this will let you select from your music library. Paths from DRM protected files won't be loaded (see README for more details).
 * Adds `getFile()` utility method that does the same of `getFilePath()` but returns a `File` object instead, for the returned path.
 
**Bug fixes and updates**
 * This package is no longer attached to the [image_picker](https://pub.dartlang.org/packages/image_picker), and because of that, camera permission is also no longer required.
 * Fixes an issue where sometimes the _InputStream_ wasn't being properly closed. Also, its exception is now being forward to the plugin caller.
 * Fixes an issue where the picker, when canceled, wasn't calling the result callback on the underlying platforms.

## 1.2.0

**Breaking change**: Migrate from the deprecated original Android Support Library to AndroidX. This shouldn't result in any functional changes, but it requires any Android apps using this plugin to [also migrate](https://developer.android.com/jetpack/androidx/migrate) if they're using the original support library.

## 1.1.1

* Updates README file.

## 1.1.0

**Breaking changes** 
 * `FileType.PDF` was removed since now it can be used along with custom file types by using the `FileType.CUSTOM` and providing the file extension (e.g. PDF, SVG, ZIP, etc.).
 * `FileType.CAPTURE` is now `FileType.CAMERA`
 
**New features**
 * Now it is possible to provide a custom file extension to filter file picking options by using `FileType.CUSTOM`
 
**Bug fixes and updates**
 * Fixes file names from cloud on Android. Previously it would always display **Document**
 * Fixes an issue on iOS where an exception was being thrown after canceling and re-opening the picker.
 * Fixes an issue where collision could happen with request codes on Android.
 * Adds public documentation to `file_picker`
 * Example app updated.
 * Updates .gitignore

## 1.0.3

 * Fixes `build.gradle`.  

## 1.0.2

 * Minor update of README file. 

## 1.0.1

 * Adds comments for public API

## 1.0.0

 * **Version 1.0** release.
 * Adds support for ANY and VIDEO files.
 * Fixes an issue where permissions were recursively asked on Android.
 * Fixes an issue where some paths from document files couldn't be loaded with Android 8.0.
 * Updates README file to match changes. 
 * General refactor & cleanup. 

## 0.1.6
* Replaces commons dependency with FilePath class on Android, to handle path resolution on different SDK. 

## 0.1.5
* Minor correction in the README file. 

## 0.1.4
* Changed Meta minimum version due to versioning conflict with flutter_localization. 

## 0.1.3

* Updated readme.

## 0.1.2

* Changed license from Apache 2.0 to MIT. 
* Adds demo screenshot.

## 0.1.1

* Adds license information (Apache 2.0).
* Adds CHANGELOG details.

## 0.1.0

* Initial release.
* Supports picking paths from files on local storage, cloud.
* Supports picking paths from both gallery & camera due to [image_picker](https://pub.dartlang.org/packages/image_picker) dependency.
