#import "ZeppelinSettings.h"

#import "Defines.h"
#import "ZPTheme.h"

@implementation ZeppelinSettingsListController
@synthesize settings = _settings;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {
		_settings = [([NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH] ?: DefaultPrefs) retain];
	}
	return self;
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ZeppelinSettings" target:self] retain];
	}
	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
    NSString *key([spec propertyForKey:@"key"]);
    if ([[spec propertyForKey:@"negate"] boolValue])
        value = [NSNumber numberWithBool:(![value boolValue])];
    [_settings setValue:value forKey:key];
}

- (id)readPreferenceValue:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];
    id defaultValue = [spec propertyForKey:@"default"];
    id plistValue = [_settings objectForKey:key];

    if (!plistValue)
        return defaultValue;
    if ([[spec propertyForKey:@"negate"] boolValue])
        plistValue = [NSNumber numberWithBool: (![plistValue boolValue])];
    return plistValue;
}

- (void)visitWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.alexzielenski.com"]];
}

- (void)visitTwitter:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/alexzielenski"]];
}

- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch *)cell.accessoryView;
	[_settings setObject: [NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];

	[self writeSettings];
	[self sendSettings];
}

- (void)setCurrentTheme:(ZPTheme *)theme {
	[_settings setObject:theme.name forKey:PrefsThemeKey];
	[_settings setObject:theme.pack forKey:PrefsPackKey];

	[_settings removeObjectForKey:PrefsAltSilverKey];
	[_settings removeObjectForKey:PrefsAltBlackKey];
	[_settings removeObjectForKey:PrefsAltEtchedKey];
	
	UITableView *table = self.table;
	UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	cell.detailTextLabel.text = theme.name;
	
	[self sendSettings];
}

- (NSNumber *)enabled {
	return [_settings objectForKey:PrefsEnabledKey];
}

- (void)setEnabled:(NSNumber*)enabled {
	[_settings setObject:enabled forKey:PrefsEnabledKey];
	[self sendSettings];
}

- (void)writeSettings {
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

	if (!data)
		return;
	if (![data writeToFile:PREFS_PATH atomically:NO])
		return;
}

- (void)sendSettings {
	[self writeSettings];

	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(r, (CFStringRef)kZeppelinSettingsChanged, NULL, (CFDictionaryRef)_settings, true);
}

- (void)suspend {
	[self writeSettings];
}

- (void)dealloc {
	// set the enabled value
	[self writeSettings];
	
	[_settings release];
	[super dealloc];
}

@end
