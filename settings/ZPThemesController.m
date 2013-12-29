#import "Defines.h"
#import "ZPThemesController.h"
#import "ZeppelinSettings.h"

// #import "UDTableView.h"
#import "ZPAlignedTableViewCell.h"
#include <objc/runtime.h>

@implementation UIDevice (OSVersion)
- (BOOL)iOSVersionIsAtLeast:(NSString*)version {
    NSComparisonResult result = [[self systemVersion] compare:version options:NSNumericSearch];
    return (result == NSOrderedDescending || result == NSOrderedSame);
}
@end

@interface UITableView (Private)
- (NSArray *) indexPathsForSelectedRows;
@property(nonatomic) BOOL allowsMultipleSelectionDuringEditing;
@end


@implementation ZPThemesController
@synthesize themes = _themes;
@synthesize packs  = _packs;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		[_tableView setAllowsSelection:YES];

		if ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"]) {
			[_tableView setAllowsMultipleSelection:NO];
			[_tableView setAllowsSelectionDuringEditing:YES];
			[_tableView setAllowsMultipleSelectionDuringEditing:YES];
		}
		
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
			ZeppelinSettingsListController *ctrl = (ZeppelinSettingsListController*)self.parentController;

			if ([[ctrl.settings objectForKey: PrefsHiddenKey] containsObject: themeIdentifier])
				theme.hidden = YES;
			
			[self.themes addObject:theme];
		} else
			[self addThemesFromDirectory: path pack: [path lastPathComponent]];
	}
}

- (void)refreshList {
	self.themes = [NSMutableArray array];
	// self.packs  = [NSMutableArray array];
	ZeppelinSettingsListController *ctrl = (ZeppelinSettingsListController*)self.parentController;
	[self addThemesFromDirectory: kThemesDirectory pack: nil];
			
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	[self.themes sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release]; // sort
	
	selectedTheme = [ctrl.settings objectForKey:PrefsThemeKey];
	if (!selectedTheme)
		selectedTheme = @"Batman";
}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshList];

	if ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"])
		self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (NSArray *)currentThemes {
	if (!_tableView.isEditing) {
	
		return [self.themes filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"hidden == NO"]];
	}
	
	return self.themes;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {	
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
		ZeppelinSettingsListController *ctrl = (ZeppelinSettingsListController*)self.parentController;
		[(NSMutableDictionary *)ctrl.settings setObject: hiddenThemes forKey: PrefsHiddenKey];
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
    }
    
	ZPTheme *theme = [self.currentThemes objectAtIndex:indexPath.row];
	cell.textLabel.text = theme.name;	
	cell.imageView.image = theme.image;
	cell.imageView.highlightedImage = theme.whiteImage;
	cell.selected = NO;

	if ([theme.name isEqualToString: selectedTheme] && !tableView.isEditing) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else if (!tableView.isEditing) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!tableView.isEditing) {
		// deselect old one
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	
		UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: [[self.currentThemes valueForKey:@"name"] indexOfObject: selectedTheme] inSection: 0]];
		if (old)
			old.accessoryType = UITableViewCellAccessoryNone;


		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
