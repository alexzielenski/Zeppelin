export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=2222

# export SDKVERSION=4.2
# export ARCHS=armv6 armv7 armv7s
# export TARGET=iphone::4.2
# export TARGET_armv7s=iphone::6.0
# export TARGET_arm64=iphone::7.0

include theos/makefiles/common.mk

THEOS_BUILD_DIR = build

SUBPROJECTS = settings
SUBPROJECTS += zeppelin_sb
SUBPROJECTS += zeppelin_uikit
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.png' -exec pincrush -i {} \;$(ECHO_END)
	$(ECHO_NOTHING)find _ -name '*.DS_Store' -type f -exec rm {} \;$(ECHO_END)
after-install::
	@install.exec "killall -9 SpringBoard"