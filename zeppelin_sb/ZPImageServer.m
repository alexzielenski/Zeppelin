#import "ZPImageServer.h"
#import "Categories/NSString+ZPAdditions.h"

@implementation ZPImageServer
+ (ZPImageServer *)sharedServer {
	static ZPImageServer *server = nil;
	if (!server) {
		server = [[ZPImageServer alloc] init];
	}
	return server;
}

- (id)init {
	if ((self = [super init])) {
		// get the settings
		[self setSettings:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
	}
	return self;
}

- (void)setSettings:(NSDictionary*)newSettings {
	if (settings) {
		[settings release];
		[directory release];
	}

	// if (pack)
		// [pack release], pack = nil;

	settings = [newSettings retain];

	if (!settings) {
		NSLog(@"Zeppelin: No settings found. Reverting to defaults.");
		settings = [DefaultPrefs retain];
	}
	NSString *name = [settings objectForKey:PrefsThemeKey];
	enabled        = ([settings.allKeys containsObject:PrefsEnabledKey]) ? [[settings objectForKey:PrefsEnabledKey] boolValue] : NO;
	directory      = [[kThemesDirectory stringByAppendingPathComponent:name] retain];
	noLogo         = [[settings objectForKey:PrefsThemeKey] isEqualToString:@"None"];
	shouldTint     = ([[NSFileManager defaultManager] fileExistsAtPath: self.currentLogoPath]);
	// if ([settings.allKeys containsObject: PrefsPackKey])
		// pack       = [[settings objectForKey: PrefsPackKey] retain];

}

- (NSDictionary *)settings {
	return settings;
}

- (BOOL)useOldMethod {
	return [[settings objectForKey:PrefsOldMethodKey] boolValue];
}

- (BOOL)noLogo {
	return noLogo;
}

- (BOOL)shouldTint {
	return shouldTint;
}

- (BOOL)enabled {
	return enabled;
}

- (NSString *)currentSilverName {
	NSString *name = nil;
	if (!(name = [settings objectForKey:PrefsAltSilverKey]))
		name = [NSString zp_silverName];
	if (![name.pathExtension isEqualToString:@"png"])
		name = [name stringByAppendingPathExtension:@"png"];
	return name;
}

- (NSString *)currentBlackName {
	NSString *name = nil;
	if (!(name = [settings objectForKey:PrefsAltBlackKey]))
		name = [NSString zp_blackName];
	if (![name.pathExtension isEqualToString:@"png"])
		name = [name stringByAppendingPathExtension:@"png"];
	return name;
}

- (NSString *)currentEtchedName {
	NSString *name = nil;
	if (!(name = [settings objectForKey:PrefsAltEtchedKey]))
		name = [NSString zp_etchedName];

	// append extension if none
	if (![name.pathExtension isEqualToString:@"png"])
		name = [name stringByAppendingPathExtension:@"png"];
	return name;
}

- (NSString *)currentLogoName {
	NSString *name = nil;
	if (!(name = [settings objectForKey:PrefsAltLogoKey]))
		name = [NSString zp_logoName];

	// append extension if none
	if (![name.pathExtension isEqualToString:@"png"])
		name = [name stringByAppendingPathExtension:@"png"];
	return name;
}

- (NSString *)currentSilverPath {
	return [[self currentThemeDirectory] stringByAppendingPathComponent:[self currentSilverName]];
}

- (NSString *)currentBlackPath {
	return [[self currentThemeDirectory] stringByAppendingPathComponent:[self currentBlackName]];
}

- (NSString *)currentEtchedPath {
	return [[self currentThemeDirectory] stringByAppendingPathComponent:[self currentEtchedName]];
}

- (NSString *)currentLogoPath {
	return [[self currentThemeDirectory] stringByAppendingPathComponent:[self currentLogoName]];
}

- (NSString *)currentThemeDirectory {
	// if (pack)
		// return [directory stringByAppendingPathComponent: pack];
	return directory;
}

- (void)dealloc {
	[directory release];
	[settings release];
	// [pack release];
	[super dealloc];
}

@end
