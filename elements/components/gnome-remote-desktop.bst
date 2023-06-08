kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-remote-desktop/44/gnome-remote-desktop-44.2.tar.xz
  ref: 7a9ffd341b5fcb636d26675e9f6269650952163fff5295327618cc2d5cc87b8e
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
