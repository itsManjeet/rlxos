kind: autotools

sources:
- kind: tar
  url: spice:releases/spice-vdagent-0.22.1.tar.bz2

  ref: 93b0d15aca4762cc7d379b179a7101149dbaed62b72112fffb2b3e90b11687a0
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/glib.bst
- components/spice-protocol.bst
- freedesktop-sdk.bst:components/alsa-lib.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:components/xorg-lib-xrandr.bst
- freedesktop-sdk.bst:components/xorg-lib-xfixes.bst
- freedesktop-sdk.bst:components/xorg-lib-xinerama.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --with-session-info=systemd
    --with-init-script=systemd
