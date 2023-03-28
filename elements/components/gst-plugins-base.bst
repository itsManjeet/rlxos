kind: filter

build-depends:
- freedesktop-sdk.bst:components/gstreamer-plugins-base.bst
runtime-depends:
- components/gdk-pixbuf.bst
- components/gtk+-3.bst
- components/pango.bst
- freedesktop-sdk.bst:components/alsa-lib.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/libogg.bst
- freedesktop-sdk.bst:components/libtheora.bst
- freedesktop-sdk.bst:components/libvorbis.bst
- freedesktop-sdk.bst:components/mesa-headers.bst
- freedesktop-sdk.bst:components/opus.bst
- freedesktop-sdk.bst:components/orc.bst
- freedesktop-sdk.bst:components/sdl2.bst
- freedesktop-sdk.bst:components/xorg-lib-xv.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgstallocators-1.0.so'
        - '%{libdir}/libgstapp-1.0.so'
        - '%{libdir}/libgstaudio-1.0.so'
        - '%{libdir}/libgstfft-1.0.so'
        - '%{libdir}/libgstgl-1.0.so'
        - '%{libdir}/libgstpbutils-1.0.so'
        - '%{libdir}/libgstriff-1.0.so'
        - '%{libdir}/libgstrtp-1.0.so'
        - '%{libdir}/libgstrtsp-1.0.so'
        - '%{libdir}/libgstsdp-1.0.so'
        - '%{libdir}/libgsttag-1.0.so'
        - '%{libdir}/libgstvideo-1.0.so'
