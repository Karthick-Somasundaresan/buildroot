################################################################################
#
# Amazon
#
################################################################################

AMAZON_VERSION = 5056183bc1c6d53ba122262a28e86d8ccf3057e4
AMAZON_SITE_METHOD = git
AMAZON_SITE = git@github.com:Metrological/amazon.git
AMAZON_INSTALL_STAGING = NO
AMAZON_INSTALL_TARGET = YES
AMAZON_DEPENDENCIES = host-cmake zlib jpeg libcurl libpng

define AMAZON_CONFIGURATION
    $(call GENERATE_LOCAL_CONFIG)
#   $(call AMAZON_MAKE, partner-device-code)
    $(call GENERATE_BOOST_CONFIG)
    $(call GENERATE_BUILD_CONFIG)
endef

define GENERATE_LOCAL_CONFIG
sed -e "s;%PLATFORM_FAMILY_NAME%;$(BR2_PACKAGE_AMAZON_PLATFORM_FAMILY_NAME);g" \
    -e "s;%PLATFORM_NAME%;$(BR2_PACKAGE_AMAZON_PLATFORM_NAME);g" \
    -e "s;%CC%;$(TARGET_CC);g" \
    -e "s;%CXX%;$(TARGET_CXX);g" \
    -e "s;%SDK_DIRECTORY%;$(STAGING_DIR);g" \
    -e "s;%AMAZON_TAG%;$(BR2_PACKAGE_AMAZON_TAG);g" \
    -e "s;%NUMBER_OF_CONCURRENT_JOBS%;$(BR2_PACKAGE_AMAZON_NUMBER_OF_CONCURRENT_JOBS);g" \
    $(@D)/templates/local.config.in  > $(@D)/tools/scripts/configuration/local.config
endef

define GENERATE_BUILD_CONFIG
sed -e "s;%IG_INSTALL_PATH%;$(BR2_PACKAGE_AMAZON_IG_INSTALL_PATH);g" \
    -e "s;%IG_READ_WRITE_PATH%;$(BR2_PACKAGE_AMAZON_IG_READ_WRITE_PATH);g" \
    -e "s;%IG_TEST_INSTALL_PATH%;$(BR2_PACKAGE_AMAZON_IG_TEST_INSTALL_PATH);g" \
    -e "s;%DTID%;$(BR2_PACKAGE_AMAZON_DTID);g" \
    -e "s;%CPU_BIT_WIDTH_AND_ENDIANNESS%;$(BR2_PACKAGE_AMAZON_CPU_BIT_WIDTH_AND_ENDIANNESS);g" \
    $(@D)/templates/avpk-build.config.in  > $(@D)/$(BR2_PACKAGE_AMAZON_PLATFORM_FAMILY_NAME)/common/configuration/avpk-build-$(BR2_PACKAGE_AMAZON_PLATFORM_FAMILY_NAME)-${BR2_PACKAGE_AMAZON_PLATFORM_NAME}.config
endef

define GENERATE_BOOST_CONFIG
 sed -e "s;%TARGET_CROSS%;$(notdir $(TARGET_CROSS));g" \
    $(@D)/templates/user-config.jam.in  > $(@D)/$(BR2_PACKAGE_AMAZON_PLATFORM_FAMILY_NAME)/platform/ignition/com.amazon.ignition.framework.core/internal/platform/$(BR2_PACKAGE_AMAZON_PLATFORM_FAMILY_NAME)/boost/user-config.jam
endef

ifeq ($(BR2_PACKAGE_AMAZON),y)
ifeq ($(BR2_PACKAGE_AMAZON_BACKEND_DRM),y)
 AMAZON_DEPENDENCIES += libgles libegl playready
 AMAZON_BACKEND = mpb-drm
else ifeq  ($(BR2_PACKAGE_AMAZON_BACKEND_NO_DRM),y)
 AMAZON_DEPENDENCIES += libgles libegl
 AMAZON_BACKEND = mpb-no-drm
else ifeq  ($(BR2_PACKAGE_AMAZON_BACKEND_FAKE),y)
 AMAZON_BACKEND = fake-mpb
else
 $(error No backend specified)
endif

ifeq ($(BR2_PACKAGE_AMAZON_BUILD_TYPE_RELEASE),y)
 AMAZON_BUILD_TYPE = release
else ifeq  ($(BR2_PACKAGE_AMAZON_BUILD_TYPE_RELEASE_DEBUG),y)
 AMAZON_BUILD_TYPE = relwithdebinfo
else ifeq  ($(BR2_PACKAGE_AMAZON_BUILD_TYPE_DEBUG),y)
 AMAZON_BUILD_TYPE = debug
else
 $(error No build type specified)
endif
endif

#define AMAZON_APPLY_CUSTOM_PATCHES
# $(call AMAZON_MAKE, ignition-repo-code)
# $(call AMAZON_MAKE, ruby-repo-code)
# $(APPLY_PATCHES) $(@D) $(@D)/patches \*.patch
#endef

define AMAZON_MAKE
$(MAKE) -C $(@D)/tools/ $1 $2
endef

define AMAZON_BUILD_CMDS
 export PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR)
 $(call AMAZON_MAKE, dpc, BUILD_TYPE=$(AMAZON_BUILD_TYPE))
 $(call AMAZON_MAKE, dpp, BUILD_TYPE=$(AMAZON_BUILD_TYPE))
 $(call AMAZON_MAKE, ignition, BUILD_TYPE=$(AMAZON_BUILD_TYPE))
 $(call AMAZON_MAKE, ignition-device, BUILD_TYPE=$(AMAZON_BUILD_TYPE))
 $(call AMAZON_MAKE, ruby, BACKEND=$(AMAZON_BACKEND) BUILD_TYPE=$(AMAZON_BUILD_TYPE))
endef

define AMAZON_INSTALL_TARGET_CMDS
 $(INSTALL) -d -m 0755 $(TARGET_DIR)/$(BR2_PACKAGE_AMAZON_IG_INSTALL_PATH)
 cp -a $(@D)/install/$(BR2_PACKAGE_AMAZON_PLATFORM_NAME)/* $(TARGET_DIR)/$(BR2_PACKAGE_AMAZON_IG_INSTALL_PATH)
 
 if [ ! -h "$(TARGET_DIR)/usr/bin/ignition" ]; then \
    rm $(TARGET_DIR)/usr/bin/ignition ;\
    ln -s $(BR2_PACKAGE_AMAZON_IG_INSTALL_PATH)/bin/ignition $(TARGET_DIR)/usr/bin/ignition ;\
 fi
 
endef

define AMAZON_INSTALL_STAGING_CMDS
endef

AMAZON_POST_EXTRACT_HOOKS += AMAZON_CONFIGURATION
# AMAZON_POST_PATCH_HOOKS += AMAZON_APPLY_CUSTOM_PATCHES

$(eval $(generic-package))
