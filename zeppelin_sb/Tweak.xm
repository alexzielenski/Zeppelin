#import "Defines.h"

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

static inline void setSettingsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo) {
	NSDictionary *newSettings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	[[ZPImageServer sharedServer] setSettings:newSettings];

	if (%c(SBStatusBarStateAggregator) != NULL) {
		[[%c(SBStatusBarStateAggregator) sharedInstance] forceUpdate];
	} else {
	    [[%c(SBStatusBarDataManager) sharedDataManager] forceUpdate];
	}
}



// SpringBoard is the only process that will read the preferences
// it then hands off the information about the wherabouts of the image
// to the other apps in ios7
%group iOS7
%hook SBStatusBarStateAggregator

%new(v@:)
- (void)forceUpdate {
	[self _updateServiceItem];
	[self _notifyItemChanged: 4];
}

- (void)_updateServiceItem {
	%orig;
	ZLog(@"update service item");

	ZPImageServer *server = [ZPImageServer sharedServer];
	StatusBarData70 *data = &MSHookIvar<StatusBarData70>(self, "_data");

    [(server.carrierText) ? server.carrierText : MSHookIvar<NSString *>(self , "_serviceString") getCString:&data->serviceString[0] maxLength:100 encoding:NSUTF8StringEncoding];

	if (!server.enabled) {
		ZLog(@"Disabled");
		data->operatorDirectory[0] = '\0';
		data->serviceContentType = 3;
		return;
	}

	NSString *black; 
	NSString *silver = server.currentLogoName;

    if (server.shouldTint) {
        black  = @"tint";
    } else if (server.shouldUseLegacyImages) {
        black  = server.currentBlackName;
        silver = server.currentSilverName;
    } else {
        silver = server.currentLightName;
        black  = server.currentDarkName;
    }

	NSString *dir = [server currentThemeDirectory];

    [silver getCString:&data->serviceImages[0][0] maxLength:100 encoding:NSUTF8StringEncoding];
    [black getCString:&data->serviceImages[1][0] maxLength:100 encoding:NSUTF8StringEncoding];
    [dir getCString:&data->operatorDirectory[0] maxLength: 1024 encoding: NSUTF8StringEncoding];
	data->serviceContentType = 3;
}

-(BOOL)_setItem:(int)item enabled:(BOOL)enabled {
    ZPImageServer *server = [ZPImageServer sharedServer];
        
    if (item == 4 && [server noLogo] && server.isEnabled && enabled) {
            ZLog(@"Disabling Item: %i", item);
            return %orig(item, NO);
    }

    return %orig(item, enabled);
}

%end

%end

%group legacy

%hook SBStatusBarDataManager
- (void)setStatusBarItem:(int)item enabled:(BOOL)enabled {
    ZPImageServer *server = [ZPImageServer sharedServer];
        
    if (item == 4 && [server noLogo] && server.isEnabled) {
        ZLog(@"Disabling Item: %i", item);
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

    [self _dataChanged];
    [self _postData];
}

- (void)_updateServiceItem {
    %orig;
    
    ZLog(@"update service item");
    
    ZPImageServer *server = [ZPImageServer sharedServer];
    BOOL apply = (server.enabled && !server.shouldUseOldMethod);

    if (!apply)
        ZLog(@"Disabled");

    NSString *silver = server.currentSilverName;
    NSString *black  = server.currentBlackName;
    NSString *etched = server.currentEtchedName;
    NSString *dir    = server.currentThemeDirectory;
    NSString *serviceString = server.carrierText ? server.carrierText : MSHookIvar<NSString *>(self , "_serviceString");

    if (IS_IOS_60()) {
        StatusBarData60 *data = &MSHookIvar<StatusBarData60>(self, "_data");
               
        if (apply) {
            [black getCString:&data->serviceImages[0][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [etched getCString:&data->serviceImages[1][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [dir getCString:&data->operatorDirectory[0] maxLength:100 encoding:NSUTF8StringEncoding];
            data->serviceContentType = 3;
        } else {
            [serviceString getCString:&data->serviceString[0] maxLength:100 encoding:NSUTF8StringEncoding];
        }
        
    } else if (IS_IOS_50()) {
        StatusBarData50 *data = &MSHookIvar<StatusBarData50>(self, "_data");
        
        if (apply) {
            [silver getCString:&data->serviceImages[0][0] maxLength:100 encoding:NSUTF8StringEncoding];                    
            [black getCString:&data->serviceImages[1][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [etched getCString:&data->serviceImages[2][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [dir getCString:&data->operatorDirectory[0] maxLength:100 encoding:NSUTF8StringEncoding];
            data->serviceContentType = 3;
        } else {
            [serviceString getCString:&data->serviceString[0] maxLength:100 encoding:NSUTF8StringEncoding];
        }
    } else {
        StatusBarData42 *data = &MSHookIvar<StatusBarData42>(self, "_data");
        
        if (apply) {
            [silver getCString:&data->serviceImageSilver[0] maxLength:100 encoding:NSUTF8StringEncoding];                    
            [black getCString:&data->serviceImageBlack[0] maxLength:100 encoding:NSUTF8StringEncoding];
            [dir getCString:&data->operatorDirectory[0] maxLength:100 encoding:NSUTF8StringEncoding];
            data->serviceContentType = 3;
        } else {
            [serviceString getCString:&data->serviceString[0] maxLength:100 encoding:NSUTF8StringEncoding];
        }
    }
}
%end
%end

%group iOS5
%hook SBStatusBarDataManager
- (BOOL)_getServiceImageNames:(NSString ***)names directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName {        
    ZLog(@"Getting images for operator: %@", anOperator);

    ZPImageServer *server = [ZPImageServer sharedServer];
    BOOL enabled = server.isEnabled;
    *carrierName = server.carrierText;

    NSString *silver = server.currentSilverName;
    NSString *black  = server.currentBlackName;
    NSString *etched = server.currentEtchedName;

    if (IS_IOS_60() && enabled) {
        names[0] = (NSString **)black;
        names[1] = (NSString **)etched;
        *directory   = server.currentThemeDirectory;

        return YES;
    } else if (enabled) {
        names[0] = (NSString **)silver;
        names[1] = (NSString **)black;
        names[2] = (NSString **)etched;
        *directory   = server.currentThemeDirectory;

        return YES;
    }
        
    return %orig(names, directory, anOperator, *carrierName ? NULL : carrierName);
}
%end
%end
        
%group iOS4
%hook SBStatusBarDataManager
- (BOOL)_getBlackImageName:(NSString **)blackImageName silverImageName:(NSString **)silverImageName directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName {
        ZLog(@"Getting images for operator: %@", anOperator);
        ZPImageServer *server = [ZPImageServer sharedServer];
        *carrierName = server.carrierText;

        BOOL enabled = server.isEnabled;
        if (!enabled) {
            return %orig(blackImageName, silverImageName, directory, anOperator, *carrierName ? NULL : carrierName);
        }

        *directory   = server.currentThemeDirectory;

        NSString *silver = server.currentSilverName;
        NSString *black  = server.currentBlackName;

        *silverImageName = silver;
        *blackImageName  = black;

        return YES;
}

- (void)_getBlackImageName:(NSString **)blackImageName silverImageName:(NSString **)silverImageName directory:(NSString **)directory forFakeCarrier:(NSString *)fakeCarrier {
        ZPImageServer *server = [ZPImageServer sharedServer];

        BOOL enabled = server.isEnabled;
        if (!enabled) {
                %orig(blackImageName, silverImageName, directory, fakeCarrier);
                return;
        }

        [self _getBlackImageName:blackImageName silverImageName:silverImageName directory:directory forOperator:fakeCarrier statusBarCarrierName:nil];
}
%end
%end

%ctor {
	NSLog(@"Zeppelin initialized");

    ZPImageServer *server = [ZPImageServer sharedServer];
    (void)server;

    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsChanged, NULL, 0);
	
	%init;

	if (%c(SBStatusBarStateAggregator)) {
		ZLog(@"loading ios 7+");
        %init(iOS7);
	} else {
        %init(legacy);
    } 

    if ([%c(SBStatusBarDataManager) instancesRespondToSelector: @selector(_getServiceImageNames:directory:forOperator:statusBarCarrierName:)] ) {
        ZLog(@"loading ios 5 or 6");
        %init(iOS5);        
    } else if (%c(SBStatusBarDataManager)) {
        ZLog(@"loading ios 4");
        %init(iOS4);
    }
}

