include theos/makefiles/common.mk

BUNDLE_NAME = ZeppelinSettings
ZeppelinSettings_FILES = ZeppelinSettings.m ZPAlignedTableViewCell.m ZPThemesController.m ZPTheme.m
ZeppelinSettings_INSTALL_PATH = /Library/PreferenceBundles
ZeppelinSettings_FRAMEWORKS = UIKit
ZeppelinSettings_PRIVATE_FRAMEWORKS = Preferences
ZeppelinSettings_CFLAGS = -I../include

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ZeppelinSettings.plist$(ECHO_END)

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.png' -exec pincrush -i {} \;$(ECHO_END)
