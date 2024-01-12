DOCS_DIR				?= build/docs
COLLECTION				?= xfce4
CHANNEL					?= experimental
OSTREE_BRANCH 		    ?= $(CHANNEL)/$(COLLECTION)
OSTREE_REPO 			?= ostree-repo
OSTREE_GPG 				?= ostree-gpg
ELEMENT_FILE			?= system/repo.yml
BUILD_ID				?= 1

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

$(IGNITE):
	@mkdir -p $(shell dirname $(IGNITE))
	go build -o $(IGNITE) rlxos/cmd/ignite

.PHONY: $(IGNITE) clean all docs

all: $(IGNITE)

clean:
	rm $(IGNITE)
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

update-ostree: files/rlxos.gpg
	scripts/commit-ostree.sh														\
	  --gpg-homedir=$(OSTREE_GPG)												\
	  --gpg-sign=$$(cat $(OSTREE_GPG)/default-id)								\
	  --collection-id=dev.rlxos.System											\
	  --build-id=$(BUILD_ID)													\
	  $(OSTREE_REPO) $(ELEMENT_FILE)											\
	  $(OSTREE_BRANCH)