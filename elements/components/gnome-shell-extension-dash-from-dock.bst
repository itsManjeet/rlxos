kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/gnome-shell.bst

sources:
- kind: git_tag
  url: github:dgsasha/dock-from-dash.git
  track: main
  ref: 8e6147e37bb33da7e8dc08800933d2c16569ca64

- kind: patch
  path: patches/gnome-shell-extensions/dash-from-dock/0001-rlxos-default-configurations.patch

config:
  install-commands:
    (>):
    - glib-compile-schemas %{install-root}%{datadir}/gnome-shell/extensions/dock-from-dash@fthx/schemas
