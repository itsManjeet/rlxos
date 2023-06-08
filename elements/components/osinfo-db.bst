kind: manual
sources:
- kind: remote
  url: pagure_releases:libosinfo/osinfo-db-20230518.tar.xz
  ref: caec5bcce4f2f07c7006bb4f72913d12bdab52595011b4b50937fcd74b81cc6d
build-depends:
- components/osinfo-db-tools.bst

config:
  install-commands:
  - osinfo-db-import --root '%{install-root}' --dir '%{datadir}/osinfo' osinfo-db-*.tar.xz
