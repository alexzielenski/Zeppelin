#import <UIKit/UIKit.h>
#import <SpringBoard/SBStatusBarDataManager.h>

#import "ZPImageServer.h"
#import "Categories/NSString+ZPAdditions.h"
#import "Defines.h"

static void setSettingsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo) {
	NSLog(@"Zeppelin: Reloading settings : %@", (NSDictionary*)userInfo);
	
	NSDictionary *newSettings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	[[ZPImageServer sharedServer] setSettings:newSettings];
	[[%c(SBStatusBarDataManager) sharedDataManager] forceUpdate];
	
	
}

%hook SBStatusBarDataManager
- (void)setStatusBarItem:(int)item enabled:(BOOL)enabled {
	ZPImageServer *server = [ZPImageServer sharedServer];
	
	if (item==4&&[server noLogo]&&[server enabled]) {
		NSLog(@"Disabling Item: %i", item);
		%orig(item, NO);
		return;
	}
	%orig(item, enabled);
}
%new(v@:)
- (void)forceUpdate {
	[self beginUpdateBlock];
	[self _updateServiceItem];
	[self endUpdateBlock];
	
	[self _postData];
}
- (void)_updateServiceItem {
	%orig;
	
	ZPImageServer *server = [ZPImageServer sharedServer];
	if (!server.enabled||server.useOldMethod)
		return;
	
	NSString *silver = [server currentSilverName];
	NSString *black  = [server currentBlackName];
	NSString *etched = [server currentEtchedName];
	
	NSString *dir = [server currentThemeDirectory];
	
	if (IS_IOS_50_OR_LATER()) {
		StatusBarData50 *data = &MSHookIvar<StatusBarData50>(self, "_data");
		
		strncpy(data->serviceImages[0], [silver cStringUsingEncoding:NSUTF8StringEncoding], 100);
		strncpy(data->serviceImages[1], [black cStringUsingEncoding:NSUTF8StringEncoding], 100);
		strncpy(data->serviceImages[2], [etched cStringUsingEncoding:NSUTF8StringEncoding], 100);	
		strncpy(data->operatorDirectory, [dir fileSystemRepresentation], 1024);	
		
		data->serviceCrossfadeString[0] = '\0'; // eliminate the titles
		data->serviceString[0]          = '\0';
		data->serviceContentType        = 3;
		
		data->serviceImages[0][99]      = '\0'; // last index should be null
		data->serviceImages[1][99]      = '\0';
		data->serviceImages[2][99]      = '\0';
		data->operatorDirectory[1023]   = '\0';
		
		NSString *(&service)[3] = MSHookIvar<NSString *[3]>(self, "_serviceImages");
		[service[0] release];
		[service[1] release];
		[service[2] release];
		
		service[0] = silver.copy;
		service[1] = black.copy;
		service[2] = etched.copy;
		
	} else {
		StatusBarData42 *data = &MSHookIvar<StatusBarData42>(self, "_data");
		
		strncpy(data->serviceImageBlack, [black cStringUsingEncoding:NSUTF8StringEncoding], 100);
		strncpy(data->serviceImageSilver, [silver cStringUsingEncoding:NSUTF8StringEncoding], 100);		
		strncpy(data->operatorDirectory, [dir fileSystemRepresentation], 1024);	
		
		data->serviceImageBlack[99]     = '\0';
		data->serviceImageSilver[99]    = '\0';
		data->serviceString[0]          = '\0';
		data->operatorDirectory[1023]   = '\0';
		data->serviceContentType        = 3;
		
		
		NSString *&serviceImageBlack  = MSHookIvar<NSString *>(self, "_serviceImageBlack");
		NSString *&serviceImageSilver = MSHookIvar<NSString *>(self, "_serviceImageSilver");
		[serviceImageBlack release];
		[serviceImageSilver release];
		
		serviceImageBlack  = black.copy;
		serviceImageSilver = silver.copy;
	}
	
	NSString *&operatorDirectory = MSHookIvar<NSString *>(self, "_operatorDirectory");
	if (operatorDirectory) {
		[operatorDirectory release];
		operatorDirectory = nil;
	}
	operatorDirectory = dir.copy;

	NSString *&serviceString = MSHookIvar<NSString *>(self, "_serviceString");
	if (serviceString) {
		[serviceString release];
		serviceString = nil;
	}
	
	[self _dataChanged];
}
%group iOS5
- (BOOL)_getServiceImageNames:(NSString ***)names directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName {	
	// NSLog(@"Zeppelin: Getting images for operator: %@", anOperator);

	ZPImageServer *server = [ZPImageServer sharedServer];
	BOOL enabled = [server enabled];
	if (!enabled) {
		return %orig(names, directory, anOperator, carrierName);
	}
	*directory   = [server currentThemeDirectory];
	*carrierName = anOperator;
	
	NSString *silver = [server currentSilverName];
	NSString *black  = [server currentBlackName];
	NSString *etched = [server currentEtchedName];
		
	names[0] = (NSString**)silver;
	names[1] = (NSString**)black;
	names[2] = (NSString**)etched;
	
	return YES;
}
%end
%group iOS4
- (BOOL)_getBlackImageName:(NSString **)blackImageName silverImageName:(NSString **)silverImageName directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName {
	// NSLog(@"Zeppelin: Getting images for operator: %@", anOperator);
	ZPImageServer *server = [ZPImageServer sharedServer];

	BOOL enabled = [server enabled];
	if (!enabled) {
		return %orig(blackImageName, silverImageName, directory, anOperator, carrierName);
	}
	*directory   = [server currentThemeDirectory];
	*carrierName = anOperator;
	
	NSString *silver = [server currentSilverName];
	NSString *black  = [server currentBlackName];
	
	*silverImageName = silver;
	*blackImageName  = black;
	
	return YES;
}
- (void)_getBlackImageName:(NSString **)blackImageName silverImageName:(NSString **)silverImageName directory:(NSString **)directory forFakeCarrier:(NSString *)fakeCarrier {
	ZPImageServer *server = [ZPImageServer sharedServer];

	BOOL enabled = [server enabled];
	if (!enabled) {
		%orig(blackImageName, silverImageName, directory, fakeCarrier);
		return;
	}
	[self _getBlackImageName:blackImageName silverImageName:silverImageName directory:directory forOperator:fakeCarrier statusBarCarrierName:nil];
	
}
%end
%end
	
%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	ZPImageServer *server = [ZPImageServer sharedServer];
	NSLog(@"Zeppelin initialized");
	(void)server;
	
	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification,
		(CFStringRef)kZeppelinSettingsRefreshSettings, NULL, 0);
	CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification,
		(CFStringRef)kZeppelinSettingsChanged, NULL, 0);
	
	%init();
	
	if (IS_IOS_50_OR_LATER()) {
		%init (iOS5);
	} else
		%init (iOS4);
	
	[pool drain];
}