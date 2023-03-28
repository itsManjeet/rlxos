kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-disk-utility/43/gnome-disk-utility-43.0.tar.xz
  ref: 7afca9805a6b92db6933dd7efcec4af8386c01bbc1f871e2dae4def7e192a2c5
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libdvdread.bst
- components/udisks2.bst
- components/gnome-settings-daemon.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/libnotify.bst
- components/libsecret.bst
- freedesktop-sdk.bst:components/pwquality.bst
- freedesktop-sdk.bst:bootstrap-import.bst
