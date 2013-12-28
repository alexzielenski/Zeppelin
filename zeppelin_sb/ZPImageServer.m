#import "ZPImageServer.h"
#import "Categories/NSString+ZPAdditions.h"

@interface ZPImageServer ()
@property (retain, nonatomic) NSDictionary *_settings;
@end

@implementation ZPImageServer
@synthesize enabled, noLogo, shouldTint, themeName, packName, _settings, shouldUseOldMethod, carrierText;

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
		self.settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	}
	return self;
}

- (void)setSettings:(NSDictionary *)newSettings {
	self._settings = newSettings;

	if (!self._settings) {
		NSLog(@"Zeppelin: No settings found. Reverting to defaults.");
		self._settings = DefaultPrefs;
	}

	self.themeName  = [self._settings objectForKey:PrefsThemeKey];
	self.enabled    = [[self._settings objectForKey:PrefsEnabledKey] boolValue];
	self.noLogo     = [[self._settings objectForKey:PrefsThemeKey] isEqualToString:@"None"];
	self.shouldTint = ([[NSFileManager defaultManager] fileExistsAtPath: self.currentLogoPath]);
	self.shouldUseOldMethod = [[self._settings objectForKey:PrefsOldMethodKey] boolValue];
	self.carrierText = [self._settings objectForKey:PrefsCarrierTextKey];
	// self.packName       = [self._settings objectForKey: PrefsPackKey];

}

- (NSDictionary *)settings {
	return self._settings;
}

- (NSString *)currentSilverName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltSilverKey])))
		name = [NSString zp_silverName];
	return name;
}

- (NSString *)currentBlackName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltBlackKey])))
		name = [NSString zp_blackName];
	return name;
}

- (NSString *)currentEtchedName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltEtchedKey])))
		name = [NSString zp_etchedName];
		name = [name stringByAppendingPathExtension:@"png"];
	return name;
}

- (NSString *)currentLogoName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltLogoKey])))
		name = [NSString zp_logoName];
	return name;
}

- (NSString *)currentSilverPath {
	return [self.currentThemeDirectory stringByAppendingPathComponent:self.currentSilverName];
}

- (NSString *)currentBlackPath {
	return [self.currentThemeDirectory stringByAppendingPathComponent:self.currentBlackName];
}

- (NSString *)currentEtchedPath {
	return [self.currentThemeDirectory stringByAppendingPathComponent:self.currentEtchedName];
}

- (NSString *)currentLogoPath {
	return [self.currentThemeDirectory stringByAppendingPathComponent:self.currentLogoName];
}

- (NSString *)currentThemeDirectory {
	NSString *directory = [kThemesDirectory stringByAppendingPathComponent: self.themeName];
	// if (self.packName)
		// return [directory stringByAppendingPathComponent: self.packName];
	return directory;
}

- (void)dealloc {
	self._settings = nil;
	self.themeName = nil;
	self.packName  = nil;

	[super dealloc];
}

@end
