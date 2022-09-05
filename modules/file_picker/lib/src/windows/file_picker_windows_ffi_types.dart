import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Function from Win32 API to display a dialog box that enables the user to select a Shell folder.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shbrowseforfolderw
typedef SHBrowseForFolderW = Pointer Function(
  /// A pointer to a [BROWSEINFOA] structure that contains information used to display the dialog box.
  Pointer lpbi,
);

/// Function from Win32 API to create an Open dialog box that lets the user specify the drive,
/// directory, and the name of a file or set of files to be opened.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/commdlg/nf-commdlg-getopenfilenamew
typedef GetOpenFileNameW = Int8 Function(
  /// A pointer to an [OPENFILENAMEW] structure that contains information used to initialize the
  /// dialog box. When GetOpenFileName returns, this structure contains information about the user's
  /// file selection.
  Pointer unnamedParam1,
);

/// Dart equivalent of [GetOpenFileNameW].
typedef GetOpenFileNameWDart = int Function(
  Pointer unnamedParam1,
);

/// Function from Win32 API to convert an item identifier list to a file system path.
///
/// Returns `true` if successful; otherwise, `false`.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetpathfromidlistw
typedef SHGetPathFromIDListW = Int8 Function(
  /// The address of an item identifier list that specifies a file or directory location relative to
  /// the root of the namespace (the desktop).
  Pointer pidl,

  /// The address of a buffer to receive the file system path. This buffer must be at least
  /// [maximumPathLength] characters in size.
  Pointer<Utf16> pszPath,
);

/// Dart equivalent of [SHGetPathFromIDListW].
typedef SHGetPathFromIDListWDart = int Function(
  Pointer pidl,
  Pointer<Utf16> pszPath,
);

/// Function from Win32 API to create a save dialog box that lets the user
/// specify the drive, directory, and name of a file to save.
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/commdlg/nf-commdlg-getsavefilenamew
typedef GetSaveFileNameW = Int8 Function(
  /// A pointer to an [OPENFILENAMEW] structure that contains information used
  /// to initialize the dialog box. When the function [GetSaveFileNameW]
  /// returns, this structure contains information about the user's file
  /// selection.
  Pointer unnamedParam1,
);

/// Dart equivalent of [GetSaveFileNameW]
typedef GetSaveFileNameWDart = int Function(
  Pointer unnamedParam1,
);

/// Struct from Win32 API that contains parameters for the [SHBrowseForFolderW] function and receives
/// information about the folder selected by the user.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/ns-shlobj_core-browseinfoa
class BROWSEINFOA extends Struct {
  /// A handle to the owner window for the dialog box.
  external Pointer hwndOwner;

  /// A PIDL that specifies the location of the root folder from which to start browsing. Only the
  /// specified folder and its subfolders in the namespace hierarchy appear in the dialog box. This
  /// member can be `null`; in that case, a default location is used.
  external Pointer pidlRoot;

  /// Pointer to a buffer to receive the display name of the folder selected by the user. The size
  /// of this buffer is assumed to be [maximumPathLength] characters.
  external Pointer<Utf16> pszDisplayName;

  /// Pointer to a null-terminated string that is displayed above the tree view control in the dialog
  /// box. This string can be used to specify instructions to the user.
  external Pointer lpszTitle;

  /// Flags that specify the options for the dialog box. This member can be 0 or a combination of the
  /// following values.
  @Uint32()
  external int ulFlags;

  /// Pointer to an application-defined function that the dialog box calls when an event occurs. For
  /// more information, see the BrowseCallbackProc function. This member can be `null`.
  external Pointer lpfn;

  /// An application-defined value that the dialog box passes to the callback function, if one is
  /// specified in [lpfn].
  external Pointer lParam;

  /// An [int] value that receives the index of the image associated with the selected folder, stored
  /// in the system image list.
  @Uint32()
  external int iImage;
}

/// Struct from Win32 API that contains parameters for the [GetOpenFileNameW] function and receives
/// information about the file(s) selected by the user.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/commdlg/ns-commdlg-openfilenamew
class OPENFILENAMEW extends Struct {
  /// The length, in bytes, of the structure. Use sizeof [OPENFILENAMEW] for this parameter.
  @Uint32()
  external int lStructSize;

  /// A handle to the window that owns the dialog box. This member can be any valid window handle, or it can be `null` if the dialog box has no owner.
  external Pointer hwndOwner;

  /// If the OFN_ENABLETEMPLATEHANDLE flag is set in the Flags member, hInstance is a handle to a memory object containing a dialog box template. If the OFN_ENABLETEMPLATE flag is set, hInstance is a handle to a module that contains a dialog box template named by the lpTemplateName member. If neither flag is set, this member is ignored. If the OFN_EXPLORER flag is set, the system uses the specified template to create a dialog box that is a child of the default Explorer-style dialog box. If the OFN_EXPLORER flag is not set, the system uses the template to create an old-style dialog box that replaces the default dialog box.
  external Pointer hInstance;

