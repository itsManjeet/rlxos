kind: autotools
sources:
- kind: tar
  url: gnome_downloads:vala/0.56/vala-0.56.8.tar.xz
  ref: 93f81dcfc6a93b77baa271d65e6be981ee3238ad451ef380af118e295d904bde
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
