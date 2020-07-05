#import "EsoPlugin.h"
#if __has_include(<eso_plugin/eso_plugin-Swift.h>)
#import <eso_plugin/eso_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "eso_plugin-Swift.h"
#endif

@implementation EsoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEsoPlugin registerWithRegistrar:registrar];
}
@end
