#import <UIKit/UIKit.h>
#import "Defines.h"
#import <UIKit70/UIStatusBarServiceItemView.h>
#import <UIKit70/UIStatusBarComposedData.h>
#import <UIKit70/_UILegibilityImageSet.h>
#import <UIKit70/UIImage-_UILegibility.h>
#import <UIKit70/_UILegibilitySettings.h>
#import <UIKit70/UIStatusBarForegroundStyleAttributes.h>

@interface UIImage (MGTint)

- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;

@end

@implementation UIImage (MGTint)


- (UIImage *)imageTintedWithColor:(UIColor *)color
{
        // This method is designed for use with template images, i.e. solid-coloured mask-like images.
        return [self imageTintedWithColor:color fraction:0.0]; // default to a fully tinted mask of the image.
}


- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction
{
        if (color) {
                // Construct new image the same size as this one.
                UIImage *image;
                
                if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
                        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f); // 0.f for scale means "scale for device's main screen".
                } else {
                        UIGraphicsBeginImageContext([self size]);
                }
                CGRect rect = CGRectZero;
                rect.size = [self size];
                
                // Composite tint color at its own opacity.
                [color set];
                UIRectFill(rect);
                
                // Mask tint color-swatch to this image's opaque mask.
                // We want behaviour like NSCompositeDestinationIn on Mac OS X.
                [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
                
                // Finally, composite this image over the tinted mask at desired opacity.
                if (fraction > 0.0) {
                        // We want behaviour like NSCompositeSourceOver on Mac OS X.
                        [self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
                }
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                return image;
        }
        
        return self;
}

@end

@interface UIStatusBarServiceItemView ()
- (UIImage *)zp_imageNamed:(NSString *)name;
- (void)zp_cacheImage:(UIImage *)image named:(NSString *)name;
- (BOOL)shouldTint;
- (BOOL)isEnabled;
@end

%hook UIStatusBarServiceItemView
static char kBLACKIMAGE;
static char kWHITEIMAGE;
static char kOPERATORDIRECTORY;
static char kIMAGECACHE;

- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2 {
	StatusBarData70 *data = (StatusBarData70*)[arg1 rawData];

	[self updateContentsAndWidth];

	[self willChangeValueForKey: @"contentsImage"];
	objc_setAssociatedObject(self, &kOPERATORDIRECTORY, [NSString stringWithCString: data->operatorDirectory encoding: NSUTF8StringEncoding], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, &kBLACKIMAGE, [NSString stringWithCString: data->serviceImages[0] encoding: NSUTF8StringEncoding], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, &kWHITEIMAGE, [NSString stringWithCString: data->serviceImages[1] encoding: NSUTF8StringEncoding], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey: @"contentsImage"];

	return %orig(arg1, arg2);
}

- (id)_serviceContentsImage {	
	NSString *operatorDirectory = objc_getAssociatedObject(self, &kOPERATORDIRECTORY);

	if (!self.isEnabled) {
		return %orig;
	}

	UIStatusBarForegroundStyleAttributes *attributes = [(UIStatusBarServiceItemView *)self valueForKey: @"foregroundStyle"];
	UIColor *tint = [attributes tintColor];

	NSString *blackImage = objc_getAssociatedObject(self, &kBLACKIMAGE);
	NSString *whiteImage = objc_getAssociatedObject(self, &kWHITEIMAGE);

	UIImage *image = nil;
	if (self.shouldTint) {
		NSString *cacheName = [operatorDirectory.lastPathComponent stringByAppendingPathComponent: blackImage];

		if (!(image = [self zp_imageNamed: cacheName])) {
			NSString *blackImage = objc_getAssociatedObject(self, &kBLACKIMAGE);
			image = [UIImage imageWithContentsOfFile: [operatorDirectory stringByAppendingPathComponent: blackImage]];
			[self zp_cacheImage: image named: cacheName];
		}

		image = [image imageTintedWithColor: tint];
	} else {
		CGFloat whiteComponent = 0.0;
		[tint getWhite:&whiteComponent alpha: NULL];

		NSString *cacheName = [operatorDirectory.lastPathComponent stringByAppendingPathComponent: whiteComponent < 0.5 ? blackImage : whiteImage];

		if (!(image = [self zp_imageNamed: cacheName])) {
			image = [UIImage imageWithContentsOfFile: [operatorDirectory stringByAppendingPathComponent: whiteComponent < 0.5 ? blackImage : whiteImage]];
			[self zp_cacheImage: image named: cacheName];
		}
	}

	return [_UILegibilityImageSet imageFromImage: image
								 withShadowImage: nil];
}

- (CGFloat)extraLeftPadding {
	if (self.shouldTint && self.isEnabled)
		return 3.0;
	return %orig;
}

- (CGFloat)extraRightPadding {
	if (self.shouldTint && self.isEnabled)
		return 3.0;
	return %orig;
}

- (CGFloat)standardPadding {
	if (self.shouldTint && self.isEnabled)
		return 0.0;
	return %orig;
}

%new
- (BOOL)shouldTint {
	NSString *whiteImage = objc_getAssociatedObject(self, &kWHITEIMAGE);
	return ([whiteImage isEqualToString: @"tint"]);
}

%new
- (BOOL)isEnabled {
	NSString *operatorDirectory = objc_getAssociatedObject(self, &kOPERATORDIRECTORY);
	return (operatorDirectory.length);
}

%new
- (UIImage *)zp_imageNamed:(NSString *)name {
	NSMutableDictionary *cache = objc_getAssociatedObject(self, &kIMAGECACHE);
	if (cache)
		return [cache objectForKey: name];
	return nil;
}

%new
- (void)zp_cacheImage:(UIImage *)image named:(NSString *)name {
	NSMutableDictionary *cache = objc_getAssociatedObject(self, &kIMAGECACHE);
	if (!cache) {
		cache = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &kIMAGECACHE, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	if (image)
		[cache setObject: image forKey: name];
}

%end