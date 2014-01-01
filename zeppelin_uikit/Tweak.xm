#import <UIKit/UIKit.h>
#import "Defines.h"
#import "UIImage+MGTint.h"

#import <UIKit70/UIStatusBarServiceItemView.h>
#import <UIKit70/UIStatusBarComposedData.h>
#import <UIKit70/_UILegibilityImageSet.h>
#import <UIKit70/UIImage-_UILegibility.h>
#import <UIKit70/_UILegibilitySettings.h>
#import <UIKit70/UIStatusBarForegroundStyleAttributes.h>

@interface UIStatusBarServiceItemView ()
- (UIImage *)zp_imageNamed:(NSString *)name;
- (void)zp_cacheImage:(UIImage *)image named:(NSString *)name;
- (BOOL)zp_shouldTint;
- (BOOL)zp_isEnabled;
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

	if (!self.zp_isEnabled) {
		return %orig;
	}

	UIStatusBarForegroundStyleAttributes *attributes = [(UIStatusBarServiceItemView *)self valueForKey: @"foregroundStyle"];
	UIColor *tint = [attributes tintColor];

	NSString *blackImage = objc_getAssociatedObject(self, &kBLACKIMAGE);
	NSString *whiteImage = objc_getAssociatedObject(self, &kWHITEIMAGE);
	NSString *operatorDirectory = objc_getAssociatedObject(self, &kOPERATORDIRECTORY);

	UIImage *image = nil;
	if (self.zp_shouldTint) {
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
								 withShadowImage: [[[UIImage alloc] init] autorelease]];
}

- (CGFloat)extraLeftPadding {
	if (self.zp_shouldTint && self.zp_isEnabled)
		return 2.0;
	return %orig;
}

- (CGFloat)extraRightPadding {
	if (self.zp_shouldTint && self.zp_isEnabled)
		return 4.0;
	return %orig;
}

- (CGFloat)standardPadding {
	if (self.zp_shouldTint && self.zp_isEnabled)
		return 0.0;
	return %orig;
}

%new
- (BOOL)zp_shouldTint {
	NSString *whiteImage = objc_getAssociatedObject(self, &kWHITEIMAGE);
	return ([whiteImage isEqualToString: @"tint"]);
}

%new
- (BOOL)zp_isEnabled {
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