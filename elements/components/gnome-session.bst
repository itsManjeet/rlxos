kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-session/45/gnome-session-45.0.tar.xz
  ref: 706d2ffcacac38553a3c0185793f5a2b4aac940bb5e789d953c9808163bef2f1
build-depends:
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/xmlto.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/upower.bst
- components/gnome-desktop.bst
- components/gtk+-3.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/xorg-lib-ice.bst
- freedesktop-sdk.bst:components/xorg-lib-sm.bst
- freedesktop-sdk.bst:bootstrap-import.bst
