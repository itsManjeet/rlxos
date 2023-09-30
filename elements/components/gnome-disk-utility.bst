kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-disk-utility/45/gnome-disk-utility-45.0.tar.xz
  ref: 3d8625faa99047bc4aefd29921ad728ab4d700cff86e0f2ec67e8dba877d0dd3
build-depends:
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
