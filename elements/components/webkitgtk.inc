sources:
- kind: tar
  url: webkitgtk:webkitgtk-2.42.0.tar.xz
  ref: 828f95935861fae583fb8f2ae58cf64c63c178ae2b7c2d6f73070813ad64ed1b

build-depends:
- components/gi-docgen.bst
- components/unifdef.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/gperf.bst
- freedesktop-sdk.bst:components/llvm.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:components/ruby.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

runtime-depends:
- freedesktop-sdk.bst:components/gstreamer-libav.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-good.bst

depends:
- components/at-spi2-core.bst
- components/enchant-2.bst
- components/libavif.bst
- components/libjxl.bst
- components/libmanette.bst
- components/libnotify.bst
- components/libsecret.bst
- components/libwpe.bst
- components/pango.bst
- components/woff2.bst
- components/wpebackend-fdo.bst
- freedesktop-sdk.bst:components/brotli.bst
- freedesktop-sdk.bst:components/bubblewrap.bst
- freedesktop-sdk.bst:components/dummy-gbm.bst
- freedesktop-sdk.bst:components/geoclue.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-bad.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-base.bst
- freedesktop-sdk.bst:components/hyphen.bst
- freedesktop-sdk.bst:components/lcms.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:components/libtasn1.bst
- freedesktop-sdk.bst:components/libwebp.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/openjpeg.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/xdg-dbus-proxy.bst
- freedesktop-sdk.bst:components/xorg-lib-xt.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  optimize-debug: 'false'
  (?):
  - arch == "i686" or arch == "arm":
      debug_flags: "-g1"

public:
  cpe:
    product: webkitgtk+

environment:
  CC: clang
  CXX: clang++
