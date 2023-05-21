kind: manual

depends:
- components/python-gbinder.bst
- components/pygobject.bst
- components/dnsmasq.bst
- freedesktop-sdk.bst:components/python3-dbus.bst

runtime-depends:
- components/waydroid-image.bst

config:
  install-commands:
  - make install DESTDIR=%{install-root} USE_NFTABLES=1


sources:
- kind: git_tag
  url: github:waydroid/waydroid.git
  track: main
  ref: 1.4.1-0-g7ce2e28e8ea76c1e79b273d122921c1f394e842f
