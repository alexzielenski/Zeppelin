include theos/makefiles/common.mk

TWEAK_NAME = zeppelin_sb
zeppelin_sb_FILES  = ../Categories/NSString+ZPAdditions.m ZPImageServer.m Tweak.xm
zeppelin_sb_CFLAGS = -I../include -I../Categories
zeppelin_sb_LIBRARIES = substrate
zeppelin_sb_FRAMEWORKS = UIKit
zeppelin_sb_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk
