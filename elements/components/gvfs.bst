kind: meson

sources:
- kind: tar
  url: gnome_downloads:gvfs/1.50/gvfs-1.50.3.tar.xz
  ref: 6897119e97bb16029d2778e1a5a54a6a6592631f8b2f3a2a1dea4ef2b01803fd
build-depends:
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
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

public:
  bst:
    split-rules:
      gvfs-client:
      - '%{includedir}'
      - '%{includedir}/**'
      - '%{libdir}/gio/**'
      - '%{libdir}/gvfs/libgvfscommon.so'
      - '%{debugdir}%{libdir}/gio/**'
      - '%{debugdir}%{libdir}/gvfs/libgvfscommon.so.debug'
      - '%{debugdir}/dwz/**'
      - '%{sourcedir}/%{element-name}/common/**'
      - '%{sourcedir}/%{element-name}/client/**'
