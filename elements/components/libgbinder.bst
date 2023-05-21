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
  ref: 1.1.34-0-g62b9b30865b65886a5808ab8087194fcca163c90
