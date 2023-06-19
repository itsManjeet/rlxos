kind: stack

depends:
- components/sudoer.bst
- components/gnome-console.bst
- components/gparted.bst
- components/os-installer-extra.bst
- boards/common/pseudo-dirs.bst

- components/plymouth.bst
- components/branding.bst
- components/gnome-shell-extensions.bst
- components/default-backgrounds.bst

- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/systemd.bst
- components/linux.bst
- proprietary/nvidia/pkg.bst
- components/firmware.bst

- freedesktop-sdk.bst:components/shadow.bst
- freedesktop-sdk.bst:vm/mesa-default.bst
- freedesktop-sdk.bst:vm/config/journald.bst
- freedesktop-sdk.bst:components/less.bst
- freedesktop-sdk.bst:components/nano.bst

- components/spice-vdagent.bst
- components/os-release.bst
