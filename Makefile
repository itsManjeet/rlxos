ARCH ?= $(shell uname -m)
VARIANT ?= desktop
OSTREE_BRANCH ?= $(ARCH)/$(VARIANT)
OSTREE_REPO ?= ostree-repo
OSTREE_GPG ?= ostree-gpg
BST_FILE ?= system/repo.bst
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
export VARIANT

all: update-ostree

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
	utils/commit-ostree.sh														\
	  --gpg-homedir=$(OSTREE_GPG)												\
	  --gpg-sign=$$(cat $(OSTREE_GPG)/default-id)								\
	  --collection-id=dev.rlxos.System											\
	  $(OSTREE_REPO) $(BST_FILE)   												\
	  $(OSTREE_BRANCH)
