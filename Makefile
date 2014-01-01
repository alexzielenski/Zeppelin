export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=2222

TARGET = iphone:clang
export SDKVERSION = 7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.2
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0
export ARCHS = armv6 armv7 armv7s arm64

include theos/makefiles/common.mk

THEOS_BUILD_DIR = build

SUBPROJECTS = settings
SUBPROJECTS += zeppelin_sb
SUBPROJECTS += zeppelin_uikit
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.png' -exec pincrush -i {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name '*.DS_Store' -type f -exec rm {} \;$(ECHO_END)
	$(ECHO_NOTHING)markdown-html -s $(THEOS_PROJECT_DIR)/GitHub2.css $(THEOS_STAGING_DIR)/Library/Zeppelin/README.md > $(THEOS_STAGING_DIR)/Library/Zeppelin/README.html \;$(ECHO_END)
	$(ECHO_NOTHING)rm $(THEOS_STAGING_DIR)/Library/Zeppelin/README.md$(ECHO_END)
after-install::
	@install.exec "killall -9 SpringBoard"