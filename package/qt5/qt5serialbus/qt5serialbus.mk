################################################################################
#
# qt5serialbus
#
################################################################################

QT5SERIALBUS_VERSION = $(QT5_VERSION)
QT5SERIALBUS_SITE = $(QT5_SITE)
QT5SERIALBUS_SOURCE = qtserialbus-opensource-src-$(QT5SERIALBUS_VERSION).tar.xz
QT5SERIALBUS_DEPENDENCIES = qt5base qt5serialport
QT5SERIALBUS_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_QT5BASE_LICENSE_APPROVED),y)
QT5SERIALBUS_LICENSE = LGPLv2.1 with exception or LGPLv3 or GPLv2
QT5SERIALBUS_LICENSE_FILES = LICENSE.LGPLv21 LGPL_EXCEPTION.txt LICENSE.LGPLv3 LICENSE.GPLv2
else
QT5SERIALBUS_LICENSE = Commercial license
QT5SERIALBUS_REDISTRIBUTE = NO
endif

define QT5SERIALBUS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/qmake)
endef

define QT5SERIALBUS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QT5SERIALBUS_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install
	$(QT5_LA_PRL_FILES_FIXUP)
endef

ifeq ($(BR2_STATIC_LIBS),)
define QT5SERIALBUS_INSTALL_TARGET_CMDS
	cp -dpf $(STAGING_DIR)/usr/lib/libQt5SerialBus.so.* $(TARGET_DIR)/usr/lib
endef
endif

$(eval $(generic-package))
