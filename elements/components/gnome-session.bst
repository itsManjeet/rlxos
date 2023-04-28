kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-session/44/gnome-session-44.0.tar.xz
  ref: ccf829a96526135e9e9f917526515d36a5092bdfa316f3737dd8c5a524dbf2c6
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
