#import <UIKit/UIKit.h>
#define PrefsThemeKey        @"theme"
#define PrefsCarrierTextKey  @"carrierText"
#define PrefsUseTextKey      @"useText"
#define PrefsEnabledKey      @"enabled"
#define PrefsOldMethodKey    @"useOldMethod"
#define PrefsAltSilverKey    @"altSilver" // would be silver-alt1@2x/.png
#define PrefsAltBlackKey     @"altBlack"
#define PrefsAltEtchedKey    @"altEtched"

#define IS_IOS_50_OR_LATER() (kCFCoreFoundationVersionNumber >= 675.00)
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
