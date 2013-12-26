include theos/makefiles/common.mk

export SDKVERSION = 7.0
export TARGET = iphone:clang:7.0

TWEAK_NAME = zeppelin_uikit
zeppelin_uikit_ARCHS = armv7 arm64
zeppelin_uikit_FILES = Tweak.xm
zeppelin_uikit_CFLAGS = -I../include
zeppelin_uikit_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk