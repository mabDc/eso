#import "FilePickerPlugin.h"
#import "FileUtils.h"
#import "ImageUtils.h"

@import DKImagePickerController;

@interface FilePickerPlugin() <DKImageAssetExporterObserver>
@property (nonatomic) FlutterResult result;
@property (nonatomic) FlutterEventSink eventSink;
@property (nonatomic) UIImagePickerController *galleryPickerController;
@property (nonatomic) UIDocumentPickerViewController *documentPickerController;
@property (nonatomic) UIDocumentInteractionController *interactionController;
@property (nonatomic) MPMediaPickerController *audioPickerController;
@property (nonatomic) NSArray<NSString *> * allowedExtensions;
@property (nonatomic) BOOL loadDataToMemory;
@property (nonatomic) BOOL allowCompression;
@property (nonatomic) dispatch_group_t group;
@end

@implementation FilePickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"miguelruivo.flutter.plugins.filepicker"
                                     binaryMessenger:[registrar messenger]];
    
    FlutterEventChannel* eventChannel = [FlutterEventChannel
                                         eventChannelWithName:@"miguelruivo.flutter.plugins.filepickerevent"
                                         binaryMessenger:[registrar messenger]];
    
    FilePickerPlugin* instance = [[FilePickerPlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];
}

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (UIViewController *)viewControllerWithWindow:(UIWindow *)window {
    UIWindow *windowToUse = window;
    if (windowToUse == nil) {
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                windowToUse = window;
                break;
            }
        }
    }
    
    UIViewController *topController = windowToUse.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    return nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (_result) {
        result([FlutterError errorWithCode:@"multiple_request"
                                   message:@"Cancelled by a second request"
                                   details:nil]);
        _result = nil;
        return;
    }
    
    _result = result;
    
    if([call.method isEqualToString:@"clear"]) {
        _result([NSNumber numberWithBool: [FileUtils clearTemporaryFiles]]);
        _result = nil;
        return;
    }
    
    if([call.method isEqualToString:@"dir"]) {
        if (@available(iOS 13, *)) {
            [self resolvePickDocumentWithMultiPick:NO pickDirectory:YES];
        } else {
            _result([self getDocumentDirectory]);
            _result = nil;
        }
        return;
    }
    
    NSDictionary * arguments = call.arguments;
    BOOL isMultiplePick = ((NSNumber*)[arguments valueForKey:@"allowMultipleSelection"]).boolValue;
    
    self.allowCompression = ((NSNumber*)[arguments valueForKey:@"allowCompression"]).boolValue;
    self.loadDataToMemory = ((NSNumber*)[arguments valueForKey:@"withData"]).boolValue;
    
    if([call.method isEqualToString:@"any"] || [call.method containsString:@"custom"]) {
        self.allowedExtensions = [FileUtils resolveType:call.method withAllowedExtensions: [arguments valueForKey:@"allowedExtensions"]];
        if(self.allowedExtensions == nil) {
            _result([FlutterError errorWithCode:@"Unsupported file extension"
                                        message:@"If you are providing extension filters make sure that you are only using FileType.custom and the extension are provided without the dot, (ie., jpg instead of .jpg). This could also have happened because you are using an unsupported file extension. If the problem persists, you may want to consider using FileType.all instead."
                                        details:nil]);
            _result = nil;
        } else if(self.allowedExtensions != nil) {
            [self resolvePickDocumentWithMultiPick:isMultiplePick pickDirectory:NO];
        }
    } else if([call.method isEqualToString:@"video"] || [call.method isEqualToString:@"image"] || [call.method isEqualToString:@"media"]) {
        [self resolvePickMedia:[FileUtils resolveMediaType:call.method] withMultiPick:isMultiplePick withCompressionAllowed:self.allowCompression];
    } else if([call.method isEqualToString:@"audio"]) {
        [self resolvePickAudioWithMultiPick: isMultiplePick];
    } else {
        result(FlutterMethodNotImplemented);
        _result = nil;
    }
}

- (NSString*)getDocumentDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

#pragma mark - Resolvers
- (void)resolvePickDocumentWithMultiPick:(BOOL)allowsMultipleSelection pickDirectory:(BOOL)isDirectory {
    
    @try{
        self.documentPickerController = [[UIDocumentPickerViewController alloc]
                                         initWithDocumentTypes: isDirectory ? @[@"public.folder"] : self.allowedExtensions
                                         inMode: isDirectory ? UIDocumentPickerModeOpen : UIDocumentPickerModeImport];
    } @catch (NSException * e) {
        Log(@"Couldn't launch documents file picker. Probably due to iOS version being below 11.0 and not having the iCloud entitlement. If so, just make sure to enable it for your app in Xcode. Exception was: %@", e);
        _result = nil;
        return;
    }
    
    if (@available(iOS 11.0, *)) {
        self.documentPickerController.allowsMultipleSelection = allowsMultipleSelection;
    } else if(allowsMultipleSelection) {
        Log(@"Multiple file selection is only supported on iOS 11 and above. Single selection will be used.");
    }
    
    self.documentPickerController.delegate = self;
    self.documentPickerController.presentationController.delegate = self;
    
    [[self viewControllerWithWindow:nil] presentViewController:self.documentPickerController animated:YES completion:nil];
}

