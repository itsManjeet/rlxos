kind: autotools
sources:
- kind: tar
  url: github_files:AbiWord/enchant/releases/download/v2.2.15/enchant-2.2.15.tar.gz
  ref: 3b0f2215578115f28e2a6aa549b35128600394304bd79d6f28b0d3b3d6f46c03
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- components/nuspell.bst
- freedesktop-sdk.bst:components/hunspell.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --with-hunspell
    --with-hunspell-dir=/usr/share/myspell
    --with-nuspell
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libenchant-2.so'
