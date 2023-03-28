kind: autotools

sources:
- kind: tar
  url: github_files:sass/sassc/archive/refs/tags/3.6.1.tar.gz

  ref: 8cee391c49a102b4464f86fc40c4ceac3a2ada52a89c4c933d8348e3e4542a60
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/libsass.bst
- freedesktop-sdk.bst:bootstrap-import.bst
