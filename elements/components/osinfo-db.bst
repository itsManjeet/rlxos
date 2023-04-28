kind: manual
sources:
- kind: remote
  url: pagure_releases:libosinfo/osinfo-db-20230308.tar.xz
  ref: 546ba04ecc5e933ba2d7f3f3b4333a2980d4ae4dfc5284989b9c54758f2b9088
build-depends:
- components/osinfo-db-tools.bst

config:
  install-commands:
  - osinfo-db-import --root '%{install-root}' --dir '%{datadir}/osinfo' osinfo-db-*.tar.xz
