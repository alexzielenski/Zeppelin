#import <Preferences/PSListController.h>
#import "ZPTheme.h"

@interface ZeppelinSettingsListController: PSListController
@property (retain, nonatomic) UIBarButtonItem *carrierTextButton;
@property (nonatomic, retain, readonly) NSDictionary *settings;
- (void)setCurrentTheme:(ZPTheme*)name;
- (void)writeSettings;
- (void)sendSettings;
@end
