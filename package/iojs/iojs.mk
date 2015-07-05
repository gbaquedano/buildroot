################################################################################
#
# iojs
#
################################################################################

IOJS_VERSION = $(call qstrip,$(BR2_PACKAGE_IOJS_VERSION_STRING))
IOJS_SOURCE = iojs-v$(IOJS_VERSION).tar.gz
IOJS_SITE = http://iojs.org/dist/v$(IOJS_VERSION)
IOJS_DEPENDENCIES = host-python host-iojs zlib \
	$(call qstrip,$(BR2_PACKAGE_IOJS_MODULES_ADDITIONAL_DEPS))
HOST_IOJS_DEPENDENCIES = host-python host-zlib
IOJS_LICENSE = MIT (core code); MIT, Apache and BSD family licenses (Bundled components)
IOJS_LICENSE_FILES = LICENSE

ifeq ($(BR2_PACKAGE_OPENSSL),y)
IOJS_DEPENDENCIES += openssl
endif

# IOjs build system is based on python, but only support python-2.6 or
# python-2.7. So, we have to enforce PYTHON interpreter to be python2.
define HOST_IOJS_CONFIGURE_CMDS
	# Build with the static, built-in OpenSSL which is supplied as part of
	# the iojs source distribution.  This is needed on the host because
	# NPM is non-functional without it, and host-openssl isn't part of
	# buildroot.
	(cd $(@D); \
		$(HOST_CONFIGURE_OPTS) \
		PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(HOST_DIR)/usr/bin/python2 ./configure \
		--prefix=$(HOST_DIR)/usr \
		--without-snapshot \
		--without-dtrace \
		--without-etw \
		--shared-zlib \
	)
endef

define HOST_IOJS_BUILD_CMDS
	$(HOST_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) \
		$(HOST_CONFIGURE_OPTS)
endef

define HOST_IOJS_INSTALL_CMDS
	$(HOST_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) install \
		$(HOST_CONFIGURE_OPTS)
endef

ifeq ($(BR2_i386),y)
IOJS_CPU = ia32
else ifeq ($(BR2_x86_64),y)
IOJS_CPU = x64
else ifeq ($(BR2_mipsel),y)
IOJS_CPU = mipsel
else ifeq ($(BR2_arm),y)
IOJS_CPU = arm
# V8 needs to know what floating point ABI the target is using.
IOJS_ARM_FP = $(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
endif

define IOJS_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)" \
		PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(HOST_DIR)/usr/bin/python2 ./configure \
		--prefix=/usr \
		--without-snapshot \
		--shared-zlib \
		$(if $(BR2_PACKAGE_OPENSSL),--shared-openssl,--without-ssl) \
		$(if $(BR2_PACKAGE_IOJS_NPM),,--without-npm) \
		--without-dtrace \
		--without-etw \
		--dest-cpu=$(IOJS_CPU) \
		$(if $(IOJS_ARM_FP),--with-arm-float-abi=$(IOJS_ARM_FP)) \
		--dest-os=linux \
	)
endef

define IOJS_BUILD_CMDS
	$(TARGET_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)"
endef

#
# Build the list of modules to install based on the booleans for
# popular modules, as well as the "additional modules" list.
#
IOJS_MODULES_LIST= $(call qstrip,\
	$(if $(BR2_PACKAGE_IOJS_MODULES_EXPRESS),express) \
	$(if $(BR2_PACKAGE_IOJS_MODULES_COFFEESCRIPT),coffee-script) \
	$(BR2_PACKAGE_IOJS_MODULES_ADDITIONAL))

# Define NPM for other packages to use
NPM = $(TARGET_CONFIGURE_OPTS) \
	LD="$(TARGET_CXX)" \
	npm_config_arch=$(IOJS_CPU) \
	npm_config_target_arch=$(IOJS_CPU) \
	npm_config_build_from_source=true \
	npm_config_iodir=$(BUILD_DIR)/iojs-$(IOJS_VERSION) \
	$(HOST_DIR)/usr/bin/npm

#
# We can only call NPM if there's something to install.
#
ifneq ($(IOJS_MODULES_LIST),)
define IOJS_INSTALL_MODULES
	# If you're having trouble with module installation, adding -d to the
	# npm install call below and setting npm_config_rollback=false can both
	# help in diagnosing the problem.
	(cd $(TARGET_DIR)/usr/lib && mkdir -p io_modules && \
		$(NPM) install $(IOJS_MODULES_LIST) \
	)

	# Symlink all executables in $(TARGET_DIR)/usr/lib/IO_modules/.bin to
	# $(TARGET_DIR)/usr/bin so they are accessible from the command line
	cd $(TARGET_DIR)/usr/bin; \
	for f in ../../usr/lib/io_modules/.bin/*; do \
		[ -f "$${f}" -a -x "$${f}" ] || continue; \
		ln -sf "$${f}" "$${f##*/}" || exit 1; \
	done
endef
endif

define IOJS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) install \
		DESTDIR=$(TARGET_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)"
	$(IOJS_INSTALL_MODULES)
endef

# IO.js configure is a Python script and does not use autotools
$(eval $(generic-package))
$(eval $(host-generic-package))
