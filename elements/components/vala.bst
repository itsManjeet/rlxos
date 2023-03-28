kind: autotools
sources:
- kind: tar
  url: gnome_downloads:vala/0.56/vala-0.56.3.tar.xz
  ref: e1066221bf7b89cb1fa7327a3888645cb33b604de3bf45aa81132fd040b699bf
build-depends:
- components/vala-tarball.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/git-minimal.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --enable-unversioned
    --disable-valadoc
  make: make bootstrap
