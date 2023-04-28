kind: cmake

(@):
  - elements/components/webkitgtk.inc

depends:
  (>):
  - components/gtk.bst
  - components/libsoup.bst

variables:
  cmake-local: >-
    -DPORT=GTK
    -DUSE_GTK4=ON

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libjavascriptcoregtk-6.0.so'
        - '%{libdir}/libwebkitgtk-6.0.so'
      webkit-debug:
      - '%{debugdir}'
      - '%{debugdir}/**'
