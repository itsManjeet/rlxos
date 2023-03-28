kind: manual
sources:
- kind: remote
  url: pagure_releases:libosinfo/osinfo-db-20221130.tar.xz
  ref: a2954cad7a1bef2679949987c63888f1e081b09e11fb725054372f037ec7717f
build-depends:
- components/osinfo-db-tools.bst

config:
  install-commands:
  - osinfo-db-import --root '%{install-root}' --dir '%{datadir}/osinfo' osinfo-db-*.tar.xz
