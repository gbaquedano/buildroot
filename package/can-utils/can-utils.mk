################################################################################
#
# can-utils
#
################################################################################

CAN_UTILS_VERSION = cda61171f1f559dbb3b25c9fede2cc2a85c7cd0d
CAN_UTILS_SITE = $(call github,linux-can,can-utils,$(CAN_UTILS_VERSION))
CAN_UTILS_AUTORECONF = YES

$(eval $(autotools-package))
