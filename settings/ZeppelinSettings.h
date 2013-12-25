#import <Preferences/PSListController.h>
#import "ZPTheme.h"

@interface ZeppelinSettingsListController: PSListController {
	NSMutableDictionary *_settings;
}
@property (nonatomic, readonly) NSMutableDictionary *settings;
- (void)setCurrentTheme:(ZPTheme*)name;
- (void)writeSettings;
- (void)sendSettings;
@end