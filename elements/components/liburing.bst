kind: make
sources:
- kind: tar
  url: github_files:axboe/liburing/archive/refs/tags/liburing-2.4.tar.gz
  ref: 2398ec82d967a6f903f3ae1fd4541c754472d3a85a584dc78c5da2fabc90706b
- kind: patch
  path: patches/liburing/0001-enable-libc.patch
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
config:
  configure-commands:
  - >-
    ./configure
    --prefix=%{prefix}
    --mandir=%{mandir}
    --libdir=/%{libdir}
    --libdevdir=/%{libdir}
    --includedir=%{includedir}
    --datadir=%{datadir}
  install-commands:
    (>):
    - rm "%{install-root}%{libdir}/liburing-ffi.a"
    - rm "%{install-root}%{libdir}/liburing.a"
