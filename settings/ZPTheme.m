#import "ZPTheme.h"
#import "Defines.h"

@implementation ZPTheme
@synthesize name, image, whiteImage, pack, hidden;

+ (ZPTheme*)themeWithPath:(NSString*)path {
	return [[[ZPTheme alloc] initWithPath:path] autorelease];
}

- (id)initWithPath:(NSString*)path {
	// make sure it is a dir
	BOOL isDir = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	
	if (!exists || !isDir) {
		[self release];
		return nil;
	}
	
	if ((self = [super init])) {
		self.name = [[path lastPathComponent] stringByDeletingPathExtension];
		// Find out which image to use
		BOOL retina = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2);
		NSString *silverName = nil;
		if (!retina)
			silverName = kSilverImageName;
		if (retina)
			silverName = [kSilverImageName stringByAppendingString:@"@2x"];
			
		silverName = [silverName stringByAppendingString:@".png"];
		self.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];
		
		NSString *blackName = nil;
		if (!retina)
			blackName = kBlackImageName;
		if (retina)
			blackName = [kBlackImageName stringByAppendingString:@"@2x"];

		blackName = [blackName stringByAppendingString:@".png"];
		self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];
		
		if (!whiteImage) {
			if (!retina)
				blackName = kEtchedImageName;
			if (retina)
				blackName = [kEtchedImageName stringByAppendingString:@"@2x"];
			blackName = [blackName stringByAppendingString:@".png"];
			self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];
		}
				
		// no images? kill myself
		if (!self.whiteImage || !self.image) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.image = nil;
	self.whiteImage = nil;
	[super dealloc];
}

@end