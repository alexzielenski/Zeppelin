#import <UIKit/UIKit.h>

@interface UIImage (MGTint)
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
@end
