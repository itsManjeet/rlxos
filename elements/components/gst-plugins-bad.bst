kind: filter


build-depends:
- freedesktop-sdk.bst:components/gstreamer-plugins-bad.bst
runtime-depends:
- components/gst-plugins-base.bst
- components/librsvg.bst
- freedesktop-sdk.bst:components/aom.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/frei0r.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/ladspa-sdk.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/libfdk-aac.bst
- freedesktop-sdk.bst:components/libglvnd.bst
- freedesktop-sdk.bst:components/libnice.bst
- freedesktop-sdk.bst:components/libwebp.bst
- freedesktop-sdk.bst:components/libsrtp2.bst
- freedesktop-sdk.bst:components/noopenh264.bst
- freedesktop-sdk.bst:components/openal.bst
- freedesktop-sdk.bst:components/orc.bst
- freedesktop-sdk.bst:components/sndfile.bst
- freedesktop-sdk.bst:components/vulkan-headers.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/webrtc-audio-processing.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgstadaptivedemux-1.0.so'
        - '%{libdir}/libgstbadaudio-1.0.so'
        - '%{libdir}/libgstbasecamerabinsrc-1.0.so'
        - '%{libdir}/libgstcodecparsers-1.0.so'
        - '%{libdir}/libgstinsertbin-1.0.so'
        - '%{libdir}/libgstisoff-1.0.so'
        - '%{libdir}/libgstmpegts-1.0.so'
        - '%{libdir}/libgstphotography-1.0.so'
        - '%{libdir}/libgstplayer-1.0.so'
        - '%{libdir}/libgstsctp-1.0.so'
        - '%{libdir}/libgsturidownloader-1.0.so'
        - '%{libdir}/libgstwayland-1.0.so'
        - '%{libdir}/libgstwebrtc-1.0.so'
