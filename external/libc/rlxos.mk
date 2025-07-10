$(SYSTEM_PATH)/lib/libc.so: $(SYSROOT_PATH)/lib/libc.so
	mkdir -p $(shell dirname $@)
	cp -rap $< $@

$(SYSTEM_PATH)/lib/ld-linux-%.so.1: $(SYSROOT_PATH)/lib/libc.so
	ln -sfv libc.so $@