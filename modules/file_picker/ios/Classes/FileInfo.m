//
//  FileInfo.m
//  file_picker
//
//  Created by Miguel Ruivo on 11/09/2020.
//

#import "FileInfo.h"

@implementation FileInfo

- (instancetype) initWithPath: (NSString *)path andUrl: (NSURL *)url andName: (NSString *)name andSize: (NSNumber *) size andData:(NSData*) data {

    self = [super init];

    if (self) {
        self.path = path;
        self.name = name;
        self.size = size;
        self.bytes = data;
        self.url = url;
    }
    return self;
}

- (NSDictionary *)toData {
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setValue:self.path forKey:@"path"];
    [data setValue:self.url.absoluteString forKey:@"identifier"];
    [data setValue:self.name forKey:@"name"];
    [data setValue:self.size forKey:@"size"];
    [data setValue:self.bytes forKey:@"bytes"];
    return data;
}

@end