- (void) resolvePickMedia:(MediaType)type withMultiPick:(BOOL)multiPick withCompressionAllowed:(BOOL)allowCompression  {
    
#ifdef PHPicker
    if (@available(iOS 14, *)) {
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
        config.filter = type == IMAGE ? [PHPickerFilter imagesFilter] : type == VIDEO ? [PHPickerFilter videosFilter] : [PHPickerFilter anyFilterMatchingSubfilters:@[[PHPickerFilter videosFilter], [PHPickerFilter imagesFilter]]];
        config.preferredAssetRepresentationMode = self.allowCompression ? PHPickerConfigurationAssetRepresentationModeCompatible : PHPickerConfigurationAssetRepresentationModeCurrent;
        
        if(multiPick) {
            config.selectionLimit = 0;
        }
        
        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
        pickerViewController.delegate = self;
        pickerViewController.presentationController.delegate = self;
        [[self viewControllerWithWindow:nil] presentViewController:pickerViewController animated:YES completion:nil];
        return;
    }
#endif
    
    if(multiPick) {
        [self resolveMultiPickFromGallery:type withCompressionAllowed:allowCompression];
        return;
    }
    
    NSArray<NSString*> * videoTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    NSArray<NSString*> * imageTypes = @[(NSString *)kUTTypeImage];
    
    self.galleryPickerController = [[UIImagePickerController alloc] init];
    self.galleryPickerController.delegate = self;
    self.galleryPickerController.presentationController.delegate = self;
    self.galleryPickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    switch (type) {
        case IMAGE:
            self.galleryPickerController.mediaTypes = imageTypes;
            if (@available(iOS 11.0, *)) {
                self.galleryPickerController.imageExportPreset = allowCompression ? UIImagePickerControllerImageURLExportPresetCompatible : UIImagePickerControllerImageURLExportPresetCurrent;
            }
            break;
            
        case VIDEO:
            self.galleryPickerController.mediaTypes = videoTypes;
            if (@available(iOS 11.0, *)) {
                self.galleryPickerController.videoExportPreset = allowCompression ? AVAssetExportPresetHighestQuality : AVAssetExportPresetPassthrough;
            }
            break;
            
        default:
            self.galleryPickerController.mediaTypes = [videoTypes arrayByAddingObjectsFromArray:imageTypes];
            break;
    }
    
    [[self viewControllerWithWindow:nil] presentViewController:self.galleryPickerController animated:YES completion:nil];
    
    
}

