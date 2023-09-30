kind: autotools
sources:
- kind: tar
  url: gnome_downloads:vala/0.56/vala-0.56.13.tar.xz
  ref: 4988223036c7e1e4874c476d0de8bd9cbe500ee25ef19a76e560dc0b6d56ae07
build-depends:
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/git-minimal.bst
- freedesktop-sdk.bst:components/vala-bootstrap.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --enable-unversioned
    --disable-valadoc
  make: make bootstrap
