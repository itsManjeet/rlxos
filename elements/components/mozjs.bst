kind: manual

sources:
- kind: tar
  url: https://ftp.mozilla.org/pub/firefox/releases/102.1.0esr/source/firefox-102.1.0esr.source.tar.xz
  base-dir: 'firefox-102.1.0'
  ref: 637b6e727d1b815bbc6eb39aeb04c6e144056eeb3c628b298cb16deb3b579460
- kind: patch
  path: patches/mozjs/0001-Bug-1776254-Install-ProfilingCategoryList.h.patch
- kind: patch
  path: patches/mozjs/0002-Bug-1780857-Change-if-to-ifdef-for-DEBUG.patch

build-depends:
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/which.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:components/nspr.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  optimize-debug: "false"

environment:
  MACH_USE_SYSTEM_PYTHON: '1'
  MAXJOBS: '%{max-jobs}'
  CC: gcc
  CXX: g++

environment-nocache:
- MAXJOBS

config:
  create-dev-shm: true
  configure-commands:
  - |
    cat >mozconfig <<EOF
    ac_add_options --prefix="%{prefix}"
    ac_add_options --libdir="%{libdir}"
    ac_add_options --host="%{triplet}"
    ac_add_options --target="%{triplet}"
    ac_add_options --enable-application=js
    ac_add_options --enable-release
    ac_add_options --with-intl-api
    ac_add_options --with-system-nspr
    ac_add_options --with-system-zlib
    ac_add_options --with-system-icu
    ac_add_options --enable-readline
    ac_add_options --disable-jemalloc
    mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/build-dir
    EOF

  - ./mach configure

  build-commands:
  - ./mach build -j${MAXJOBS} --verbose

  install-commands:
  - make -C build-dir -j1 install DESTDIR="%{install-root}"
  - rm -rf "%{install-root}%{bindir}"
  - rm "%{install-root}%{libdir}/libjs_static.ajs"
