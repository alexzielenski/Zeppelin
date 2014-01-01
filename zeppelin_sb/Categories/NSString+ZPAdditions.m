#import "NSString+ZPAdditions.h"
#import "Defines.h"

@implementation NSString (Zeppelin)

+ (NSString *)zp_etchedName {
	return RETINIZE(kEtchedImageName);
}

+ (NSString *)zp_blackName {
	return RETINIZE(kBlackImageName);
}

+ (NSString *)zp_silverName {
	return RETINIZE(kSilverImageName);
}

+ (NSString *)zp_logoName {
	return RETINIZE(kLogoImageName);
}

+ (NSString *)zp_darkName {
	return RETINIZE(kDarkImageName);
}

+ (NSString *)zp_lightName {
	return RETINIZE(kLightImageName);
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
		
	return RETINIZE(file);
}
@end