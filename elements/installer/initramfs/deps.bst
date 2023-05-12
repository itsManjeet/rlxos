kind: stack

depends:
- components/plymouth.bst
- components/os-release.bst
- installer/isomd5sum.bst

- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/dracut.bst
- freedesktop-sdk.bst:components/gzip.bst
- components/firmware.bst
- components/linux.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/shadow.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/tzdata.bst
- freedesktop-sdk.bst:components/util-linux.bst
- freedesktop-sdk.bst:bootstrap-import.bst
