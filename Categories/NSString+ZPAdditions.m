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

- (NSString *)maximizeScaleInDirectory:(NSString *)dir {
	CGFloat scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
	NSString *tentativeName = SCALE(self, scale);
	while (![[NSFileManager defaultManager] fileExistsAtPath: [dir stringByAppendingPathComponent: tentativeName]]) {
		if (scale == 0) {
			tentativeName = nil;
			break;
		}
		scale -= 1;
		tentativeName = SCALE(self, scale);
	}
	return tentativeName;
}

@end