#import <UIKit/UIKit.h>

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

+ (ZPTheme *)themeWithPath:(NSString*)path;
- (id)initWithPath:(NSString*)path;

@end