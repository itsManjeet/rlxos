kind: meson

sources:
- kind: tar
  url: gnome_downloads:glib/2.76/glib-2.76.2.tar.xz
  ref: 24f3847857b1d8674cdb0389a36edec0f13c666cd3ce727ecd340eb9da8aca9e

build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- freedesktop-sdk.bst:components/glib.bst

depends:
- components/sysprof-minimal.bst
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:components/util-linux.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgtk_doc=true
    -Dinstalled_tests=true
    -Dselinux=disabled
    -Dsysprof=enabled

public:
  bst:
    integration-commands:
    - glib-compile-schemas %{prefix}/share/glib-2.0/schemas
    - |
      if [ -d "%{libdir}/gio/modules" ]; then
        gio-querymodules "%{libdir}/gio/modules"
      fi
    - |
      for lib in gio glib gmodule gobject gthread; do
        fulllib="%{libdir}/lib${lib}-2.0.so.0"
        keep="$(readlink "${fulllib}")"
        for i in "${fulllib}".*; do
          if [ "$(basename "${i}")" != "${keep}" ]; then
            rm "${i}"
          fi
        done
      done
    # remove this once freedesktop-sdk updates to 2.66
    - rm -f /usr/include/glib-2.0/glib/gurifuncs.h
    overlap-whitelist:
    - '**'
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgio-2.0.so'
        - '%{libdir}/libglib-2.0.so'
        - '%{libdir}/libgmodule-2.0.so'
        - '%{libdir}/libgobject-2.0.so'
        - '%{libdir}/libgthread-2.0.so'
