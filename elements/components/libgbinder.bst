kind: manual

depends:
- components/libglibutil.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

config:
  build-commands:
  - make KEEP_SYMBOLS=1 LIBDIR=%{libdir} release pkgconfig

  install-commands:
  - make install-dev LIBDIR=%{libdir} DESTDIR=%{install-root}

sources:
- kind: git_tag
  url: github:mer-hybris/libgbinder.git
  track: master
  ref: 1.1.34-2-g509faccba07696b39c89557a1bed548f25712802
