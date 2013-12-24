#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ZPAlignedTableViewCell.h"
#include <objc/runtime.h>
#import "Defines.h"
#import "UDTableView.h"

@implementation UIDevice (OSVersion)
- (BOOL)iOSVersionIsAtLeast:(NSString*)version {
    NSComparisonResult result = [[self systemVersion] compare:version options:NSNumericSearch];
    return (result == NSOrderedDescending || result == NSOrderedSame);
}
@end

@interface ZPTheme : NSObject {
	NSString *name;
	NSString *pack;
	BOOL      hidden;
	UIImage *image;
	UIImage *whiteImage;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pack;
@property (nonatomic, retain) UIImage *image, *whiteImage;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
+ (ZPTheme*)themeWithPath:(NSString*)path;
- (id)initWithPath:(NSString*)path;
@end

static NSMutableDictionary *_settings = nil;

@interface ZeppelinSettingsListController: PSListController
- (void)setCurrentTheme:(ZPTheme*)name;
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

- (void)visitWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.alexzielenski.com"]];
}

- (void)visitTwitter:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/alexzielenski"]];
}

- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch*)cell.accessoryView;
	[_settings setObject:[NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];
	
	[self writeSettings];
	
	[self sendSettings];
	
}

- (void)setCurrentTheme:(ZPTheme *)theme {
	[_settings setObject:theme.name forKey:PrefsThemeKey];
	[_settings setObject:theme.pack forKey:PrefsPackKey];

	[_settings removeObjectForKey:PrefsAltSilverKey];
	[_settings removeObjectForKey:PrefsAltBlackKey];
	[_settings removeObjectForKey:PrefsAltEtchedKey];
	
	UITableView *table = self.table;
	UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	cell.detailTextLabel.text = theme.name;
	
	[self sendSettings];
}

