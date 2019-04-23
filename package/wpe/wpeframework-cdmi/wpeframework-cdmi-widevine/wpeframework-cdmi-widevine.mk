################################################################################
#
# wpeframework-cdmi-widevine
#
################################################################################

WPEFRAMEWORK_CDMI_WIDEVINE_VERSION = eab63197d0c77a9d14fbfd4ef0ba0f6f156b4a7d
WPEFRAMEWORK_CDMI_WIDEVINE_SITE_METHOD = git
WPEFRAMEWORK_CDMI_WIDEVINE_SITE = git@github.com:WebPlatformForEmbedded/OCDM-Widevine.git
WPEFRAMEWORK_CDMI_WIDEVINE_INSTALL_STAGING = NO
WPEFRAMEWORK_CDMI_WIDEVINE_DEPENDENCIES = wpeframework widevine

define WPEFRAMEWORK_CDMI_WIDEVINE_POST_INSTALLATION
	$(INSTALL) -m 755 -d $(TARGET_DIR)/etc/WideVine
	$(INSTALL) -D -m 755 $(@D)/tools/keybox/testkeybox.bin $(TARGET_DIR)/etc/WideVine/keybox.bin
endef

WPEFRAMEWORK_CDMI_WIDEVINE_POST_INSTALL_TARGET_HOOKS += WPEFRAMEWORK_CDMI_WIDEVINE_POST_INSTALLATION

$(eval $(cmake-package))
