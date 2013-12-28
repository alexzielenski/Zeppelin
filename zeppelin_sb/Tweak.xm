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
	%orig();
	NSLog(@"Zeppelin: update service item");

	ZPImageServer *server = [ZPImageServer sharedServer];
	StatusBarData70 *data = &MSHookIvar<StatusBarData70>(self, "_data");

    [(server.carrierText && server.carrierText.length) ? server.carrierText : (NSString *)self.operatorName getCString:&data->serviceString[0] maxLength:100 encoding:NSUTF8StringEncoding];

	if (!server.enabled) {
		NSLog(@"Zeppelin: Disabled");
		data->operatorDirectory[0] = '\0';
		data->serviceContentType = 3;
		return;
	}

	NSString *black; 
	NSString *silver;
    if (server.shouldTint) {
        black  =  @"tint";
        silver = server.currentLogoName;
    } else {
        black = [server currentBlackName];
        silver = [server currentSilverName];
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
            NSLog(@"Zeppelin: Disabling Item: %i", item);
            return %orig(item, NO);
    }

    return %orig(item, enabled);
}

%end

%end

%hook SBStatusBarDataManager

- (void)setStatusBarItem:(int)item enabled:(BOOL)enabled {
        ZPImageServer *server = [ZPImageServer sharedServer];
        
        if (item == 4 && [server noLogo] && server.isEnabled) {
            NSLog(@"Zeppelin: Disabling Item: %i", item);
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
        
        NSLog(@"Zeppelin: update service item");
        
        ZPImageServer *server = [ZPImageServer sharedServer];
        NSString *carrierText = server.carrierText;
        if (carrierText && carrierText.length) {
            StatusBarDataCommon *data = &MSHookIvar<StatusBarDataCommon>(self, "_data");
            
            [carrierText getCString:&data->serviceString[0] maxLength:100 encoding:NSUTF8StringEncoding];
            data->serviceContentType = 1;
            data->operatorDirectory[0] = '\0';
        }

        if (!server.enabled || server.shouldUseOldMethod) {

            NSLog(@"Zeppelin: Disabled");
            return;
        }

        NSString *silver = server.currentSilverName;
        NSString *black  = server.currentBlackName;
        NSString *etched = server.currentEtchedName;
        NSString *dir    = server.currentThemeDirectory;
        
        if (IS_IOS_60()) {
            StatusBarData60 *data = &MSHookIvar<StatusBarData60>(self, "_data");
                   
            [black getCString:&data->serviceImages[0][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [etched getCString:&data->serviceImages[1][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [dir getCString:&data->operatorDirectory[0] maxLength:100 encoding:NSUTF8StringEncoding];

            // data->serviceCrossfadeString[0] = '\0'; // eliminate the titles
            // data->serviceString[0]          = '\0';
            data->serviceContentType        = 3;

            NSString *(&service)[2] = MSHookIvar<NSString *[2]>(self, "_serviceImages");
            [service[0] release];
            [service[1] release];

            service[0] = black.copy;
            service[1] = etched.copy;
                        
        } else  if (IS_IOS_50()) {
            StatusBarData50 *data = &MSHookIvar<StatusBarData50>(self, "_data");
            
            [silver getCString:&data->serviceImages[0][0] maxLength:100 encoding:NSUTF8StringEncoding];                    
            [black getCString:&data->serviceImages[1][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [etched getCString:&data->serviceImages[2][0] maxLength:100 encoding:NSUTF8StringEncoding];
            [dir getCString:&data->operatorDirectory[0] maxLength:100 encoding:NSUTF8StringEncoding];   
            data->serviceContentType = 3;
                                
            NSString *(&service)[3] = MSHookIvar<NSString *[3]>(self, "_serviceImages");
            [service[0] release];
            [service[1] release];
            [service[2] release];
                                
            service[0] = silver.copy;
            service[1] = black.copy;
            service[2] = etched.copy;
                
        } else {
            StatusBarData42 *data = &MSHookIvar<StatusBarData42>(self, "_data");
            
            [silver getCString:&data->serviceImageSilver[0] maxLength:100 encoding:NSUTF8StringEncoding];                    
            [black getCString:&data->serviceImageBlack[0] maxLength:100 encoding:NSUTF8StringEncoding];
            [dir getCString:&data->operatorDirectory[0] maxLength:100 encoding:NSUTF8StringEncoding];
            data->serviceContentType = 3;
                 
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
        serviceString = server.carrierText;

        [self _dataChanged];
}

%group iOS5
- (BOOL)_getServiceImageNames:(NSString ***)names directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName {        
    NSLog(@"Zeppelin: Getting images for operator: %@", anOperator);
    ZPImageServer *server = [ZPImageServer sharedServer];
    BOOL enabled = server.isEnabled;

    *directory   = server.currentThemeDirectory;
    *carrierName = server.carrierText ? server.carrierText : anOperator;

    NSString *silver = server.currentSilverName;
    NSString *black  = server.currentBlackName;
    NSString *etched = server.currentEtchedName;

    if (IS_IOS_60() && enabled) {
        names[0] = (NSString **)black;
        names[1] = (NSString **)etched;
                
        return YES;
    } else if (enabled) {
        names[0] = (NSString **)silver;
        names[1] = (NSString **)black;
        names[2] = (NSString **)etched;

        return YES;
    }
        
    return %orig(names, directory, anOperator, carrierName);
}
%end
        
%group iOS4
- (BOOL)_getBlackImageName:(NSString **)blackImageName silverImageName:(NSString **)silverImageName directory:(NSString **)directory forOperator:(NSString *)anOperator statusBarCarrierName:(NSString **)carrierName {
        NSLog(@"Zeppelin: Getting images for operator: %@", anOperator);
        ZPImageServer *server = [ZPImageServer sharedServer];

        BOOL enabled = server.isEnabled;
        if (!enabled) {
                return %orig(blackImageName, silverImageName, directory, anOperator, carrierName);
        }

        *directory   = server.currentThemeDirectory;
        *carrierName = server.carrierText ? server.carrierText : anOperator;

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

	NSFileManager *manager = [NSFileManager defaultManager];
	[manager createDirectoryAtPath: kPacksDirectory withIntermediateDirectories: YES attributes: nil error: nil];

	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsRefreshSettings, NULL, 0);
	CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kZeppelinSettingsChanged, NULL, 0);

	%init();

	if (%c(SBStatusBarStateAggregator)) {
		NSLog(@"Zeppelin: loading ios 7+");
        %init(iOS7);
	} else if ([%c(SBStatusBarDataManager) instancesRespondToSelector: @selector(_getServiceImageNames:directory:forOperator:statusBarCarrierName:)] ) {
        NSLog(@"Zeppelin: loading ios 5 or 6");
        %init(iOS5);        
    } else {
        NSLog(@"Zeppelin: init ios 4");
        %init(iOS4);
    }
}

