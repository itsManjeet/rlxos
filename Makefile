ARCH			?= x86_64

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

MKBOOTIMG		?= $(shell pwd)/scripts/mkbootimg

export PATH := $(PATH):$(TOOLCHAIN_PATH)/bin

all: $(ISOFILE)

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
	rm -rf $(ISODIR)