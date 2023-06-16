kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/gnome-shell.bst

sources:
- kind: git_tag
  url: github:dgsasha/dock-from-dash.git
  track: main
  ref: a96461c3803088b08c5f0836661cc56614023f13

- kind: patch
  path: patches/gnome-shell-extensions/dash-from-dock/0001-rlxos-default-configurations.patch

config:
  configure-commands:
    (<):
    - sed -i '10i ,"44"' metadata.json
  install-commands:
    (>):
    - glib-compile-schemas %{install-root}%{datadir}/gnome-shell/extensions/dock-from-dash@fthx/schemas
