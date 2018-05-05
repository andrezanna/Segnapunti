#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  FlutterMethodChannel* systemVersion = [FlutterMethodChannel
                                            methodChannelWithName:@"andrea.zanini.segnapunti/system_version"
                                            binaryMessenger:controller];
[batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
  if ([@"getSystemVersion" isEqualToString:call.method]) {
    String systemVersion = [self getSystemVersion];


      result(@(systemVersion));

  } else {
    result(FlutterMethodNotImplemented);
  }
}];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
- (String)getSystemVersion {
  UIDevice* device = UIDevice.currentDevice;
    return device.systemName;
}
@end
