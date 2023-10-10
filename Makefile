ARCH			?= x86_64

VERSION			?= 0.9.0
CODENAME		?= experimental
CHANGELOG		?= "NO CHANGELOG"
SERVER			?= "http://storage.rlxos.dev"

GOLANG			?= go

TARGET_TRIPLE	:= $(ARCH)-elf

BUILDDIR		?= $(shell pwd)/build

CACHE_PATH		?= $(BUILDDIR)/cache

BUILDER			?= $(BUILDDIR)/builder
RELEASE_PATH	?= $(BUILDDIR)/release

CURCOMMIT		:= $(shell git rev-parse HEAD)

BOARD			?= $(ARCH)
CONTAIN_CHANGES := $(shell git diff-index --quiet HEAD --; echo $$?)

ALL_ELEMENTS	:= $(wildcard elements/components/*.yml)
ALL_ELEMENTS	:= $(ALL_ELEMENTS:elements/%=%)

export PATH := $(PATH):$(TOOLCHAIN_PATH)/bin

all: $(BUILDER)

clean:
	rm -f $(KERNEL_IMAGE) $(KERNEL_IMAGE).txt $(ISOFILE)
	rm -rf $(ISODIR) vendor
	rm -f $(BUILDER)

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

$(BUILDER): update-vendor version.yml server.yml
	$(GOLANG) build -o $@ rlxos/cmd/builder

report: $(BUILDER)
	$(BUILDER) report -cache-path $(CACHE_PATH)

clean-garbage: $(BUILDER)
	$(BUILDER) report -cache-path $(CACHE_PATH) -clean-garbage

list-files: $(BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(BUILDER) list-files -cache-path $(CACHE_PATH) $(ELEMENT)

check: $(BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	echo "CACHE PATH: $(CACHE_PATH)"
	$(BUILDER) status -cache-path $(CACHE_PATH) $(ELEMENT)

test:
	@if [ -z $(IMAGE) ] ;then echo "ERROR: no image specified"; exit 1; fi
	@if [ ! -f $(IMAGE) ] ; then echo "ERROR: no image exists $(IMAGE)"; exit 1; fi
	qemu-system-$(ARCH) -cdrom $(IMAGE) \
		-m 2G -smp 2 \
		-nographic

cache: $(BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(BUILDER) build -cache-path $(CACHE_PATH) $(ELEMENT)

checkout: $(BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(BUILDER) checkout -cache-path $(CACHE_PATH) $(ELEMENT) $(RELEASE_PATH)

filepath: $(BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(BUILDER) file -cache-path $(CACHE_PATH) $(ELEMENT)

metadata: $(BUILDER)
	$(BUILDER) dump-metadata -cache-path $(CACHE_PATH) $(RELEASE_PATH)

TODO:
	@grep -R "# TODO:" elements/ | sed 's/# TODO://g' > $@
	@cat $@

create-patch: $(BUILDER) $(CREATE_PATCH)
	@if [ -z $(SOURCE) ] ; then echo "ERROR: SOURCE commit not specified"; exit 1; fi
	@if [ -z $(TARGET) ] ; then echo "ERROR: TARGET commit not specified"; exit 1; fi
	
	@if [ $(CONTAIN_CHANGES) ] ; then git stash; fi
	
	@git checkout $(SOURCE)
	$(eval SOURCE_IMAGE_PATH := $(shell $(BUILDER) file -cache-path $(CACHE_PATH) boards/$(ARCH)/image.yml | tail -n1))

	@git checkout $(TARGET)
	$(eval TARGET_IMAGE_PATH := $(shell $(BUILDER) file -cache-path $(CACHE_PATH) boards/$(ARCH)/image.yml | tail -n1))

	@git checkout $(CURCOMMIT)
	@if [ $(CONTAIN_CHANGES) ] ; then git stash pop; fi

	rm -rf $(BUILDDIR)/_work
	
	umount $(BUILDDIR)/source $(BUILDDIR)/target || true

	mkdir -p $(BUILDDIR)/source $(BUILDDIR)/target
	mkdir -p $(BUILDDIR)/_work/source
	mkdir -p $(BUILDDIR)/_work/target

	@echo "SOURCE IMAGE PATH: $(SOURCE_IMAGE_PATH)"
	@echo "TARGET IMAGE PATH: $(TARGET_IMAGE_PATH)"

	tar --wildcards -xaf $(SOURCE_IMAGE_PATH) -C $(BUILDDIR)/_work/source "*usr*.squashfs"
	tar --wildcards -xaf $(TARGET_IMAGE_PATH) -C $(BUILDDIR)/_work/target "*usr*.squashfs"

	$(eval SOURCE_IMAGE_SQUASH_PATH := $(shell readlink $(BUILDDIR)/_work/source/usr.squashfs))
	$(eval TARGET_IMAGE_SQUASH_PATH := $(shell readlink $(BUILDDIR)/_work/target/usr.squashfs))

	squashfuse $(BUILDDIR)/_work/source/$(SOURCE_IMAGE_SQUASH_PATH) $(BUILDDIR)/source
	squashfuse $(BUILDDIR)/_work/source/$(TARGET_IMAGE_SQUASH_PATH) $(BUILDDIR)/target

	$(BUILDER) create-patch $(BUILDDIR)/source $(BUILDDIR)/target

	rm -rf $(BUILDDIR)/_work
	umount $(BUILDDIR)/source $(BUILDDIR)/target || true

define BUILD_ELEMENT

endef

world: $(BUILDER)
	for element in $(ALL_ELEMENTS) ; do 										\
		echo "BUILDING $$element";												\
		if $(BUILDER) build -cache-path $(CACHE_PATH) $$element ; then 	\
			echo "PASSED $$element" >> passed;									\
		else																	\
			echo "FAILED $$element" >> failed;									\
		fi; 																	\
	done

	@echo -e "\n\n\n\n\n== FAILED ======================="
	@cat failed

	@echo -e "\n\n\n\n\n== PASSED ======================="
	@cat passed

	@echo "TOTAL FAILED $(shell wc -l failed)"
	@echo "TOTAL PASSED $(shell wc -l passed)"

check-updates: $(BUILDER)
	$(BUILDER) check-updates

$(RELEASE_PATH)/rlxos-$(VERSION)-amd64-desktop-installer.iso: $(BUILDER)
	make checkout ELEMENT=boards/amd64-desktop/installer.yml

board: $(BUILDER)
	@if [ -z $(BOARD) ] ;then echo "ERROR: no board specified"; exit 1; fi
	@if [ ! -f elements/boards/$(BOARD)/image.yml 		] ; then echo "ERROR: no board image exists elements/boards/$(BOARD)/image.yml"; exit 1; fi
	@if [ ! -f elements/boards/$(BOARD)/installer.yml 	] ; then echo "ERROR: no board installer exists elements/boards/$(BOARD)/installer.yml"; exit 1; fi

	$(BUILDER) build -cache-path $(CACHE_PATH) boards/$(BOARD)/image.yml
	$(BUILDER) build -cache-path $(CACHE_PATH) boards/$(BOARD)/installer.yml

run-vnc: $(BUILDER)
	@if [ -z $(BOARD) ] ;then echo "ERROR: no board specified"; exit 1; fi
	@if [ ! -f elements/boards/$(BOARD)/image.yml 		] ; then echo "ERROR: no board image exists elements/boards/$(BOARD)/image.yml"; exit 1; fi
	@if [ ! -f elements/boards/$(BOARD)/installer.yml 	] ; then echo "ERROR: no board installer exists elements/boards/$(BOARD)/installer.yml"; exit 1; fi

	$(BUILDER) checkout -cache-path $(CACHE_PATH) boards/$(BOARD)/installer.yml $(RELEASE_PATH)
	qemu-system-x86_64 -smp 2 -m 4G -vnc :0 -monitor stdio -cdrom $(RELEASE_PATH)/rlxos-$(VERSION)-$(BOARD)-installer.iso

.PHONY: all clean update-vendor component TODO