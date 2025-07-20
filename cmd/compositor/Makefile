$(SYSTEM_PATH)/cmd/compositor: $(wildcard $(CURDIR)/cmd/compositor/*.go) $(TOOLCHAIN_PATH)/bin/go $(SYSROOT_PATH)/lib/libwlroots-0.18.so
	CGO_ENABLED=1 GOOS=$(GOOS) GOARCH=$(GOARCH) $(TOOLCHAIN_PATH)/bin/go build -o $@ \
		rlxos.dev/cmd/compositor