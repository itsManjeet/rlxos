kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-shell-extensions/45/gnome-shell-extensions-45.0.tar.xz
  ref: 239bf89ff52794f8d5e86acd85fbfe5c24be8ce167c57690db2efd587c339fd6

- kind: local
  path: files/gnome-shell-extensions/

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gnome-menus.bst
- components/gnome-shell.bst
- components/gnome-pie.bst
- components/gnome-shell-extension-blur-my-shell.bst
- components/gnome-shell-extension-dash-from-dock.bst
- components/gnome-shell-extension-gsconnect.bst
- components/adw-theme.bst
# - components/gnome-shell-extension-aylur-widgets.bst
- components/librsvg.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dextension_set=classic

config:
  install-commands:
    (>):
    - install -Dm644 -t %{install-root}/%{datadir}/glib-2.0/schemas/ %{build-root}/*.override
