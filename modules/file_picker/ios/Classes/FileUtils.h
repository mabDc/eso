//
//  FileUtils.h
//  Pods
//
//  Created by Miguel Ruivo on 05/12/2018.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

#ifdef DEBUG
#define Log(fmt, ...)            NSLog((@"\n\n***** " fmt @"\n* %s [Line %d]\n\n\n"), ##__VA_ARGS__, __PRETTY_FUNCTION__, __LINE__)
#else
#define Log(fmt, ...)
#endif

typedef NS_ENUM(NSInteger, MediaType) {
  VIDEO,
  IMAGE,
  MEDIA
};

@interface FileUtils : NSObject
+ (BOOL) clearTemporaryFiles;
+ (NSArray<NSString*>*) resolveType:(NSString*)type withAllowedExtensions:(NSArray<NSString*>*)allowedExtensions;
+ (MediaType) resolveMediaType:(NSString*)type;
+ (NSArray<NSDictionary*>*) resolveFileInfo:(NSArray<NSURL *> *)urls withData:(BOOL)loadData;
+ (NSURL*) exportMusicAsset:(NSString*)url withName: (NSString*)name;
@end



