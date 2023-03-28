kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-session/43/gnome-session-43.0.tar.xz
  ref: 3fb9949501385c8c14618e78f178d952df98ad8c91080f4c5e1568c7393ae1f2
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
