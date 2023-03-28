kind: filter

build-depends:
- components/ibus.bst

runtime-depends:
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  include:
    - libibus
  include-orphans: false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libibus-1.0.so'
