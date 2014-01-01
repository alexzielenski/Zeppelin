#import <UIKit/UIKit.h>
#import <substrate.h>

#define ZLog(format, ...) NSLog(@"Zeppelin: %@", [NSString stringWithFormat: format, ## __VA_ARGS__])

#define PrefsThemeKey        @"theme"
#define PrefsCarrierTextKey  @"carrierText"
#define PrefsUseTextKey      @"useText"
#define PrefsEnabledKey      @"enabled"
#define PrefsOldMethodKey    @"useOldMethod"
#define PrefsAltSilverKey    @"altSilver" // would be silver-alt1@2x.png
#define PrefsAltBlackKey     @"altBlack"
#define PrefsAltEtchedKey    @"altEtched"
#define PrefsAltLogoKey      @"altLogo"
#define PrefsAltDarkKey      @"altDark"
#define PrefsAltLightKey     @"altLight"
#define PrefsPackKey         @"pack"
#define PrefsHiddenKey       @"hiddenThemes"
#define PrefsShouldTintKey   @"shouldTint"
#define PrefsUseLegacyKey    @"useLegacy"

#define IN_SPRINGBOARD()     ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
#define IS_RETINA()          ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define PREFS_PATH           [NSString stringWithFormat:@"%@/Library/Preferences/com.alexzielenski.zeppelin.plist", NSHomeDirectory()]
#define RETINIZE(r)          [(IS_RETINA()) ? [r stringByAppendingString:@"@2x"] : r stringByAppendingPathExtension: @"png"]

#define kZeppelinSettingsChanged         @"com.alexzielenski.zeppelin/settingsChanged"
#define kZeppelinSettingsRefreshSettings @"com.alexzielenski.zeppelin/refreshSettings"

#define kBlackImageName      @"black"
#define kSilverImageName     @"silver"
#define kEtchedImageName     @"etched"
#define kLogoImageName       @"logo"
#define kDarkImageName       @"dark"
#define kLightImageName      @"light"

#define kThemesDirectory     @"/Library/Zeppelin"
#define kPacksDirectory      @"/Library/Zeppelin/Packs"
#define DefaultPrefs         [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Zeppelin", PrefsPackKey, @"Batman", PrefsThemeKey, [NSNumber numberWithBool:YES], PrefsEnabledKey, [NSNumber numberWithBool: YES], PrefsShouldTintKey, [NSNumber numberWithBool: NO], PrefsUseLegacyKey, nil]

@interface UIDevice (de)
- (BOOL)iOSVersionIsAtLeast:(NSString *)vers;
@end

#define IS_IOS_70_OR_LATER() [[UIDevice currentDevice] iOSVersionIsAtLeast: @"7.0"]
#define IS_IOS_60()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"6.0"] && !IS_IOS_70_OR_LATER())
#define IS_IOS_50()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"] && !IS_IOS_60() && !IS_IOS_70_OR_LATER())
#define IS_IOS_40()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"4.2"] && !IS_IOS_50() && !IS_IOS_60() && !IS_IOS_70_OR_LATER())

typedef struct {
    BOOL itemIsEnabled[25]; // 25 max items
    int gsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    char serviceString[100];
    char serviceCrossfadeString[100];
    unsigned int serviceContentType;
    char serviceImages[3][100]; // 3 max items
    char serviceImageBlack[100];
    char serviceImageSilver[100];
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned int dataNetworkType;
    int batteryCapacity;
    unsigned int batteryState;
    int bluetoothBatteryCapacity;
    int thermalColor;
    char operatorDirectory[1024];
} StatusBarDataCommon;

typedef struct {
    BOOL itemIsEnabled[25];
    BOOL timeString[64];
    int gsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    char serviceString[100];
    char serviceCrossfadeString[100];
    char serviceImages[2][100];
    char operatorDirectory[1024];
    unsigned serviceContentType;
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned dataNetworkType;
    int batteryCapacity;
    unsigned batteryState;
    BOOL batteryDetailString[150];
    int bluetoothBatteryCapacity;
    int thermalColor;
    unsigned thermalSunlightMode : 1;
    unsigned slowActivity : 1;
    unsigned syncActivity : 1;
    BOOL activityDisplayId[256];
    unsigned bluetoothConnected : 1;
    unsigned displayRawGSMSignal : 1;
    unsigned displayRawWifiSignal : 1;
    unsigned locationIconType : 1;
    unsigned quietModeInactive : 1;
    unsigned tetheringConnectionCount;
} StatusBarData70;

typedef struct {
    char itemIsEnabled[23];
    char timeString[64];
    int gsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    char serviceString[100];
    char serviceCrossfadeString[100];
    char serviceImages[2][100];
    char operatorDirectory[1024];
    unsigned int serviceContentType;
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned int dataNetworkType;
    int batteryCapacity;
    unsigned int batteryState;
    char notChargingString[150];
    int bluetoothBatteryCapacity;
    int thermalColor;
    unsigned int thermalSunlightMode:1;
    unsigned int slowActivity:1;
    unsigned int syncActivity:1;
    char activityDisplayId[256];
    unsigned int bluetoothConnected:1;
    unsigned int displayRawGSMSignal:1;
    unsigned int displayRawWifiSignal:1;
    unsigned int locationIconType:1;
} StatusBarData60;

typedef struct  {
	char itemIsEnabled[23];
	char timeString[64];
	int gsmSignalStrengthRaw;
	int gsmSignalStrengthBars;
	char serviceString[100];
	char serviceCrossfadeString[100];
	char serviceImages[3][100];
	char operatorDirectory[1024];
	unsigned serviceContentType;
	int wifiSignalStrengthRaw;
	int wifiSignalStrengthBars;
	unsigned dataNetworkType;
	int batteryCapacity;
	unsigned batteryState;
	char notChargingString[150];
	int bluetoothBatteryCapacity;
	int thermalColor;
	unsigned thermalSunlightMode : 1;
	unsigned slowActivity : 1;
	unsigned syncActivity : 1;
	char activityDisplayId[256];
	unsigned bluetoothConnected : 1;
	unsigned displayRawGSMSignal : 1;
	unsigned displayRawWifiSignal : 1;
} StatusBarData50;

typedef struct  {
	char itemIsEnabled[22];
	char timeString[64];
	int gsmSignalStrengthRaw;
	int gsmSignalStrengthBars;
	char serviceString[100];
	char serviceImageBlack[100];
	char serviceImageSilver[100];
	char operatorDirectory[1024];
	unsigned int serviceContentType;
	int wifiSignalStrengthRaw;
	int wifiSignalStrengthBars;
	unsigned int dataNetworkType;
	int batteryCapacity;
	unsigned int batteryState;
	char notChargingString[150];
	int bluetoothBatteryCapacity;
	int thermalColor;
	bool slowActivity;
	char activityDisplayId[256];
	bool bluetoothConnected;
	char recordingAppString[100];
	bool displayRawGSMSignal;
	bool displayRawWifiSignal;
} StatusBarData42;
