kind: cmake

(@):
  - elements/components/webkitgtk.inc

depends:
  (>):
  - components/gtk+-3.bst
  - components/libsoup.bst

variables:
  cmake-local: >-
    -DPORT=GTK
    -DENABLE_WEBDRIVER=OFF

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libjavascriptcoregtk-4.1.so'
        - '%{libdir}/libwebkit2gtk-4.1.so'
      webkit-debug:
      - '%{debugdir}'
      - '%{debugdir}/**'