- (void) resolveMultiPickFromGallery:(MediaType)type withCompressionAllowed:(BOOL)allowCompression {
    DKImagePickerController * dkImagePickerController = [[DKImagePickerController alloc] init];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    UIViewController *currentViewController = [self viewControllerWithWindow:nil];
    if(_eventSink == nil) {
        // Create alert dialog for asset caching
        [alert.view setCenter: currentViewController.view.center];
        [alert.view addConstraint: [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
        
        // Create a default loader if user don't provide a status handler
        indicator.hidesWhenStopped = YES;
        [indicator setCenter: alert.view.center];
        indicator.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        [alert.view addSubview: indicator];
    }
    
    if (@available(iOS 11.0, *)) {
        DKImageAssetExporterConfiguration * exportConfiguration = [[DKImageAssetExporterConfiguration alloc] init];
        exportConfiguration.imageExportPreset = allowCompression ? DKImageExportPresentCompatible : DKImageExportPresentCurrent;
        exportConfiguration.videoExportPreset = allowCompression ? AVAssetExportPresetHighestQuality : AVAssetExportPresetPassthrough;
        dkImagePickerController.exporter = [dkImagePickerController.exporter initWithConfiguration:exportConfiguration];
    }
    
    dkImagePickerController.exportsWhenCompleted = YES;
    dkImagePickerController.showsCancelButton = YES;
    dkImagePickerController.sourceType = DKImagePickerControllerSourceTypePhoto;
    dkImagePickerController.assetType = type == VIDEO ? DKImagePickerControllerAssetTypeAllVideos : type == IMAGE ? DKImagePickerControllerAssetTypeAllPhotos : DKImagePickerControllerAssetTypeAllAssets;
    
    // Export status changed
    [dkImagePickerController setExportStatusChanged:^(enum DKImagePickerControllerExportStatus status) {
        
        if(status == DKImagePickerControllerExportStatusExporting && dkImagePickerController.selectedAssets.count > 0){
            Log("Exporting assets, this operation may take a while if remote (iCloud) assets are being cached.");
            
            if(self->_eventSink != nil){
                self->_eventSink([NSNumber numberWithBool:YES]);
            } else {
                [indicator startAnimating];
                [currentViewController showViewController:alert sender:nil];
            }
            
        } else {
            if(self->_eventSink != nil) {
                self->_eventSink([NSNumber numberWithBool:NO]);
            } else {
                [indicator stopAnimating];
                [alert dismissViewControllerAnimated:YES completion:nil];
            }
            
        }
    }];
    
    // Did cancel
    [dkImagePickerController setDidCancel:^(){
        self->_result(nil);
        self->_result = nil;
    }];
    
    // Did select
    [dkImagePickerController setDidSelectAssets:^(NSArray<DKAsset*> * __nonnull DKAssets) {
        NSMutableArray<NSURL*>* paths = [[NSMutableArray<NSURL*> alloc] init];
        
        for(DKAsset * asset in DKAssets) {
            if(asset.localTemporaryPath.absoluteURL != nil) {
                [paths addObject:asset.localTemporaryPath.absoluteURL];
            }
        }
        
        [self handleResult: paths];
    }];
    
    [[self viewControllerWithWindow:nil] presentViewController:dkImagePickerController animated:YES completion:nil];
}

- (void) resolvePickAudioWithMultiPick:(BOOL)isMultiPick {
    
    
    self.audioPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    self.audioPickerController.delegate = self;
    self.audioPickerController.presentationController.delegate = self;
    self.audioPickerController.showsCloudItems = YES;
    self.audioPickerController.allowsPickingMultipleItems = isMultiPick;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if([self viewControllerWithWindow:nil].presentedViewController == nil){
            Log("Exporting assets, this operation may take a while if remote (iCloud) assets are being cached.");
        }
    });

    
    [[self viewControllerWithWindow:nil] presentViewController:self.audioPickerController animated:YES completion:nil];
}

- (void) handleResult:(id) files {
    _result([FileUtils resolveFileInfo: [files isKindOfClass: [NSArray class]] ? files : @[files] withData:self.loadDataToMemory]);
    _result = nil;
}

#pragma mark - Delegates

// DocumentPicker delegate - iOS 10 only
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    [self.documentPickerController dismissViewControllerAnimated:YES completion:nil];
    [self handleResult:url];
}

// DocumentPicker delegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    
    if(_result == nil) {
        return;
    }
    
    [self.documentPickerController dismissViewControllerAnimated:YES completion:nil];
    
    if(controller.documentPickerMode == UIDocumentPickerModeOpen) {
        _result([urls objectAtIndex:0].path);
        _result = nil;
        return;
    }
    
    [self handleResult: urls];
}


// ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(_result == nil) {
        return;
    }
    
    NSURL *pickedVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    NSURL *pickedImageUrl;
    
    if(@available(iOS 13.0, *)) {
        
        if(pickedVideoUrl != nil) {
            NSString * fileName = [pickedVideoUrl lastPathComponent];
            NSURL * destination = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
            
            if([[NSFileManager defaultManager] isReadableFileAtPath: [pickedVideoUrl path]]) {
                Log(@"Caching video file for iOS 13 or above...");
                [[NSFileManager defaultManager] copyItemAtURL:pickedVideoUrl toURL:destination error:nil];
                pickedVideoUrl = destination;
            }
        } else {
            pickedImageUrl = [info objectForKey:UIImagePickerControllerImageURL];
        }
        
    } else if (@available(iOS 11.0, *)) {
        pickedImageUrl = [info objectForKey:UIImagePickerControllerImageURL];
    } else {
        UIImage *pickedImage  = [info objectForKey:UIImagePickerControllerEditedImage];
        
        if(pickedImage == nil) {
            pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        pickedImageUrl = [ImageUtils saveTmpImage:pickedImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if(pickedImageUrl == nil && pickedVideoUrl == nil) {
        _result([FlutterError errorWithCode:@"file_picker_error"
                                    message:@"Temporary file could not be created"
                                    details:nil]);
        _result = nil;
        return;
    }
    
    [self handleResult: pickedVideoUrl != nil ? pickedVideoUrl : pickedImageUrl];
}

#ifdef PHPicker

-(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)){
    
    if(_result == nil) {
        return;
    }
    
    if(self.group != nil) {
        return;
    }
    
    Log(@"Picker:%@ didFinishPicking:%@", picker, results);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if(results.count == 0) {
        Log(@"FilePicker canceled");
        _result(nil);
        _result = nil;
        return;
    }
    
    NSMutableArray<NSURL *> * urls = [[NSMutableArray alloc] initWithCapacity:results.count];
    
    self.group = dispatch_group_create();
    
    if(self->_eventSink != nil) {
        self->_eventSink([NSNumber numberWithBool:YES]);
    }
    
    __block NSError * blockError;
    
    for (PHPickerResult *result in results) {
        dispatch_group_enter(_group);
        [result.itemProvider loadFileRepresentationForTypeIdentifier:@"public.item" completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
            
            if(url == nil) {
                blockError = error;
                Log("Could not load the picked given file: %@", blockError);
                dispatch_group_leave(self->_group);
                return;
            }
            
            NSString * filename = url.lastPathComponent;
            NSString * extension = [filename pathExtension];
            NSFileManager * fileManager = [[NSFileManager alloc] init];
            NSURL * cachedUrl;
            
            // Check for live photos
            if(self.allowCompression && [extension isEqualToString:@"pvt"]) {
                NSArray * files = [fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                
                for (NSURL * item in files) {
                    if (UTTypeConformsTo(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, CFBridgingRetain([item pathExtension]), NULL), kUTTypeImage)) {
                        
                        UIImage * img = [UIImage imageWithContentsOfFile:item.path];
                        NSString * fileName = [[item.path lastPathComponent] stringByDeletingPathExtension];
                        NSData * data = UIImageJPEGRepresentation(img, 1);
                        NSString * tmpFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[fileName stringByAppendingString:@".jpeg"]];
                        cachedUrl = [NSURL fileURLWithPath: tmpFile];

                        if([fileManager fileExistsAtPath:tmpFile]) {
                            [fileManager removeItemAtPath:tmpFile error:nil];
                        }
                        
                        if([fileManager createFileAtPath:tmpFile contents:data attributes:nil]) {
                            filename = tmpFile;
                        } else {
                            Log("%@ Error while caching picked Live photo", self);
                        }
                        break;
                    }
                }
            } else {
                NSString * cachedFile = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
                
                if([fileManager fileExistsAtPath:cachedFile]) {
                    [fileManager removeItemAtPath:cachedFile error:NULL];
                }
                
                cachedUrl = [NSURL fileURLWithPath: cachedFile];
                
                NSError *copyError;
                [fileManager copyItemAtURL: url
                                     toURL: cachedUrl
                                     error: &copyError];
                
                if (copyError) {
                    Log("%@ Error while caching picked file: %@", self, copyError);
                    return;
                }
            }
            
            
            [urls addObject:cachedUrl];
            dispatch_group_leave(self->_group);
        }];
    }
    
    dispatch_group_notify(_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        self->_group = nil;
        if(self->_eventSink != nil) {
            self->_eventSink([NSNumber numberWithBool:NO]);
        }
        
        if(blockError) {
            self->_result([FlutterError errorWithCode:@"file_picker_error"
                                        message:@"Temporary file could not be created"
                                        details:blockError.description]);
            self->_result = nil;
            return;
        }
        [self handleResult:urls];
    });
}

#endif


// AudioPicker delegate
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [mediaPicker dismissViewControllerAnimated:YES completion:NULL];
    int numberOfItems = (int)[mediaItemCollection items].count;
    
    if(numberOfItems == 0) {
        return;
    }
    
    if(_eventSink != nil) {
        _eventSink([NSNumber numberWithBool:YES]);
    }
    
    NSMutableArray<NSURL *> * urls = [[NSMutableArray alloc] initWithCapacity:numberOfItems];
    
    for(MPMediaItemCollection * item in [mediaItemCollection items]) {
        NSURL * cachedAsset = [FileUtils exportMusicAsset: [item valueForKey:MPMediaItemPropertyAssetURL] withName: [item valueForKey:MPMediaItemPropertyTitle]];
        [urls addObject: cachedAsset];
    }
    
    if(_eventSink != nil) {
        _eventSink([NSNumber numberWithBool:NO]);
    }
    
    if(urls.count == 0) {
        Log(@"Couldn't retrieve the audio file path, either is not locally downloaded or the file is DRM protected.");
    }
    [self handleResult:urls];
}

#pragma mark - Actions canceled

- (void)presentationControllerDidDismiss:(UIPresentationController *)controller {
    Log(@"FilePicker canceled");
    if (self.result != nil) {
        self.result(nil);
        self.result = nil;
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)controller {
    Log(@"FilePicker canceled");
    _result(nil);
    _result = nil;
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    Log(@"FilePicker canceled");
    _result(nil);
    _result = nil;
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    Log(@"FilePicker canceled");
    _result(nil);
    _result = nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Alert dialog


@end
