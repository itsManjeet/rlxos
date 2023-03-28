kind: meson

sources:
- kind: tar
  url: gnome_downloads:glib/2.74/glib-2.74.4.tar.xz
  ref: 0e82da5ea129b4444227c7e4a9e598f7288d1994bf63f129c44b90cfd2432172
- kind: patch
  path: patches/glib/6626765a79f125cf0ec9cdaefa51ceef718d41e7.patch

build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
# a dummy dependency so our glib is always staged
# on top of freedesktop-sdk version
- freedesktop-sdk.bst:components/glib.bst

depends:
# sysprof-capture-4 ends up in Requires.private
# so we either could have added sysprof-minimal
# as a builddep to everything that depends on it
# and its downstream users, or make it a runtime
# dependency of glib and have it be always available
# transiently.
#
# Ideally, sysprof-minimal would be just a build dep
# of modules, since its already statically linked.
# https://github.com/mesonbuild/meson/issues/3970
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
