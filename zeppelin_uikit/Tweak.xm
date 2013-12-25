#import <UIKit/UIKit.h>
#import "Defines.h"
#import <UIKit70/UIStatusBarServiceItemView.h>
#import <UIKit70/UIStatusBarComposedData.h>
#import <UIKit70/_UILegibilityImageSet.h>
#import <UIKit70/UIImage-_UILegibility.h>
#import <UIKit70/_UILegibilitySettings.h>
#import <UIKit70/UIStatusBarForegroundStyleAttributes.h>

%hook UIStatusBarServiceItemView
static char kBLACKIMAGE;
static char kWHITEIMAGE;
static char kOPERATORDIRECTORY;

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

	if (!operatorDirectory.length) {
		return %orig;
	}

	UIColor *tint = [(UIStatusBarForegroundStyleAttributes *)[(UIStatusBarServiceItemView *)self valueForKey: @"foregroundStyle"] tintColor];
	CGFloat white;

	[tint getWhite: &white alpha: NULL];

	NSString *blackImage = objc_getAssociatedObject(self, &kBLACKIMAGE);
	NSString *whiteImage = objc_getAssociatedObject(self, &kWHITEIMAGE);
	UIImage *image = [UIImage imageWithContentsOfFile: [operatorDirectory stringByAppendingPathComponent: white ? whiteImage : blackImage]];

	return [_UILegibilityImageSet imageFromImage: [image _imageWithBrightnessModifiedForLegibilityStyle: [self legibilityStyle]]
								 withShadowImage: [image _imageForLegibilitySettings: [_UILegibilitySettings sharedInstanceForStyle: [self legibilityStyle]] strength: [self legibilityStrength]]];
}

%end