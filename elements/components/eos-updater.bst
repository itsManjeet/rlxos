kind: meson

sources:
- kind: tar
  url: github_files:endlessm/eos-updater/archive/Release_4.0.7.tar.gz
  ref: 583fd4c02d48d38a5f3f089e654ede2448aec49aaf6d2096a1798538c844d627
- kind: patch
  path: patches/eos-updater/no-ostree-httpd.patch
depends:
- components/networkmanager.bst
- components/mogwai.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:components/avahi.bst
- freedesktop-sdk.bst:components/flatpak.bst
- freedesktop-sdk.bst:components/gnupg.bst
- freedesktop-sdk.bst:components/ostree.bst
- freedesktop-sdk.bst:bootstrap-import.bst

build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/valgrind-maybe.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

variables:
  meson-local: >-
    -Dmetrics=disabled
