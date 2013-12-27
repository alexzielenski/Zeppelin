#import "NSString+ZPAdditions.h"
#import "Defines.h"

@implementation NSString (Zeppelin)

+ (NSString *)zp_etchedName {
	NSString *name = kEtchedImageName;
	if (IS_RETINA())
		name = [name stringByAppendingString:@"@2x"];
	return [name stringByAppendingPathExtension:@"png"];
}

+ (NSString *)zp_blackName {
	NSString *name = kBlackImageName;
	if (IS_RETINA())
		name = [name stringByAppendingString:@"@2x"];
	return [name stringByAppendingPathExtension:@"png"];
}

+ (NSString *)zp_silverName {
	NSString *name = kSilverImageName;
	if (IS_RETINA())
		name = [name stringByAppendingString:@"@2x"];
	return [name stringByAppendingPathExtension:@"png"];
}

+ (NSString *)zp_logoName {
	NSString *name = kLogoImageName;
	if (IS_RETINA())
		name = [name stringByAppendingString: @"@2x"];
	return [name stringByAppendingPathExtension: @"png"];
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
@end