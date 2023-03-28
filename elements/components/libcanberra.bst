kind: autotools

sources:
- kind: tar
  url: 0pointer:lennart/projects/libcanberra/libcanberra-0.30.tar.xz

  ref: c2b671e67e0c288a69fc33dc1b6f1b534d07882c2aceed37004bf48c601afa72
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/libpulse.bst
- freedesktop-sdk.bst:components/libtool.bst
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/xdg-sound-theme.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libcanberra-gtk3.so'
        - '%{libdir}/libcanberra.so'
