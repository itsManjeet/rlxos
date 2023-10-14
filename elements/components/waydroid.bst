kind: manual

depends:
- components/lxc.bst
- components/python-gbinder.bst
- components/pygobject.bst
- components/dnsmasq.bst
- freedesktop-sdk.bst:components/python3-dbus.bst

runtime-depends:
- components/waydroid-script.bst

config:
  install-commands:
  - make install DESTDIR=%{install-root} USE_NFTABLES=1


sources:
- kind: git_tag
  url: github:waydroid/waydroid.git
  track: main
  ref: 1.4.1-17-gb67b208d89b654880cca5be9f2e6803db12d2774
