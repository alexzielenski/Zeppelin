ARCHS := armv7 armv7s arm64
TARGET := iphone:7.0:7.0

include theos/makefiles/common.mk

TWEAK_NAME = zeppelin_uikit
zeppelin_uikit_FILES = UIImage+MGTint.m Tweak.xm
zeppelin_uikit_LIBRARIES = substrate
zeppelin_uikit_CFLAGS = -I../include -I../Categories
zeppelin_uikit_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk