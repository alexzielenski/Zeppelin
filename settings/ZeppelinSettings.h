#import <Preferences/PSListController.h>
#import "ZPTheme.h"

@interface ZeppelinSettingsListController: PSListController {
	NSMutableDictionary *_settings;
}
@property (nonatomic, readonly) NSMutableDictionary *settings;
@property (retain, nonatomic) UIBarButtonItem *carrierTextButton;
- (void)setCurrentTheme:(ZPTheme*)name;
- (void)writeSettings;
- (void)sendSettings;
@end