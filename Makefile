export THEOS_DEVICE_IP=192.168.3.97
export ARCHS=armv7
# export GO_EASY_ON_ME=1

include theos/makefiles/common.mk

THEOS_BUILD_DIR = build

TWEAK_NAME = Zeppelin
Zeppelin_FILES  = src/Tweak.xm src/ZPImageServer.m src/Categories/NSString+ZPAdditions.m
Zeppelin_CFLAGS = -I./src

Zeppelin_FRAMEWORKS = UIKit
#Zeppelin_PRIVATE_FRAMEWORKS = AppSupport

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.2

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS = settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.png' -exec pincrush -i {} \;$(ECHO_END)
	$(ECHO_NOTHING)find _ -name '*.DS_Store' -type f -exec rm {} \;$(ECHO_END)
