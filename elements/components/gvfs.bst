kind: meson

sources:
- kind: tar
  url: gnome_downloads:gvfs/1.52/gvfs-1.52.0.tar.xz
  ref: e40e2035a40bc51ce9e88eed05b025596e40bb4aaf9bc632d12ce74fdb30b1f6
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
