kind: make

depends:
- components/glib.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

config:
  build-commands:
  - make KEEP_SYMBOLS=1 LIBDIR=%{libdir} release pkgconfig

  install-commands:
  - make install-dev LIBDIR=%{libdir} DESTDIR=%{install-root}
  - mkdir -p %{install-root}%{libdir}/

sources:
- kind: git_tag
  url: github:sailfishos/libglibutil.git
  track: master
  ref: 1.0.69-0-g91f2bffd6ad85286923505037a0954f1ceb52651
