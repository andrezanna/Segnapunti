#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

   FlutterMethodChannel* systemVersion = [FlutterMethodChannel
                                           methodChannelWithName:@"andrea.zanini.segnapunti/system_version"
                                             binaryMessenger:controller];
  [systemVersion setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
   if ([@"getSystemVersion" isEqualToString:call.method]) {
     NSString*  systemVersion = [self getSystemVersion];
     result(systemVersion);
   } else {
     result(FlutterMethodNotImplemented);
   }
  }];

     return [super application:application didFinishLaunchingWithOptions:launchOptions];
   }

  - (NSString *)getSystemVersion {
    UIDevice* device = UIDevice.currentDevice;
     return device.systemVersion;
  }
@end
