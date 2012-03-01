#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import "ZPAlignedTableViewCell.h"
#include <objc/runtime.h>
#import "Defines.h"

static NSMutableDictionary *_settings = nil;

@interface ZeppelinSettingsListController: PSListController
- (void)setCurrentTheme:(NSString*)name;
- (void)writeSettings;
- (void)sendSettings;
@end

@implementation ZeppelinSettingsListController
- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {
		_settings = [([NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH] ?: DefaultPrefs) retain];
	}
	return self;
}
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ZeppelinSettings" target:self] retain];
	}
	return _specifiers;
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
    NSString *key([spec propertyForKey:@"key"]);
    if ([[spec propertyForKey:@"negate"] boolValue])
        value = [NSNumber numberWithBool:(![value boolValue])];
    [_settings setValue:value forKey:key];
}

- (id)readPreferenceValue:(PSSpecifier *)spec {
    NSString *key([spec propertyForKey:@"key"]);
    id defaultValue([spec propertyForKey:@"default"]);
    id plistValue([_settings objectForKey:key]);

    if (!plistValue)
        return defaultValue;
    if ([[spec propertyForKey:@"negate"] boolValue])
        plistValue = [NSNumber numberWithBool:(![plistValue boolValue])];
    return plistValue;
}
- (void)donateButton:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H6B999S6C3UX2"]];
}
- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch*)cell.accessoryView;
	[_settings setObject:[NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];
	
	[self writeSettings];
	
	[self sendSettings];
	
}
- (void)setCurrentTheme:(NSString*)name {
	[_settings setObject:name forKey:PrefsThemeKey];

	[_settings removeObjectForKey:PrefsAltSilverKey];
	[_settings removeObjectForKey:PrefsAltBlackKey];
	[_settings removeObjectForKey:PrefsAltEtchedKey];
	
	UITableView *table = self.table;
	UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	cell.detailTextLabel.text = name;
	
	[self sendSettings];
}
- (NSNumber*)enabled {
	return [_settings objectForKey:PrefsEnabledKey];
}
- (void)setEnabled:(NSNumber*)enabled {
	[_settings setObject:enabled forKey:PrefsEnabledKey];
	[self sendSettings];
}
- (void)writeSettings {
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

	if (!data)
		return;
	if (![data writeToFile:PREFS_PATH atomically:NO])
		return;
}
- (void)sendSettings {
	[self writeSettings];

	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(r, (CFStringRef)kZeppelinSettingsChanged, NULL, (CFDictionaryRef)_settings, true);
}
- (void)suspend {
	[self writeSettings];
}
- (void)dealloc {
	// set the enabled value
	[self writeSettings];
	
	[_settings release];
	[super dealloc];
}
@end

@interface ZPTheme : NSObject {
	NSString *name;
	UIImage *image;
	UIImage *whiteImage;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *image, *whiteImage;
+ (ZPTheme*)themeWithPath:(NSString*)path;
- (id)initWithPath:(NSString*)path;
@end

@implementation ZPTheme
@synthesize name, image, whiteImage;
+ (ZPTheme*)themeWithPath:(NSString*)path {
	return [[[ZPTheme alloc] initWithPath:path] autorelease];
}
- (id)initWithPath:(NSString*)path {
	// make sure it is a dir
	BOOL isDir = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	if (!exists||!isDir) {
		[self release];
		return nil;
	}
	if ((self = [super init])) {
		self.name = [[path lastPathComponent] stringByDeletingPathExtension];
		// Find out which image to use
		BOOL retina = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2);
		NSString *silverName = nil;
		if (!retina)
			silverName = kSilverImageName;
		if (retina)
			silverName = [kSilverImageName stringByAppendingString:@"@2x"];
			
		silverName = [silverName stringByAppendingString:@".png"];
		self.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];
		
		NSString *blackName = nil;
		if (!retina)
			blackName = kBlackImageName;
		if (retina)
			blackName = [kBlackImageName stringByAppendingString:@"@2x"];

