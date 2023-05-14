kind: meson

sources:
- kind: git_tag
  url: freedesktop:hadess/switcheroo-control
  track: master

  ref: 2.6-9-gd99d8c3ef9914d2f2fb5f4a2c945a4a4bff5eeeb
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libgudev.bst
- components/pygobject.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/systemd.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/python3-setuptools.bst
- freedesktop-sdk.bst:components/python3-dbus.bst
- freedesktop-sdk.bst:components/python3-dbusmock.bst
