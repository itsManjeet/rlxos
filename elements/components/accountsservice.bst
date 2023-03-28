kind: meson

sources:
- kind: tar
  base-dir: ''
  url: freedesktop_software:accountsservice/accountsservice-22.08.8.tar.xz

  ref: 909997a76919fe7dc138a9a01cea70bd622d5a932dbc9fb13010113023a7a391
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
