kind: manual

sources:
- kind: git_tag
  url: github:systemd/zram-generator
  track: main
- kind: cargo-lock
- kind: cargo
- kind: local
  path: files/zram-generator.conf
build-depends:
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:components/systemd.bst

config:
  build-commands:
  - make build RONN=true NOMAN=1
  install-commands:
  - make install PREFIX=%{prefix} DESTDIR=%{install-root} RONN=true NOMAN=1
  - install -Dm 0644 -t %{install-root}%{sysconfdir}/systemd/ zram-generator.conf
