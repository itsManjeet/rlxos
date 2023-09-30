kind: meson

sources:
- kind: tar
  base-dir: ''
  url: freedesktop_software:accountsservice/accountsservice-23.13.9.tar.xz

  ref: adda4cdeae24fa0992e7df3ffff9effa7090be3ac233a3edfdf69d5a9c9b924f
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson: meson %{build-dir} */ %{meson-args}
