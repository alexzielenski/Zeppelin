#import "Defines.h"

@interface ZPImageServer : NSObject {
	BOOL enabled;
	BOOL noLogo;
	NSString *directory;
	NSString *pack;
	NSDictionary *settings;
}
+ (ZPImageServer*)sharedServer;
- (BOOL)enabled;
- (BOOL)useOldMethod;
- (BOOL)noLogo;

- (NSString*)currentSilverName;
- (NSString*)currentBlackName;
- (NSString*)currentEtchedName;

- (NSString*)currentSilverPath;
- (NSString*)currentBlackPath;
- (NSString*)currentEtchedPath;
- (NSString*)currentThemeDirectory;

- (void)setSettings:(NSDictionary *)newSettings;
- (NSDictionary*)settings;
@end