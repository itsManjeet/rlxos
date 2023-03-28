kind: manual

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  build-commands:
  - |
    cd libraries/liblmdb
    make prefix="%{prefix}" libdir="%{libdir}" bindir="%{bindir}" XCFLAGS="${CFLAGS}"
  install-commands:
  - |
    cd libraries/liblmdb
    make install prefix="%{prefix}" libdir="%{libdir}" bindir="%{bindir}" DESTDIR='%{install-root}'

sources:
- kind: tar
  url: github_files:LMDB/lmdb/archive/LMDB_0.9.28.tar.gz
  ref: 47457d3d3ae2c489b52078a07e9f55ec6e094b48c2204029c7754e2972fe1882
