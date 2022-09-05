#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

#if __has_include(<PhotosUI/PHPicker.h>) || __has_include("PHPicker.h")
#define PHPicker
#import <PhotosUI/PHPicker.h>
#endif

@interface FilePickerPlugin : NSObject<FlutterPlugin, FlutterStreamHandler, UIAdaptivePresentationControllerDelegate, UIDocumentPickerDelegate, UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MPMediaPickerControllerDelegate
#ifdef PHPicker
, PHPickerViewControllerDelegate
#endif
>
@end
