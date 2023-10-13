kind: stack

depends:
  - components/sudoer.bst
  - components/gnome-console.bst
  - components/gparted.bst
  - components/os-installer-extra.bst
  - installer/pseudo-dirs.bst

  - components/plymouth.bst
  - components/branding.bst
  - components/gnome-shell-extensions.bst
  - components/default-backgrounds.bst

  - freedesktop-sdk.bst:components/wayland.bst
  - freedesktop-sdk.bst:components/systemd.bst
  - components/linux.bst
  - components/firmware.bst

  - freedesktop-sdk.bst:components/shadow.bst
  - freedesktop-sdk.bst:vm/mesa-default.bst
  - freedesktop-sdk.bst:vm/config/journald.bst
  - freedesktop-sdk.bst:components/less.bst
  - freedesktop-sdk.bst:components/nano.bst
  - freedesktop-sdk.bst:components/locales.bst
  - freedesktop-sdk.bst:components/supported-locales.bst

  - components/spice-vdagent.bst
  - components/os-release.bst
