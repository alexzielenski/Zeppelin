#import "ZeppelinSettings.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "Defines.h"
#import "ZPTheme.h"

@interface ZeppelinSettingsListController () {
	NSMutableDictionary *_settings;
}
- (IBAction)carrierText:(UIBarButtonItem *)item;
@property (retain, nonatomic) UITextField *carrierTextField;
@property (retain, nonatomic) UIAlertView *carrierAlertView;
@property (nonatomic, retain, readwrite) NSMutableDictionary *settings;

@end

@implementation ZeppelinSettingsListController
@synthesize settings = _settings;
@synthesize carrierTextButton;
@synthesize carrierAlertView;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {
		self.settings = [([NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH] ?: DefaultPrefs) retain];
		self.carrierTextButton = [[[UIBarButtonItem alloc] initWithTitle:@"Carrier Text" 
																  style:UIBarButtonItemStyleBordered
																 target:self 
																 action:@selector(carrierText:)] autorelease];
	}
	return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ZeppelinSettings" target:self] retain];
	}
	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];
    if ([[spec propertyForKey:@"negate"] boolValue])
        value = [NSNumber numberWithBool:(![value boolValue])];
    [_settings setValue:value forKey:key];
}

- (id)readPreferenceValue:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];
    id defaultValue = [spec propertyForKey:@"default"];
    id plistValue = [self.settings objectForKey:key];

    if (!plistValue)
        return defaultValue;
    if ([[spec propertyForKey:@"negate"] boolValue])
        plistValue = [NSNumber numberWithBool: (![plistValue boolValue])];
    return plistValue;
}

- (void)visitWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.alexzielenski.com"]];
}

- (void)visitTwitter:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/alexzielenski"]];
}

- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch *)cell.accessoryView;
	[_settings setObject: [NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];

	[self writeSettings];
	[self sendSettings];
}

- (void)setCurrentTheme:(ZPTheme *)theme {
	if ([theme.name isEqualToString: [_settings objectForKey: PrefsThemeKey]])
		return;
	
	[_settings setObject:theme.name forKey:PrefsThemeKey];
	[_settings setObject:theme.pack forKey:PrefsPackKey];

	[_settings removeObjectForKey:PrefsAltSilverKey];
	[_settings removeObjectForKey:PrefsAltBlackKey];
	[_settings removeObjectForKey:PrefsAltEtchedKey];
	[_settings removeObjectForKey:PrefsAltLogoKey];
	
	UITableView *table = self.table;
	UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	cell.detailTextLabel.text = theme.name;

	if (theme.useDark) {
		[_settings setObject: kDarkImageName forKey: PrefsAltLogoKey];
	}
	
	[self sendSettings];
}

- (NSNumber *)enabled {
	return [self.settings objectForKey:PrefsEnabledKey];
}

- (void)setEnabled:(NSNumber *)enabled {
	[_settings setObject:enabled forKey:PrefsEnabledKey];
	[self sendSettings];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	self.navigationItem.rightBarButtonItem = self.carrierTextButton;
}

- (IBAction)carrierText:(UIBarButtonItem *)item {

	if (!self.carrierAlertView) {
		self.carrierAlertView = [[UIAlertView alloc] initWithTitle:@"Enter your carrier text:"
		                                                 message:@"\n\n"
		                                                delegate:self
		                                       cancelButtonTitle:@"Cancel"
		                                       otherButtonTitles:@"Save", @"Revert", nil];
	}

	CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *carrier = [netinfo subscriberCellularProvider];
	NSString *carrierName = carrier.carrierName;
	[netinfo release];

	// the prompt api was added in ios 5
	if (IS_IOS_40()) {
		if (!self.carrierTextField) {
			self.carrierTextField = [[[UITextField alloc] initWithFrame:CGRectMake(12, 50, 260, 25)] autorelease];
			[self.carrierTextField setBackgroundColor:[UIColor whiteColor]];
			[self.carrierTextField setPlaceholder:@"Carrier Text"];
			self.carrierTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
			[self.carrierAlertView addSubview:self.carrierTextField];
		}

		self.carrierTextField.placeholder = carrierName;
		self.carrierTextField.text = [_settings objectForKey: PrefsCarrierTextKey];

		// show the dialog box
		[self.carrierAlertView show];

		// set cursor and show keyboard
		[self.carrierTextField becomeFirstResponder];
	} else {
		self.carrierAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		UITextField *field = [self.carrierAlertView textFieldAtIndex: 0];
		field.text = [_settings objectForKey: PrefsCarrierTextKey];
		field.placeholder = carrierName;

		[self.carrierAlertView show];
	}
}

- (void)writeSettings {
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:self.settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

	if (!data)
		return;
	if (![data writeToFile:PREFS_PATH atomically:NO])
		return;
}

- (void)sendSettings {
	[self writeSettings];

	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(r, (CFStringRef)kZeppelinSettingsChanged, NULL, (CFDictionaryRef)self.settings, true);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex { 
	if (buttonIndex == 1) {// save
		NSString *text = nil;

		if ([alertView respondsToSelector: @selector(textFieldAtIndex:)]) {
		    text = [[alertView textFieldAtIndex:0] text];
		} else {
			text = self.carrierTextField.text;
		}

		if (text)
			[_settings setObject:text forKey: PrefsCarrierTextKey];
	} else if (buttonIndex == 2) { // revert
		[_settings removeObjectForKey: PrefsCarrierTextKey];
	}

	[self sendSettings];
}

- (void)suspend {
	[self writeSettings];
}

- (void)dealloc {
	// set the enabled value
	[self writeSettings];

	self.carrierAlertView = nil;
	self.carrierTextField = nil;
	self.settings = nil;

	[super dealloc];
}

@end
