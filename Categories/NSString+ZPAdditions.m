#import "NSString+ZPAdditions.h"
#import "Defines.h"

@implementation NSString (Zeppelin)

+ (NSString *)zp_etchedName {
	return kEtchedImageName;
}

+ (NSString *)zp_blackName {
	return kBlackImageName;
}

+ (NSString *)zp_silverName {
	return kSilverImageName;
}

+ (NSString *)zp_logoName {
	return kLogoImageName;
}

+ (NSString *)zp_darkName {
	return kDarkImageName;
}

+ (NSString *)zp_lightName {
	return kLightImageName;
}

- (NSString *)zp_convertedCarrierImageName {
	NSString *file = nil;
	
	if ([self hasPrefix:@"ColorOnGrayShadow"])
		file = kSilverImageName;
	else if ([self hasPrefix:@"WhiteOnBlackEtch"])
		file = kEtchedImageName;
	else if ([self hasPrefix:@"WhiteOnBlackShadow"])
		file = kBlackImageName;
	else if ([self hasPrefix:@"Black"])
		file = kBlackImageName;
	else
		file = kSilverImageName;
		
	return file;
}

- (NSString *)scaleTo:(CGFloat)scale {
	if (scale == 0)
		return nil;
	return scale == 1.0 ? self : [self stringByAppendingFormat: @"@%.0fx", scale];
}

- (NSString *)maximizeScaleInDirectory:(NSString *)dir {
	CGFloat scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
	NSString *tentativeName = [self scaleTo: scale];
	while (![[NSFileManager defaultManager] fileExistsAtPath: [dir stringByAppendingPathComponent: [tentativeName stringByAppendingPathExtension: @"png"]]]) {		
		if (scale == 0) {
			return nil;
		}
		
		scale -= 1;
		tentativeName = [self scaleTo: scale];
	}
	return [tentativeName stringByAppendingPathExtension: @"png"];
}

@end