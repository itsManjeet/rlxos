kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-remote-desktop/43/gnome-remote-desktop-43.3.tar.xz
  ref: 11d451d1fde44f1809ebf61aff4bea5f9ef4fdc02359a89647f6e9e7d45429ac
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
