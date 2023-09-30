kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-remote-desktop/45/gnome-remote-desktop-45.rc.tar.xz
  ref: 82646c3db9df044d80a72ae8b9f9a017784f05468c5dc4f001417c98a9f0b7a5
build-depends:
- components/nv-codec-headers.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libvncserver.bst
- components/freerdp.bst
- components/libei.bst
- components/glib.bst
- components/libnotify.bst
- components/libsecret.bst
- freedesktop-sdk.bst:components/tpm2-tss.bst
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/dummy-gbm.bst
- freedesktop-sdk.bst:components/fuse3.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/pipewire.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dtests=false