  /// A buffer containing pairs of null-terminated filter strings. The last string in the buffer must be terminated by two `null` characters.
  external Pointer<Utf16> lpstrFilter;

  /// A static buffer that contains a pair of null-terminated filter strings for preserving the filter pattern chosen by the user.
  external Pointer<Utf16> lpstrCustomFilter;

  /// The size, in characters, of the buffer identified by [lpstrCustomFilter]. This buffer should be at least 40 characters long. This member is ignored if [lpstrCustomFilter] is `null` or points to a `null` string.
  @Uint32()
  external int nMaxCustFilter;

  /// The index of the currently selected filter in the File Types control.
  @Uint32()
  external int nFilterIndex;

  /// The file name used to initialize the File Name edit control. The first character of this buffer must be `null` if initialization is not necessary.
  external Pointer<Utf16> lpstrFile;

  /// The size, in characters, of the buffer pointed to by lpstrFile. The buffer must be large enough to store the path and file name string or strings, including the terminating `null` character. The GetOpenFileName and GetSaveFileName functions return `false` if the buffer is too small to contain the file information. The buffer should be at least 256 characters long.
  @Uint32()
  external int nMaxFile;

  /// The file name and extension (without path information) of the selected file. This member can be `null`.
  external Pointer<Utf16> lpstrFileTitle;

  /// The size, in characters, of the buffer pointed to by [lpstrFileTitle]. This member is ignored if [lpstrFileTitle] is `null`.
  @Uint32()
  external int nMaxFileTitle;

  /// The initial directory. The algorithm for selecting the initial directory varies on different platforms.
  external Pointer<Utf16> lpstrInitialDir;

  /// A string to be placed in the title bar of the dialog box. If this member is `null`, the system uses the default title (that is, Save As or Open).
  external Pointer<Utf16> lpstrTitle;

  /// A set of bit flags you can use to initialize the dialog box. When the dialog box returns, it sets these flags to indicate the user's input.
  @Uint32()
  external int flags;

  /// The zero-based offset, in characters, from the beginning of the path to the file name in the string pointed to by [lpstrFile].
  @Uint16()
  external int nFileOffset;

  /// The zero-based offset, in characters, from the beginning of the path to the file name extension in the string pointed to by [lpstrFile].
  @Uint16()
  external int nFileExtension;

  /// The default extension. GetOpenFileName and GetSaveFileName append this extension to the file name if the user fails to type an extension.
  external Pointer<Utf16> lpstrDefExt;

  /// Application-defined data that the system passes to the hook procedure identified by the lpfnHook member. When the system sends the WM_INITDIALOG message to the hook procedure, the message's lParam parameter is a pointer to the OPENFILENAME structure specified when the dialog box was created. The hook procedure can use this pointer to get the lCustData value.
  external Pointer lCustData;

  /// A pointer to a hook procedure. This member is ignored unless the Flags member includes the OFN_ENABLEHOOK flag.
  external Pointer lpfnHook;

  /// The name of the dialog template resource in the module identified by the hInstance member. For numbered dialog box resources, this can be a value returned by the MAKEINTRESOURCE macro. This member is ignored unless the OFN_ENABLETEMPLATE flag is set in the Flags member. If the OFN_EXPLORER flag is set, the system uses the specified template to create a dialog box that is a child of the default Explorer-style dialog box. If the OFN_EXPLORER flag is not set, the system uses the template to create an old-style dialog box that replaces the default dialog box.
  external Pointer<Utf16> lpTemplateName;

  /// This member is reserved.
  external Pointer pvReserved;

  /// This member is reserved.
  @Uint32()
  external int dwReserved;

  /// A set of bit flags you can use to initialize the dialog box.
  @Uint32()
  external int flagsEx;
}

/// Only return file system directories. If the user selects folders that are not part of the file
/// system, the OK button is grayed.
const bifReturnOnlyFsDirs = 0x00000001;

/// Include an edit control in the browse dialog box that allows the user to type the name of an item.
const bifEditBox = 0x00000010;

/// Use the new user interface. Setting this flag provides the user with a larger dialog box that can
/// be resized. The dialog box has several new capabilities, including: drag-and-drop capability within
/// the dialog box, reordering, shortcut menus, new folders, delete, and other shortcut menu commands.
const bifNewDialogStyle = 0x00000040;

/// In the Windows API, the maximum length for a path is MAX_PATH, which is defined as 260 characters.
const maximumPathLength = 260;

/// The File Name list box allows multiple selections.
const ofnAllowMultiSelect = 0x00000200;

/// Indicates that any customizations made to the Open or Save As dialog box use the Explorer-style customization methods.
const ofnExplorer = 0x00080000;

/// The user can type only names of existing files in the File Name entry field.
const ofnFileMustExist = 0x00001000;

/// Hides the Read Only check box.
const ofnHideReadOnly = 0x00000004;
