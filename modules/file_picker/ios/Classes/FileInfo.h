//
//  FileInfo.h
//  file_picker
//
//  Created by Miguel Ruivo on 11/09/2020.
//

@interface FileInfo : NSObject

@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSData * bytes;
@property (nonatomic, strong) NSNumber * isDirectory;

- (instancetype) initWithPath: (NSString *)path andUrl: (NSURL*)url andName: (NSString *)name andSize: (NSNumber *) size andData:(NSData*) data;

- (NSDictionary *) toData;

@end

