kind: manual
sources:
- kind: remote
  url: pagure_releases:libosinfo/osinfo-db-20230719.tar.xz
  ref: 13d1c97fc7d67137935dcc97778c08bb079a4f0fe312d479786cea1411e4845a
build-depends:
- components/osinfo-db-tools.bst

config:
  install-commands:
  - osinfo-db-import --root '%{install-root}' --dir '%{datadir}/osinfo' osinfo-db-*.tar.xz
