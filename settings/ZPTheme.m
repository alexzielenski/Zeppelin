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
		NSString *silverName;
		if (IS_IOS_70_OR_LATER()) {
			silverName = RETINIZE(kLogoImageName);
			self.image = self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];
		}

		if (!self.image) {
			silverName = RETINIZE(kSilverImageName);
			self.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:silverName]];
		}

		NSString *blackName;
		if (!self.whiteImage) {
			blackName = RETINIZE(kBlackImageName);
			self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];

			if (!self.whiteImage) {
				blackName = RETINIZE(kEtchedImageName);
				self.whiteImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:blackName]];
			}
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