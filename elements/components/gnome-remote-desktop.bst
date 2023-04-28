kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-remote-desktop/44/gnome-remote-desktop-44.1.tar.xz
  ref: d1107eaf8ee135a8bff18aafd5d0ed4e898b12841d04b999c541d9d4b24ef623
build-depends:
- components/nv-codec-headers.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libvncserver.bst
- components/freerdp.bst
- components/glib.bst
- components/libnotify.bst
- components/libsecret.bst
- components/pipewire.bst
- freedesktop-sdk.bst:components/tpm2-tss.bst
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/dummy-gbm.bst
- freedesktop-sdk.bst:components/fuse3.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
