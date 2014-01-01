#import <UIKit/UIKit.h>

@interface ZPTheme : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pack;
@property (nonatomic, retain) UIImage *image, *whiteImage;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
@property (nonatomic, assign) BOOL shouldTint;
@property (nonatomic, assign) BOOL shouldUseLegacyImages;
+ (ZPTheme *)themeWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end