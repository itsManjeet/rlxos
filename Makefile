ARCH			?= x86_64

VERSION			?= 999
CODENAME		?= rolling
CHANGELOG		?= "NO CHANGELOG"
SERVER			?= "http://storage.rlxos.dev"

GOLANG			?= go

TARGET_TRIPLE	:= $(ARCH)-elf

BUILDDIR		?= $(shell pwd)/build

CACHE_PATH		?= $(BUILDDIR)/cache

SWUPD			?= $(BUILDDIR)/swupd
RELEASE_PATH	?= $(BUILDDIR)/release

CURCOMMIT		:= $(shell git rev-parse HEAD)

BOARD			?= $(ARCH)
CONTAIN_CHANGES := $(shell git diff-index --quiet HEAD --; echo $$?)

ALL_ELEMENTS	:= $(wildcard elements/components/*.yml)
ALL_ELEMENTS	:= $(ALL_ELEMENTS:elements/%=%)

export PATH := $(PATH):$(TOOLCHAIN_PATH)/bin

all: $(SWUPD)

clean:
	rm -f $(KERNEL_IMAGE) $(KERNEL_IMAGE).txt $(ISOFILE)
	rm -rf $(ISODIR) vendor
	rm -f $(SWUPD)

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

$(SWUPD): update-vendor version.yml server.yml
	$(GOLANG) build -o $@ rlxos/cmd/swupd

report: $(SWUPD)
	$(SWUPD) buildroot report -cache-path $(CACHE_PATH)

clean-garbage: $(SWUPD)
	$(SWUPD) buildroot report -cache-path $(CACHE_PATH) -clean-garbage

list-files: $(SWUPD)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(SWUPD) buildroot list-files -cache-path $(CACHE_PATH) $(ELEMENT)

check: $(SWUPD)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	echo "CACHE PATH: $(CACHE_PATH)"
	$(SWUPD) buildroot status -cache-path $(CACHE_PATH) $(ELEMENT)

component: $(SWUPD)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(SWUPD) buildroot build -cache-path $(CACHE_PATH) $(ELEMENT)

checkout: $(SWUPD)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(SWUPD) buildroot checkout -cache-path $(CACHE_PATH) $(ELEMENT) $(RELEASE_PATH)

filepath: $(SWUPD)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(SWUPD) buildroot file -cache-path $(CACHE_PATH) $(ELEMENT)

dump-metadata: $(SWUPD)
	$(SWUPD) buildroot dump-metadata -cache-path $(CACHE_PATH) $(CACHE_PATH)/$(CODENAME)

TODO:
	@grep -R "# TODO:" elements/ | sed 's/# TODO://g' > $@
	@cat $@

create-patch: $(SWUPD) $(CREATE_PATCH)
	@if [ -z $(SOURCE) ] ; then echo "ERROR: SOURCE commit not specified"; exit 1; fi
	@if [ -z $(TARGET) ] ; then echo "ERROR: TARGET commit not specified"; exit 1; fi
	
	@if [ $(CONTAIN_CHANGES) ] ; then git stash; fi
	
	@git checkout $(SOURCE)
	$(eval SOURCE_IMAGE_PATH := $(shell $(SWUPD) file -cache-path $(CACHE_PATH) boards/$(ARCH)/image.yml | tail -n1))

	@git checkout $(TARGET)
	$(eval TARGET_IMAGE_PATH := $(shell $(SWUPD) file -cache-path $(CACHE_PATH) boards/$(ARCH)/image.yml | tail -n1))

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

	$(SWUPD) buildroot create-patch $(BUILDDIR)/source $(BUILDDIR)/target

	rm -rf $(BUILDDIR)/_work
	umount $(BUILDDIR)/source $(BUILDDIR)/target || true

define BUILD_ELEMENT

endef

world: $(SWUPD)
	for element in $(ALL_ELEMENTS) ; do 										\
		echo "BUILDING $$element";												\
		if $(SWUPD) buildroot build -cache-path $(CACHE_PATH) $$element ; then 	\
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

check-updates: $(SWUPD)
	$(SWUPD) buildroot check-updates

.PHONY: all clean update-vendor component TODO