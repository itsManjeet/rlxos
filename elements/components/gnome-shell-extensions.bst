kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-shell-extensions/44/gnome-shell-extensions-44.0.tar.xz
  ref: 8c345e72f31a1e37f55063e0b15997301b01194ed698772fd87aeb50cbb101ab

- kind: local
  path: files/gnome-shell-extensions/org.gnome.shell-enabled-extensions.gschema.override
- kind: local
  path: files/gnome-shell-extensions/org.gnome.shell-favorite-apps.gschema.override
- kind: local
  path: files/gnome-shell-extensions/org.gnome.desktop.background.gschema.override

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gnome-menus.bst
- components/gnome-shell.bst
- components/gnome-pie.bst
- components/gnome-shell-extension-blur-my-shell.bst
- components/gnome-shell-extension-dash-from-dock.bst
- components/gnome-shell-extension-gsconnect.bst
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
