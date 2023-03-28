kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-shell-extensions/43/gnome-shell-extensions-43.1.tar.xz
  ref: adde04bd946a13113557e4c34c890bbe9077505a6a3f0755f17bea1c6e4a2d17

- kind: local
  path: files/gnome-shell-extensions/org.gnome.shell-enabled-extensions.gschema.override
- kind: local
  path: files/gnome-shell-extensions/org.gnome.shell-favorite-apps.gschema.override

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gnome-menus.bst
- components/gnome-shell.bst
- components/gnome-shell-extension-blur-my-shell.bst
- components/gnome-shell-extension-dash-from-dock.bst
- components/gnome-shell-extension-gsconnect.bst
- components/librsvg.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dextension_set=classic

config:
  install-commands:
    (>):
      - install -Dm644 -t %{install-root}/%{datadir}/glib-2.0/schemas/ %{build-root}/*.override