#import "ZPImageServer.h"
#import "Categories/NSString+ZPAdditions.h"

@interface ZPImageServer ()
@property (retain, nonatomic) NSDictionary *_settings;
@end

@implementation ZPImageServer
@synthesize enabled, noLogo, shouldTint, themeName, packName, _settings, shouldUseOldMethod;
@synthesize carrierText;
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
		[self setSettings: [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
	}
	return self;
}

- (void)setSettings:(NSDictionary *)newSettings {
	self._settings = newSettings;

	if (!self._settings) {
		ZLog(@"No settings found. Reverting to defaults.");
		self._settings = DefaultPrefs;
	}

	NSNumber *nabled = [_settings objectForKey:PrefsEnabledKey];
	NSNumber *useOld = [_settings objectForKey:PrefsOldMethodKey];

	self.themeName   = [_settings objectForKey:PrefsThemeKey];
	if (nabled)
		self.enabled = [nabled boolValue];
	self.noLogo      = [[_settings objectForKey:PrefsThemeKey] isEqualToString:@"None"];
	if (useOld)
		self.shouldUseOldMethod = [useOld boolValue];
	self.carrierText = [_settings objectForKey:@"carrierText"];

	if (IS_IOS_70_OR_LATER()) {
		self.shouldTint = [[_settings objectForKey: PrefsShouldTintKey] boolValue];
		self.shouldUseLegacyImages = [[_settings objectForKey: PrefsUseLegacyKey] boolValue];
	}

	// self.packName    = [_settings objectForKey:PrefsPackKey];
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
	return name;
}

- (NSString *)currentLogoName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltLogoKey])))
		name = [NSString zp_logoName];
	return name;
}

- (NSString *)currentDarkName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltDarkKey])))
		name = [NSString zp_darkName];
	return name;
}

- (NSString *)currentLightName {
	NSString *name = nil;
	if (!(name = RETINIZE([self.settings objectForKey:PrefsAltLightKey])))
		name = [NSString zp_lightName];
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

- (NSString *)currentDarkPath {
	return [self.currentThemeDirectory stringByAppendingPathComponent:self.currentDarkName];
}

- (NSString *)currentLightPath {
	return [self.currentThemeDirectory stringByAppendingPathComponent:self.currentLightName];
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
