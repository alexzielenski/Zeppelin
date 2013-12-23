#import "Defines.h"
#import <objc/runtime.h>

#import <SpringBoard/SBStatusBarDataManager.h>
#import <SpringBoard70/SBStatusBarStateAggregator.h>

#import "ZPImageServer.h"

@implementation UIDevice (OSVersion)
- (BOOL)iOSVersionIsAtLeast:(NSString*)version {
    NSComparisonResult result = [[self systemVersion] compare:version options:NSNumericSearch];
    return (result == NSOrderedDescending || result == NSOrderedSame);
}
@end

@interface SBStatusBarDataManager (asd)
- (void)forceUpdate;
- (BOOL)_getBlackImageName:(NSString **)blackImageName silverImageName:(NSString **)silverImageName directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName;
@end

static void setSettingsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo) {
	NSLog(@"Zeppelin: Reloading settings : %@", (NSDictionary*)userInfo);

	NSDictionary *newSettings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	[[ZPImageServer sharedServer] setSettings:newSettings];

	[[%c(SBStatusBarStateAggregator) sharedInstance] forceUpdate];
}


// SpringBoard is the only process that will read the preferences
// it then hands off the information about the wherabouts of the image
// to the other apps in ios7
%hook SBStatusBarStateAggregator
%new(v@:)
- (void)forceUpdate {
	[self _updateServiceItem];
	// [self _postItem: 4 withState: 9];
	[self _notifyItemChanged: 4];
}

- (void)_updateServiceItem {
	%orig();
	NSLog(@"Zeppelin: update service item");

	ZPImageServer *server = [ZPImageServer sharedServer];

	StatusBarData70 *data = &MSHookIvar<StatusBarData70>(self, "_data");

	if (!server.enabled) {
		NSLog(@"Zeppelin: Disabled");
		strncpy(data->operatorDirectory, "", 1024);
		data->operatorDirectory[0]   = '\0';
		data->serviceContentType        = 3;
		return;
	}

	NSString *black  = [server currentBlackName];
	NSString *silver = [server currentSilverName];

	NSString *dir = [server currentThemeDirectory];


	strncpy(data->serviceImages[0], [silver cStringUsingEncoding:NSUTF8StringEncoding], 100);
	strncpy(data->serviceImages[1], [black cStringUsingEncoding:NSUTF8StringEncoding], 100);
	strncpy(data->operatorDirectory, [dir fileSystemRepresentation], 1024);

	data->serviceContentType        = 3;

	data->serviceImages[0][99]      = '\0'; // last index should be null
	data->serviceImages[1][99]      = '\0';
	data->operatorDirectory[1023]   = '\0';

}

%end

%ctor {
	NSLog(@"Zeppelin initialized");
	%init();

	ZPImageServer *server = [ZPImageServer sharedServer];
	(void)server;

	NSFileManager *manager = [NSFileManager defaultManager];
	[manager createDirectoryAtPath: kPacksDirectory withIntermediateDirectories: YES attributes: nil error: nil];

	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsRefreshSettings, NULL, 0);
	CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsChanged, NULL, 0);
}

