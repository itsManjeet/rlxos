kind: autotools
sources:
- kind: tar
  url: gnome_downloads:vala/0.56/vala-0.56.7.tar.xz
  ref: 3d39c7596d5fa9ae8bfeae476669f811f7057b7f7b9308478a27b68443d8b003
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
