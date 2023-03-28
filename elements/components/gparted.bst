kind: autotools

sources:
- kind: tar
  url: https://downloads.sourceforge.net/project/gparted/gparted/gparted-1.4.0/gparted-1.4.0.tar.gz

  ref: e5293a792e53fdbeba29c4a834113cd9603d0d639330da931a468bf3687887be
build-depends:
- components/intltool.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/gtkmm-3.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/parted.bst
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/ntfs-3g.bst
- freedesktop-sdk.bst:components/btrfs-progs.bst
- freedesktop-sdk.bst:components/dosfstools.bst
- freedesktop-sdk.bst:components/e2fsprogs.bst
- freedesktop-sdk.bst:components/f2fs-tools.bst

variables:
  conf-local: >-
    --enable-online-resize
    --enable-libparted-dmraid
    --enable-xhost-root

config:
  install-commands:
    (<):
    - install -D -m0644 org.gnome.gparted.policy -t %{install-root}%{datadir}/polkit-1/actions/
