include theos/makefiles/common.mk

TWEAK_NAME = zeppelin_uikit
zeppelin_uikit_FILES = UIImage+MGTint.m Tweak.xm
zeppelin_uikit_LIBRARIES = substrate
zeppelin_uikit_CFLAGS = -I../include -I../Categories
zeppelin_uikit_FRAMEWORKS = UIKit CoreGraphics
zeppelin_uikit_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk