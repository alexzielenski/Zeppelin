#import <UIKit/UIKit.h>
#define PrefsThemeKey        @"theme"
#define PrefsCarrierTextKey  @"carrierText"
#define PrefsUseTextKey      @"useText"
#define PrefsEnabledKey      @"enabled"
#define PrefsOldMethodKey    @"useOldMethod"
#define PrefsAltSilverKey    @"altSilver" // would be silver-alt1@2x/.png
#define PrefsAltBlackKey     @"altBlack"
#define PrefsAltEtchedKey    @"altEtched"

#define IN_SPRINGBOARD()     ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
#define IS_RETINA()          ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define PREFS_PATH           [NSString stringWithFormat:@"%@/Library/Preferences/com.alexzielenski.zeppelin.plist", NSHomeDirectory()]

#define kZeppelinSettingsChanged         @"com.alexzielenski.zeppelin/settingsChanged"
#define kZeppelinSettingsRefreshSettings @"com.alexzielenski.zeppelin/refreshSettings"

#define kBlackImageName      @"black"
#define kSilverImageName     @"silver"
#define kEtchedImageName     @"etched"

#define kThemesDirectory     @"/Library/Zeppelin"
#define DefaultPrefs         [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Batman", PrefsThemeKey, [NSNumber numberWithBool:YES], PrefsEnabledKey, nil]

@interface UIDevice (de)
- (BOOL)iOSVersionIsAtLeast:(NSString *)vers;
@end

#define IS_IOS_60_OR_LATER() [[UIDevice currentDevice] iOSVersionIsAtLeast: @"6.0"]
#define IS_IOS_50()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"] && !IS_IOS_60_OR_LATER())
#define IS_IOS_40()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"4.2"] && !IS_IOS_50())

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
