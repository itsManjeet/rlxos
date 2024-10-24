CHANNEL								?= unstable
OSTREE_BRANCH 		    			?= $(shell uname -m)/os/$(CHANNEL)
OSTREE_REPO 						?= ostree-repo
OSTREE_GPG 							?= ostree-gpg
VERSION								?= 2.0
PKGUPD								?= build/src/pkgupd/bin/pkgupd
CACHE_PATH							?= build/
DESTDIR								?= checkout/
APPMARKET_PATH						?= appmarket/
KEY_TYPES							:= PK KEK DB VENDOR linux-module-cert
ALL_CERTS							 = $(foreach KEY,$(KEY_TYPES),files/sign-keys/$(KEY).crt)
ALL_KEYS							 = $(foreach KEY,$(KEY_TYPES),files/sign-keys/$(KEY).key)
BOOT_KEYS							 = $(ALL_KEYS) $(ALL_CERTS) files/sign-keys/extra-db/.keep files/sign-keys/extra-kek/.keep files/sign-keys/modules/linux-module-cert.crt

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
export PKGUPD
export CACHE_PATH

.PHONY: clean all docs version.yml channel.yml ostree-branch.yml apps TODO.ELEMENTS

all: $(PKGUPD) version.yml ostree-branch.yml channel.yml
ifdef ELEMENT
	$(PKGUPD) ignite build ignite.cache=$(CACHE_PATH) $(ELEMENT)
endif

status: $(PKGUPD) version.yml ostree-branch.yml channel.yml
ifdef ELEMENT
	$(PKGUPD) ignite status ignite.cache=$(CACHE_PATH) $(ELEMENT)
else
	@echo "no ELEMENT specified"
	exit 1
endif

filepath: $(PKGUPD) version.yml ostree-branch.yml  channel.yml
ifdef ELEMENT
	@PKGUPD_NO_MESSAGE=1 $(PKGUPD) ignite filepath ignite.cache=$(CACHE_PATH) $(ELEMENT)
else
	@echo "no ELEMENT specified"
	exit 1
endif

checkout: $(PKGUPD) version.yml ostree-branch.yml  channel.yml
ifdef ELEMENT
	$(PKGUPD) ignite checkout ignite.cache=$(CACHE_PATH) $(ELEMENT) $(DESTDIR)
else
	@echo "no ELEMENT specified"
	exit 1
endif


build/build.ninja: CMakeLists.txt
	cmake -B build

$(PKGUPD): build/build.ninja src/pkgupd/CMakeLists.txt
	@cmake --build build --target pkgupd

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

update-app-market: $(PKGUPD) version.yml ostree-branch.yml channel.yml
	$(PKGUPD) ignite meta ignite.cache=$(CACHE_PATH) $(APPMARKET_PATH)/$(CHANNEL)
	./scripts/extract-icons.sh $(APPMARKET_PATH)/$(CHANNEL)/apps/ $(APPMARKET_PATH)/$(CHANNEL)/icons/

update-ostree: $(PKGUPD) version.yml ostree-branch.yml channel.yml files/rlxos.gpg
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

 channel.yml:
	@echo "variables:" > $@
	@echo "  channel: ${CHANNEL}" >> $@

generate-keys: $(BOOT_KEYS) 

files/sign-keys/extra-db/.keep files/sign-keys/extra-kek/.keep:
	[ -d $(dir $@) ] || mkdir -p $(dir $@)
	touch $@

files/sign-keys/modules/linux-module-cert.crt: files/sign-keys/linux-module-cert.crt
	mkdir -p files/sign-keys/modules
	cp $< $@

files/sign-keys/%.crt files/sign-keys/%.key:
	[ -d files/sign-keys ] || mkdir -p files/sign-keys
	openssl req -new -x509 -newkey rsa:2048 -subj "/CN=RLXOS $(basename $(notdir $@)) key/" -keyout "$(basename $@).key" -out "$(basename $@).crt" -days 3650 -nodes -sha256

download-microsoft-keys: files/sign-keys/extra-db/.keep files/sign-keys/extra-kek/.keep
	curl https://www.microsoft.com/pkiops/certs/MicCorUEFCA2011_2011-06-27.crt | openssl x509 -inform der -outform pem >files/sign-keys/extra-kek/mic-kek.crt
	echo 77fa9abd-0359-4d32-bd60-28f4e78f784b >files/sign-keys/extra-kek/mic-kek.owner
	curl https://www.microsoft.com/pkiops/certs/MicCorUEFCA2011_2011-06-27.crt | openssl x509 -inform der -outform pem >files/sign-keys/extra-db/mic-other.crt
	echo 77fa9abd-0359-4d32-bd60-28f4e78f784b >files/sign-keys/extra-db/mic-other.owner
	curl https://www.microsoft.com/pkiops/certs/MicWinProPCA2011_2011-10-19.crt | openssl x509 -inform der -outform pem >files/sign-keys/extra-db/mic-win.crt
	echo 77fa9abd-0359-4d32-bd60-28f4e78f784b >files/sign-keys/extra-db/mic-win.owner

