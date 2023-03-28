kind: autotools

sources:
- kind: tar
  url: freedesktop_software:plymouth/releases/plymouth-22.02.122.tar.xz

  ref: 100551442221033ce868c447ad6c74d831d209c18ae232b98ae0207e34eadaeb

- kind: local
  path: files/plymouth

depends:
- components/gtk+-3.bst
- components/pango.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/systemd.bst

build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

config:
  install-commands:
    (>):
    - mv "%{install-root}/var/run" "%{install-root}/"
    - install -Dm644 plymouthd.defaults "%{install-root}%{datadir}/plymouth/plymouthd.defaults"