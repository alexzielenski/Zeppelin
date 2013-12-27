#import "Defines.h"

@interface ZPImageServer : NSObject {
	BOOL enabled;
	BOOL noLogo;
	BOOL shouldTint;
	NSString *directory;
	NSString *pack;
	NSDictionary *settings;
}
+ (ZPImageServer*)sharedServer;
- (BOOL)enabled;
- (BOOL)useOldMethod;
- (BOOL)noLogo;
- (BOOL)shouldTint;

- (NSString *)currentSilverName;
- (NSString *)currentBlackName;
- (NSString *)currentEtchedName;
- (NSString *)currentLogoName;

- (NSString *)currentSilverPath;
- (NSString *)currentBlackPath;
- (NSString *)currentEtchedPath;
- (NSString *)currentLogoPath;
- (NSString *)currentThemeDirectory;

- (void)setSettings:(NSDictionary *)newSettings;
- (NSDictionary *)settings;
@end