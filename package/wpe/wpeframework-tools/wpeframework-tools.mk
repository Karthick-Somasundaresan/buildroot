################################################################################
#
# wpeframework-tools
#
################################################################################

WPEFRAMEWORK_TOOLS_VERSION = 2b687ad87d4c1036a26ad1ecfae95c5c4b230128

HOST_WPEFRAMEWORK_TOOLS_SITE = $(call github,WebPlatformForEmbedded,WPEFramework,$(WPEFRAMEWORK_TOOLS_VERSION))
HOST_WPEFRAMEWORK_TOOLS_INSTALL_STAGING = YES
HOST_WPEFRAMEWORK_TOOLS_INSTALL_TARGET = NO

HOST_WPEFRAMEWORK_TOOLS_DEPENDENCIES = host-cmake host-python-jsonref

HOST_WPEFRAMEWORK_TOOLS_SUBDIR = Tools

$(eval $(host-cmake-package))
