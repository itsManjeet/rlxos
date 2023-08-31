ARCH			?= x86_64

VERSION			?= 999
CODENAME		?= rolling
CHANGELOG		?= "NO CHANGELOG"
SERVER			?= "http://storage.rlxos.dev"

GOLANG			?= go

GOENV			?= GOARCH=amd64 GOAMD64=v1

GOFLAGS			?=
LDFLAGS			?=


TARGET_TRIPLE	:= $(ARCH)-elf
LDFLAGS 		:= $(LDFLAGS) -nostdlib -n -v -static -m elf_$(ARCH) -T kernel/link.ld
GOFLAGS 		:= $(GOFLAGS) -trimpath -gcflags=rlxos/kernel=-std -ldflags="-linkmode external -extld $(TARGET_TRIPLE)-ld -extldflags '$(LDFLAGS)'"
STRIPFLAGS 		:= -s -K mmio -K fb -K bootboot -K environment -K initstack

TOOLCHAIN_PATH	?= $(HOME)/toolchain/$(TARGET_TRIPLE)
BUILDDIR		?= $(shell pwd)/build
KERNEL_IMAGE	?= $(BUILDDIR)/kernel.$(TARGET_TRIPLE)
ISODIR			?= $(BUILDDIR)/ISO
ISOFILE			?= $(BUILDDIR)/rlxos-$(ARCH).iso

CACHE_PATH		?= $(BUILDDIR)/cache

MKBOOTIMG		?= $(shell pwd)/scripts/mkbootimg

REPO_BUILDER	?= $(BUILDDIR)/builder
RELEASE_PATH	?= $(BUILDDIR)/release

BOARD			?= $(ARCH)

export PATH := $(PATH):$(TOOLCHAIN_PATH)/bin

all: $(REPO_BUILDER)

$(KERNEL_IMAGE):
	CGO_ENABLED=0 GOOS=linux $(GOENV) go build $(GOFLAGS) -o $@ rlxos/kernel
	x86_64-elf-strip $(STRIPFLAGS) $@
	x86_64-elf-readelf -hls $@ > $@.txt
	$(MKBOOTIMG) check $@

$(ISODIR)/boot/sys/config: kernel/bootboot/bootboot.cfg 
	install -vDm0644 $< $@

$(ISODIR)/bootboot.json: kernel/bootboot/bootboot.json
	install -vDm0644 $< $@

$(ISODIR)/boot/sys/core: $(KERNEL_IMAGE)
	install -vDm0755 $< $@

$(ISOFILE): $(ISODIR)/boot/sys/core $(ISODIR)/bootboot.json $(ISODIR)/boot/sys/config
	cd $(ISODIR) && $(MKBOOTIMG) bootboot.json $@

clean:
	rm -f $(KERNEL_IMAGE) $(KERNEL_IMAGE).txt $(ISOFILE)
	rm -rf $(ISODIR) vendor $(BUILDDIR)
	rm -f version.yml server.yml $(REPO_BUILDER)

# TODO: remove only rlxos running containers
	docker rm -f $(shell docker ps -aq) 2>/dev/null || true

version.yml:
	@echo "version: $(VERSION)" > $@
	@echo "variables:" >> $@
	@echo "  codename: $(CODENAME)" >> $@

server.yml:
	@echo "variables:" > $@
	@echo "  server: $(SERVER)" >> $@
	@echo "  channel: $(CODENAME)" >> $@

update-vendor:
	$(GOLANG) mod tidy && $(GOLANG) mod vendor

$(REPO_BUILDER): update-vendor version.yml server.yml
	$(GOLANG) build -o $@ rlxos/cmd/builder

report: $(REPO_BUILDER) 
	$(REPO_BUILDER) report -cache-path $(CACHE_PATH)

list-files: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) list-files -cache-path $(CACHE_PATH) $(ELEMENT)

check: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) status -cache-path $(CACHE_PATH) $(ELEMENT)

component: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) build -cache-path $(CACHE_PATH) $(ELEMENT)

checkout: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) checkout -cache-path $(CACHE_PATH) $(ELEMENT) $(RELEASE_PATH)


.PHONY: all clean update-vendor component