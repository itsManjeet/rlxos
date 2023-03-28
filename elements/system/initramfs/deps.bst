kind: stack

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/util-linux.bst
- components/linux.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/dracut.bst
- freedesktop-sdk.bst:components/os-release.bst
- freedesktop-sdk.bst:components/shadow.bst
- freedesktop-sdk.bst:components/tzdata.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- components/firmware.bst
- components/libostree.bst
- components/plymouth.bst
