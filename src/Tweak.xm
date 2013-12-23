#import <UIKit/UIKit.h>
#import <SpringBoard/SBStatusBarDataManager.h>
#import <SpringBoard70/SBStatusBarStateAggregator.h>
#import <UIKit70/UIStatusBarServiceItemView.h>
#import <UIKit70/UIStatusBarComposedData.h>
#import <UIKit70/_UILegibilityImageSet.h>
#import <UIKit70/UIImage-_UILegibility.h>
#import <UIKit70/_UILegibilitySettings.h>

#import "ZPImageServer.h"
#import "Categories/NSString+ZPAdditions.h"
#import "Defines.h"
#import <objc/runtime.h>


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
	NSLog(@"Zeppelin: %@", newSettings);
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

	if (!server.enabled || server.useOldMethod) {
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

	// data->serviceCrossfadeString[0] = '\0'; // eliminate the titles
	// data->serviceString[0]          = '\0';
	data->serviceContentType        = 3;

	data->serviceImages[0][99]      = '\0'; // last index should be null
	data->serviceImages[1][99]      = '\0';
	data->operatorDirectory[1023]   = '\0';

}

%end

%hook UIStatusBarServiceItemView
static char kBLACKIMAGE;
static char kWHITEIMAGE;
static char kOPERATORDIRECTORY;

- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2 {
	StatusBarData70 *data = (StatusBarData70*)[arg1 rawData];

	[self updateContentsAndWidth];

	[self willChangeValueForKey: @"contentsImage"];
	objc_setAssociatedObject(self, &kOPERATORDIRECTORY, [NSString stringWithCString: data->operatorDirectory encoding: NSUTF8StringEncoding], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, &kBLACKIMAGE, [NSString stringWithCString: data->serviceImages[0] encoding: NSUTF8StringEncoding], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, &kWHITEIMAGE, [NSString stringWithCString: data->serviceImages[1] encoding: NSUTF8StringEncoding], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey: @"contentsImage"];

	return %orig(arg1, arg2);
}

- (id)_serviceContentsImage {	
	NSString *operatorDirectory = objc_getAssociatedObject(self, &kOPERATORDIRECTORY);

	if (!operatorDirectory.length) {
		return %orig;
	}

	UIColor *tint = [(id)self.foregroundStyle tintColor];
	CGFloat white;

	[tint getWhite: &white alpha: NULL];

	NSString *blackImage = objc_getAssociatedObject(self, &kBLACKIMAGE);
	NSString *whiteImage = objc_getAssociatedObject(self, &kWHITEIMAGE);
	UIImage *image = [UIImage imageWithContentsOfFile: [operatorDirectory stringByAppendingPathComponent: white ? whiteImage : blackImage]];

	return [_UILegibilityImageSet imageFromImage: [image _imageWithBrightnessModifiedForLegibilityStyle: [self legibilityStyle]]
								 withShadowImage: [image _imageForLegibilitySettings: [_UILegibilitySettings sharedInstanceForStyle: [self legibilityStyle]] strength: [self legibilityStrength]]];
}

%end

%ctor {
	NSLog(@"Zeppelin initialized");
	%init();

	// run only in springboard
	if (NSStringFromClass(%c(SBStatusBarStateAggregator))) {
		ZPImageServer *server = [ZPImageServer sharedServer];
		(void)server;

		NSFileManager *manager = [NSFileManager defaultManager];
		[manager createDirectoryAtPath: kPacksDirectory withIntermediateDirectories: YES attributes: nil error: nil];

		CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
		CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsRefreshSettings, NULL, 0);
		CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsChanged, NULL, 0);
	}

}

