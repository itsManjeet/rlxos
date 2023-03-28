kind: make

sources:
- kind: tar
  url: github_files:FFmpeg/nv-codec-headers/releases/download/n11.1.5.1/nv-codec-headers-11.1.5.1.tar.gz

  ref: a28cdde3ac0e9e02c2dde7a1b4de5333b4ac6148a8332ca712da243a3361a0d9
depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  make-install: make -j1 PREFIX="%{prefix}" LIBDIR="%{lib}" DESTDIR="%{install-root}"
    install
