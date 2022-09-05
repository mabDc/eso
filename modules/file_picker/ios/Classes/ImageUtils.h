//
//  ImageUtils.h
//  Pods
//
//  Created by Miguel Ruivo on 05/03/2019.
//

@interface ImageUtils : NSObject
+ (BOOL)hasAlpha:(UIImage *)image;
+ (NSURL*)saveTmpImage:(UIImage *)image;
@end
