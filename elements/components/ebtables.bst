kind: autotools
sources:
- kind: tar
  url: netfilter:pub/ebtables/ebtables-2.0.11.tar.gz
  ref: b71f654784a726329f88b412ef7b96b4e5d786ed2bd28193ed7b4c0d677dfd2a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
config:
  install-commands:
    (>):
    - rm '%{install-root}%{sysconfdir}/ethertypes'
