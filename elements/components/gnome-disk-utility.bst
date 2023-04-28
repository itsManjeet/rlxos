kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-disk-utility/44/gnome-disk-utility-44.0.tar.xz
  ref: 02031097896cdb37d8717a5823f93e3723d4dfce7fdc4002c9dfcb16b7e7a3ef
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
