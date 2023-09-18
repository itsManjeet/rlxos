ARCH			?= x86_64

VERSION			?= 999
CODENAME		?= rolling
CHANGELOG		?= "NO CHANGELOG"
SERVER			?= "http://storage.rlxos.dev"

GOLANG			?= go

TARGET_TRIPLE	:= $(ARCH)-elf

BUILDDIR		?= $(shell pwd)/build

CACHE_PATH		?= $(BUILDDIR)/cache

REPO_BUILDER	?= $(BUILDDIR)/builder
CREATE_PATCH	?= $(BUILDDIR)/create-patch
RELEASE_PATH	?= $(BUILDDIR)/release

CURCOMMIT		:= $(shell git rev-parse HEAD)

BOARD			?= $(ARCH)
CONTAIN_CHANGES := $(shell git diff-index --quiet HEAD --; echo $$?)

ALL_ELEMENTS	:= $(wildcard elements/components/*.yml)
ALL_ELEMENTS	:= $(ALL_ELEMENTS:elements/%=%)

export PATH := $(PATH):$(TOOLCHAIN_PATH)/bin

all: $(REPO_BUILDER)

clean:
	rm -f $(KERNEL_IMAGE) $(KERNEL_IMAGE).txt $(ISOFILE)
	rm -rf $(ISODIR) vendor
	rm -f $(REPO_BUILDER)

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

$(CREATE_PATCH):
	$(GOLANG) build -o $@ rlxos/cmd/create-patch

report: $(REPO_BUILDER)
	$(REPO_BUILDER) report -cache-path $(CACHE_PATH)

clean-garbage: $(REPO_BUILDER)
	$(REPO_BUILDER) report -cache-path $(CACHE_PATH) -clean-garbage

list-files: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) list-files -cache-path $(CACHE_PATH) $(ELEMENT)

check: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	echo "CACHE PATH: $(CACHE_PATH)"
	$(REPO_BUILDER) status -cache-path $(CACHE_PATH) $(ELEMENT)

component: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) build -cache-path $(CACHE_PATH) $(ELEMENT)

checkout: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) checkout -cache-path $(CACHE_PATH) $(ELEMENT) $(RELEASE_PATH)

filepath: $(REPO_BUILDER)
	@if [ -z $(ELEMENT) ] ;then echo "ERROR: no element specified"; exit 1; fi
	@if [ ! -f elements/$(ELEMENT) ] ; then echo "ERROR: no element exists elements/$(ELEMENT)"; exit 1; fi
	$(REPO_BUILDER) file -cache-path $(CACHE_PATH) $(ELEMENT)

market-data: $(REPO_BUILDER)
	$(REPO_BUILDER) create-market-data -cache-path $(CACHE_PATH) $(CACHE_PATH)

TODO:
	@grep -R "# TODO:" elements/ | sed 's/# TODO://g' > $@
	@cat $@

create-patch: $(REPO_BUILDER) $(CREATE_PATCH)
	@if [ -z $(SOURCE) ] ; then echo "ERROR: SOURCE commit not specified"; exit 1; fi
	@if [ -z $(TARGET) ] ; then echo "ERROR: TARGET commit not specified"; exit 1; fi
	
	@if [ $(CONTAIN_CHANGES) ] ; then git stash; fi
	
	@git checkout $(SOURCE)
	$(eval SOURCE_IMAGE_PATH := $(shell $(REPO_BUILDER) file -cache-path $(CACHE_PATH) boards/$(ARCH)/image.yml | tail -n1))

	@git checkout $(TARGET)
	$(eval TARGET_IMAGE_PATH := $(shell $(REPO_BUILDER) file -cache-path $(CACHE_PATH) boards/$(ARCH)/image.yml | tail -n1))

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

	$(CREATE_PATCH) $(BUILDDIR)/source $(BUILDDIR)/target

	rm -rf $(BUILDDIR)/_work
	umount $(BUILDDIR)/source $(BUILDDIR)/target || true

define BUILD_ELEMENT

endef

world: $(REPO_BUILDER)
	for element in $(ALL_ELEMENTS) ; do 										\
		echo "BUILDING $$element";												\
		if $(REPO_BUILDER) build -cache-path $(CACHE_PATH) $$element ; then 	\
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

check-updates: $(REPO_BUILDER)
	$(REPO_BUILDER) check-updates

.PHONY: all clean update-vendor component TODO