DOCS_DIR				?= build/docs
OSTREE_BRANCH 		    ?= $(CHANNEL)/$(COLLECTION)
OSTREE_REPO 			?= ostree-repo
OSTREE_GPG 				?= ostree-gpg
VERSION					?= 2.0
CHANNEL					?= unstable
IGNITE					?= build/bin/ignite/ignite

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

.PHONY: $(IGNITE) clean all docs version.yml apps

all: $(IGNITE) version.yml
ifdef ELEMENT
	$(IGNITE) build $(ELEMENT)
endif

$(IGNITE): src/ignite/CMakeLists.txt
	@cmake --build build --target ignite

clean:
	rm -rf $(DOCS_DIR)

TODO.ELEMENTS:
	grep -R "# TODO:" elements | sed 's/# TODO://g' | sed 's#elements/##g' > $@

docs:
	mdbook build -d $(DOCS_DIR)


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

update-app-market:
ifdef MARKET_PATH
	$(IGNITE) meta $(MARKET_PATH)
	./scripts/extract-icons.sh $(MARKET_PATH)/../apps/ $(MARKET_PATH)/../icons/
else
	@echo "no MARKET_PATH specified"
	@exit 1
endif

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
	@echo "channel: ${CHANNEL}" >> $@
	@echo "ostree-branch: ${OSTREE_BRANCH}" >> $@