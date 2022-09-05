//
//  ImageUtils.m
//  file_picker
//
//  Created by Miguel Ruivo on 05/03/2019.
//

#import "ImageUtils.h"

@implementation ImageUtils

// Returns true if the image has an alpha layer
+ (BOOL)hasAlpha:(UIImage *)image {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
}

// Save the image temporarly in the app's tmp directory
+ (NSURL *)saveTmpImage:(UIImage *)image {
    BOOL hasAlpha = [ImageUtils hasAlpha:image];
    NSData *data = hasAlpha ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1.0);
    NSString *fileExtension = hasAlpha ? @"tmp_%@.png" : @"tmp_%@.jpg";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *tmpFile = [NSString stringWithFormat:fileExtension, guid];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
    
    if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
        return  [NSURL URLWithString: tmpPath];
    }
    return nil;
}

@end