- (NSNumber *)enabled {
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

@implementation ZPTheme
@synthesize name, image, whiteImage, pack, hidden;

+ (ZPTheme*)themeWithPath:(NSString*)path {
	return [[[ZPTheme alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString*)path {
	// make sure it is a dir
	BOOL isDir = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	
	if (!exists || !isDir) {
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
		
			
		// no images? kill myself
		if (!self.whiteImage || !self.image) {
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

@interface UITableView (Private)
- (NSArray *) indexPathsForSelectedRows;
@property(nonatomic) BOOL allowsMultipleSelectionDuringEditing;
@end

/* Theme Settings {{{ */
@interface ZPThemesController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_themes;
	NSMutableArray *_packs;
	NSString *selectedTheme;
}
@property (nonatomic, retain) NSMutableArray *themes;
@property (nonatomic, retain) NSMutableArray *packs;
// + (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (NSString*)navigationTitle;
- (void)refreshList;
- (NSArray *)currentThemes;
@end 

@implementation ZPThemesController
@synthesize themes = _themes;
@synthesize packs  = _packs;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {		
		_tableView = [[UDTableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		[_tableView setAllowsSelectionDuringEditing:YES];
		[_tableView setAllowsMultipleSelectionDuringEditing:YES];
		
		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];			
	}
	return self;
}

- (void)addThemesFromDirectory:(NSString *)directory pack: (NSString *)pack {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *diskThemes = [manager contentsOfDirectoryAtPath:directory error:nil];
	
	for (NSString *dirName in diskThemes) {
		NSString *path = [kThemesDirectory stringByAppendingPathComponent:dirName];

		ZPTheme *theme = [ZPTheme themeWithPath:path];
		theme.pack = pack ? pack : @"";
		
		
		if (theme) {
			NSString *themeIdentifier = [theme.pack stringByAppendingFormat: @".%@", theme.name];
			
			if ([[_settings objectForKey: PrefsHiddenKey] containsObject: themeIdentifier])
				theme.hidden = YES;
			
			[self.themes addObject:theme];
		} else
			[self addThemesFromDirectory: path pack: [path lastPathComponent]];
	}
}

- (void)refreshList {
	self.themes = [NSMutableArray array];
	// self.packs  = [NSMutableArray array];
	
	[self addThemesFromDirectory: kThemesDirectory pack: nil];
			
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	[self.themes sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release]; // sort
	
	selectedTheme = [_settings objectForKey:PrefsThemeKey];
	if (!selectedTheme)
		selectedTheme = @"Batman";
}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshList];
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (NSArray *)currentThemes
{	
	if (!_tableView.isEditing) {
	
		return [self.themes filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"hidden == NO"]];
	}
	
	return self.themes;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {	
	// done editing. save the changes into settings
	if (!editing) {
		NSArray* selectedRows = [_tableView indexPathsForSelectedRows];
		NSMutableArray *hiddenThemes = [NSMutableArray array];
		
		for (NSUInteger idx = 0; idx < self.themes.count; idx++) {
			ZPTheme *theme = [self.themes objectAtIndex: idx];
			
			NSIndexPath *path = [NSIndexPath indexPathForRow: idx inSection: 0];
			theme.hidden = [selectedRows containsObject: path];
			
			if (theme.hidden)
				[hiddenThemes addObject: [theme.pack stringByAppendingFormat: @".%@", theme.name]];
	
		}
				
		[_settings setObject: hiddenThemes forKey: PrefsHiddenKey];
		
		ZeppelinSettingsListController *ctrl = (ZeppelinSettingsListController*)self.parentController;
		[ctrl writeSettings]; // no need to send them because they only pertain to the settings part of Zeppelin
	}
	
	[super setEditing:editing animated:animated];
	[_tableView setEditing: editing animated: NO];
	// show hidden items
	[_tableView reloadData];
	
	if (editing) {
		for (NSUInteger idx = 0; idx < self.themes.count; idx++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow: idx inSection: 0];
			ZPTheme *theme = [self.themes objectAtIndex: idx];
			if (theme.isHidden)
				[_tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
			else
				[_tableView deselectRowAtIndexPath: indexPath animated: NO];
		}
	}
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
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currentThemes.count;
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ZPAlignedTableViewCell *cell = (ZPAlignedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ThemeCell"];
    if (!cell) {
        cell = [[[ZPAlignedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThemeCell"] autorelease];
        // 
        // // UIView *colorView = cell.backgroundView.copy;
        // // colorView.backgroundColor = [UIColor colorWithWhite: 0.940 alpha: 1.0];
        // UIImageView *colorView = [[UIImageView alloc] init];
        // 
        // CGRect rect = CGRectMake(0, 0, 1, 1);
        // UIGraphicsBeginImageContext(rect.size);
        // CGContextRef context = UIGraphicsGetCurrentContext();
        // CGContextSetFillColorWithColor(context,
        // 								   [[UIColor colorWithWhite:0.875 alpha: 1.0] CGColor]);
        // 
        // CGContextFillRect(context, rect);
        // UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        // UIGraphicsEndImageContext();
        // 
        // colorView.image = img;
        // 
        // cell.selectedBackgroundView = [colorView autorelease];
    }
    
	ZPTheme *theme = [self.currentThemes objectAtIndex:indexPath.row];
	cell.textLabel.text = theme.name;	
	cell.imageView.image = theme.image;
	cell.imageView.highlightedImage = theme.whiteImage;
	cell.selected = NO;

	if ([theme.name isEqualToString: selectedTheme]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.isEditing) {
		// deselect old one
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
		UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: [[self.currentThemes valueForKey:@"name"] indexOfObject: selectedTheme] inSection: 0]];
		if (old)
			old.accessoryType = UITableViewCellAccessoryNone;

		// check it off
		cell.accessoryType = UITableViewCellAccessoryCheckmark;

		ZPTheme *theme = (ZPTheme*)[self.currentThemes objectAtIndex:indexPath.row];
	
		// make the title changes
		ZeppelinSettingsListController *ctrl = (ZeppelinSettingsListController*)self.parentController;
		[ctrl setCurrentTheme:theme];
	
		selectedTheme = theme.name;

	} else {
		// future pack functionality
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
	return (UITableViewCellEditingStyle)3;
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