		blackName = [blackName stringByAppendingString:@".png"];
		self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];
		
		if (!whiteImage) {
			if (!retina)
				blackName = kEtchedImageName;
			if (retina)
				blackName = [kEtchedImageName stringByAppendingString:@"@2x"];
			blackName = [blackName stringByAppendingString:@".png"];
			self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];
		}
		
		if (self.whiteImage&&!self.image)
			self.image = self.whiteImage;
		else if (self.image&&!self.whiteImage)
			self.whiteImage = self.image;
			
		// no images? kill myself
		if (!self.whiteImage||!self.image) {
			[self release];
			return nil;
		}
	}
	return self;
}
- (void)dealloc {
	self.name = nil;
	self.image = nil;
	self.whiteImage = nil;
	[super dealloc];
}
@end

/* Theme Settings {{{ */
@interface ZPThemesController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_themes;
	NSInteger selectedRow;
}
@property (nonatomic, retain) NSMutableArray *themes;
// + (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (NSString*)navigationTitle;
- (void)refreshList;
@end 

@implementation ZPThemesController
@synthesize themes = _themes;
- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];
			
		[self refreshList];
	}
	return self;
}
- (void)refreshList {
	self.themes = [NSMutableArray array];
	
	NSArray *diskThemes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kThemesDirectory error:nil];
	for (NSString *dirName in diskThemes) {
		NSString *path = [kThemesDirectory stringByAppendingPathComponent:dirName];
		ZPTheme *theme = [ZPTheme themeWithPath:path];
		if (theme)
			[self.themes addObject:theme];
	}
	
		
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	[self.themes sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release]; // sort
	
		
	NSArray *themeNames = [_themes valueForKey:@"name"];
	selectedRow = [themeNames indexOfObject:[_settings objectForKey:PrefsThemeKey]];
	if (selectedRow == NSNotFound)
		selectedRow = [themeNames indexOfObject:@"Batman"];
	if (selectedRow == NSNotFound)
		selectedRow = 0;
}
- (void)viewWillAppear:(BOOL)animated {
	[self refreshList];
}
- (void)dealloc { 
	self.themes = nil;
	[super dealloc];
}
- (NSString*)navigationTitle {
	return @"Themes";
}
- (id)view {
	return _tableView;
}
/* UITableViewDelegate / UITableViewDataSource Methods {{{ */
- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    return @"";
}
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return _themes.count;
}
- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ZPAlignedTableViewCell *cell = (ZPAlignedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ThemeCell"];
    if (!cell) {
        cell = [[[ZPAlignedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThemeCell"] autorelease];
    }
	ZPTheme *theme = [self.themes objectAtIndex:indexPath.row];
	cell.textLabel.text = theme.name;
	
	cell.imageView.image = theme.image;
	// cell.imageView.contentMode = UIViewContentModeCenter;
	
	cell.imageView.highlightedImage = theme.whiteImage;
	
	if (indexPath.row == (NSInteger)selectedRow)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// deselect old one
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	// check it off
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	// uncheck prev
	UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
	if (old!=cell) {
		old.accessoryType = UITableViewCellAccessoryNone;
	}
	
	ZPTheme *theme = (ZPTheme*)[self.themes objectAtIndex:indexPath.row];
	
	// make the title changes
	ZeppelinSettingsListController *ctrl = (ZeppelinSettingsListController*)self.parentController;
	[ctrl setCurrentTheme:theme.name];
	
	selectedRow = indexPath.row;
}
@end

// borrowed from winterboard
#define WBSAddMethod(_class, _sel, _imp, _type) \
    if (![[_class class] instancesRespondToSelector:@selector(_sel)]) \
        class_addMethod([_class class], @selector(_sel), (IMP)_imp, _type)

void $PSViewController$hideNavigationBarButtons(PSRootController *self, SEL _cmd) {
}

id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGRect contentSize) {
    return [self init];
}

static __attribute__((constructor)) void __wbsInit() {
    WBSAddMethod(PSViewController, hideNavigationBarButtons, $PSViewController$hideNavigationBarButtons, "v@:");
    WBSAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");
}