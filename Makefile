CHANNEL								?= unstable
OSTREE_BRANCH 		    			?= $(shell uname -m)/os/$(CHANNEL)
OSTREE_REPO 						?= ostree-repo
OSTREE_GPG 							?= ostree-gpg
VERSION								?= 2.0
IGNITE								?= build/src/ignite/ignite
CACHE_PATH							?= build/
DESTDIR								?= checkout/
APPMARKET_PATH						?= appmarket/

-include config.mk

define OSTREE_GPG_CONFIG
Key-Type: DSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: RLXOS
Expire-Date: 0
%no-protection
%commit
%echo finished
endef


export OSTREE_GPG_CONFIG
export IGNITE
export CACHE_PATH

.PHONY: clean all docs version.yml ostree-branch.yml apps

all: $(IGNITE) version.yml ostree-branch.yml
ifdef ELEMENT
	$(IGNITE) cache-path=$(CACHE_PATH) build $(ELEMENT)
endif

status: $(IGNITE) version.yml ostree-branch.yml
ifdef ELEMENT
	$(IGNITE) cache-path=$(CACHE_PATH) status $(ELEMENT)
else
	@echo "no ELEMENT specified"
	exit 1
endif

filepath: $(IGNITE) version.yml ostree-branch.yml
ifdef ELEMENT
	@PKGUPD_NO_MESSAGE=1 $(IGNITE) cache-path=$(CACHE_PATH) filepath $(ELEMENT)
else
	@echo "no ELEMENT specified"
	exit 1
endif

checkout: $(IGNITE) version.yml ostree-branch.yml
ifdef ELEMENT
	$(IGNITE) cache-path=$(CACHE_PATH) checkout $(ELEMENT) $(DESTDIR)
else
	@echo "no ELEMENT specified"
	exit 1
endif


build/build.ninja: CMakeLists.txt
	cmake -B build

$(IGNITE): build/build.ninja src/ignite/CMakeLists.txt
	@cmake --build build --target ignite

clean:
	rm -rf $(DOCS_DIR)

TODO.ELEMENTS:
	grep -R "# TODO:" elements | sed 's/# TODO://g' | sed 's#elements/##g' > $@

$(OSTREE_GPG)/key-config:
	rm -rf ostree-gpg.tmp
	mkdir ostree-gpg.tmp
	chmod 0700 ostree-gpg.tmp
	echo "$${OSTREE_GPG_CONFIG}" >ostree-gpg.tmp/key-config
	gpg --batch --homedir=ostree-gpg.tmp --generate-key ostree-gpg.tmp/key-config
	gpg --homedir=ostree-gpg.tmp -k --with-colons | sed '/^fpr:/q;d' | cut -d: -f10 >ostree-gpg.tmp/default-id
	mv ostree-gpg.tmp $(OSTREE_GPG)

files/rlxos.gpg: $(OSTREE_GPG)/key-config
	gpg --homedir=$(OSTREE_GPG) --export --armor >"$@"

update-app-market: $(IGNITE) version.yml ostree-branch.yml
	$(IGNITE) cache-path=$(CACHE_PATH) meta $(APPMARKET_PATH)/$(CHANNEL)
	./scripts/extract-icons.sh $(APPMARKET_PATH)/$(CHANNEL)/apps/ $(APPMARKET_PATH)/$(CHANNEL)/icons/

update-ostree: files/rlxos.gpg
ifndef ELEMENT
	@echo "no ELEMENT specified"
	@exit 1
endif
	scripts/commit-ostree.sh													\
	  --gpg-homedir=$(OSTREE_GPG)												\
	  --gpg-sign=$$(cat $(OSTREE_GPG)/default-id)								\
	  --collection-id=dev.rlxos.System											\
	  --version=$(VERSION)													\
	  $(OSTREE_REPO) $(ELEMENT)													\
	  $(OSTREE_BRANCH)

version.yml:
	@echo "version: ${VERSION}" > $@
	@echo "variables:" >> $@
	@echo "  channel: ${CHANNEL}" >> $@

ostree-branch.yml:
	@echo "variables:" > $@
	@echo "  ostree-branch: ${OSTREE_BRANCH}" >> $@