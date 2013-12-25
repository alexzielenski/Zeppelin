#import <Preferences/PSViewController.h>

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
