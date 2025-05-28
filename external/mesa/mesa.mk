$(SYSROOT_PATH)/lib/libGL.so: $(CURDIR)/external/mesa/mesa.json
	DESTDIR=$(SYSROOT_PATH) $(GO) run rlxos.dev/tools/builder \
		-cache-path $(DEVICE_CACHE_PATH) \
		-sysroot $(SYSROOT_PATH) \
		-target $(TOOLCHAIN_TARGET_TRIPLE) \
		$<

$(SYSTEM_PATH)/lib/libGL.so: $(SYSTEM_PATH)/lib/libdrm.so $(SYSROOT_PATH)/lib/libGL.so
	cp -av $< $@
