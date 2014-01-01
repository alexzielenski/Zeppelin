#import "Defines.h"

@interface ZPImageServer : NSObject
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;
@property (assign, nonatomic) BOOL noLogo;
@property (assign, nonatomic) BOOL shouldTint;
@property (assign, nonatomic) BOOL shouldUseOldMethod;
@property (assign, nonatomic) BOOL shouldUseLegacyImages;
@property (copy, nonatomic) NSString *themeName;
@property (copy, nonatomic) NSString *packName;
@property (copy, nonatomic) NSString *carrierText;

+ (ZPImageServer*)sharedServer;
- (NSString *)currentSilverName;
- (NSString *)currentBlackName;
- (NSString *)currentEtchedName;
- (NSString *)currentLogoName;
- (NSString *)currentDarkName;
- (NSString *)currentLightName;

- (NSString *)currentSilverPath;
- (NSString *)currentBlackPath;
- (NSString *)currentEtchedPath;
- (NSString *)currentLogoPath;
- (NSString *)currentDarkPath;
- (NSString *)currentLightPath;
- (NSString *)currentThemeDirectory;

- (void)setSettings:(NSDictionary *)newSettings;
- (NSDictionary *)settings;
@end