RLXOS_VERSION     			= 2.0
RLXOS_LICENSE				= GPL-3.0+
RLXOS_LICENSE_FILES 		= LICENSE
RLXOS_DEPENDENCIES			= host-go host-pkgconf

PACKAGES_ALL += rlxos
PACKAGES += rlxos

RLXOS_BUILD_TARGETS = \
	system/core/init \
	system/core/service

rlxos: $(RLXOS_DEPENDENCIES)
	$(foreach d,$(RLXOS_BUILD_TARGETS),\
		cd $(BR2_EXTERNAL_RLXOS_PATH); \
		if [ -d $(d)/cmd ] ; then \
			$(HOST_GO_TARGET_ENV) \
			$(RLXOS_GO_ENV) \
				$(GO_BIN) build -v $(RLXOS_BUILD_OPTS) \
					-mod=vendor -o $(TARGET_DIR)/$(shell dirname $(d))/cmd/$(shell basename $(d)) \
					rlxos/$(d)/cmd || exit 1; \
		fi; \
		if [ -d $(d)/*.service ] ; then \
			install -vDm 0644 $(d)/*.service $(TARGET_DIR)/$(shell dirname $(d)/services/) \
		fi;)