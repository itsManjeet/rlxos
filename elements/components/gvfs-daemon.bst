kind: filter

build-depends:
- components/gvfs.bst

runtime-depends:
- components/gvfs-client.bst
- components/gnome-online-accounts.bst
- components/libbluray.bst
- components/libcdio-paranoia.bst
- components/libgdata.bst
- components/libgphoto2.bst
- components/libimobiledevice.bst
- components/libmtp.bst
- components/libnfs.bst
- components/plist.bst
- components/samba.bst
- components/udisks2.bst
- components/gcr-3.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/libsecret.bst
- components/libsoup.bst
- freedesktop-sdk.bst:components/avahi.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/fuse3.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:components/openssh.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  exclude:
  - gvfs-client
