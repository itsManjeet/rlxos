kind: meson

(@): elements/components/sysprof.inc

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/libunwind.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dagent=false
    -Dexamples=false
    -Dgtk=false
    -Dtests=false
    -Dtools=false
    -Dlibsysprof=false
    -Dsysprofd=none
    -Dhelp=false
