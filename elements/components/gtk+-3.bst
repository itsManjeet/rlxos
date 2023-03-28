kind: meson

sources:
- kind: tar
  url: gnome_downloads:gtk+/3.24/gtk+-3.24.36.tar.xz
  ref: 27a6ef157743350c807ffea59baa1d70226dbede82a5e953ffd58ea6059fe691
- kind: patch
  path: files/gtk3/gtk3-werror.patch

build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/cantarell-fonts.bst

depends:
- components/at-spi2-core.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/pango.bst
- components/tracker.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/hicolor-icon-theme.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/mesa-headers.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/xorg-lib-xcomposite.bst
- freedesktop-sdk.bst:components/xorg-lib-xcursor.bst
- freedesktop-sdk.bst:components/xorg-lib-xdamage.bst
- freedesktop-sdk.bst:components/xorg-lib-xi.bst
- freedesktop-sdk.bst:components/xorg-lib-xinerama.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  local_flags: '-DG_ENABLE_DEBUG -DG_DISABLE_CAST_CHECKS'
  meson-local: >-
    -Dbroadway_backend=true
    -Dinstalled_tests=true
    -Dtests=false
    -Dx11_backend=true
    -Dwayland_backend=true
    -Dgtk_doc=true
    -Dman=true
    -Dintrospection=true
    -Dtracker3=true
    -Dprofiler=false

public:
  bst:
    integration-commands:
    - |-
      for dir in %{prefix}/share/icons/*; do
        if test -f $dir/index.theme; then
          gtk-update-icon-cache --quiet $dir
        fi
      done
    - gtk-query-immodules-3.0 --update-cache
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgailutil-3.so'
        - '%{libdir}/libgdk-3.so'
        - '%{libdir}/libgtk-3.so'
  cpe:
    product: gtk+
