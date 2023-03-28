kind: make

sources:
- kind: tar
  url: github_files:rhinstaller/isomd5sum/archive/1.2.3.tar.gz

  ref: b0e706f470c336f689f43ddea33a85aed43fa7e5276221c7ac930e22f795c93c
depends:
- freedesktop-sdk.bst:components/popt.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  # When building in parallel, it might fail with errors about missing
  # symbols.
  notparallel: true
  make: make
  make-install: make -j1 install DESTDIR="%{install-root}" LIBDIR="%{libdir}"
