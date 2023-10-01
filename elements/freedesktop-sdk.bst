kind: junction
sources:
- kind: git_tag
  url: gitlab:freedesktop-sdk/freedesktop-sdk.git
  track: release/23.08
  track-tags: true
  ref: freedesktop-sdk-23.08.1-0-g82ccd27bb92aa3934f8c2ff62bbe46ae4af7adf4
config:
  options:
    target_arch: '%{arch}'
    (?):
    - arch in ('x86_64', 'i686'):
        bootstrap_build_arch: 'x86_64'
    - arch in ('aarch64', 'arm'):
        bootstrap_build_arch: 'aarch64'
    - arch == "ppc64le":
        bootstrap_build_arch: "ppc64le"
    - arch == "riscv64":
        bootstrap_build_arch: "x86_64"
  overrides:
    components/appstream-glib.bst: components/appstream-glib.bst
    components/at-spi2-core.bst: components/at-spi2-core.bst
    components/cairo.bst: components/cairo.bst
    components/fcitx5.bst: components/fcitx5-gtk.bst
    components/gcab.bst: components/gcab.bst
    components/gdk-pixbuf.bst: components/gdk-pixbuf.bst
    components/glib-networking.bst: components/glib-networking.bst
    components/glib.bst: components/glib.bst
    components/gobject-introspection.bst: components/gobject-introspection.bst
    components/graphene.bst: components/graphene.bst
    components/gsettings-desktop-schemas.bst: components/gsettings-desktop-schemas.bst
    components/gtk-doc.bst: components/gtk-doc.bst
    components/gtk3.bst: components/gtk+-3.bst
    components/ibus.bst: components/libibus.bst
    components/json-glib.bst: components/json-glib.bst
    components/librsvg.bst: components/librsvg.bst
    components/libsoup.bst: components/libsoup.bst
    components/pango.bst: components/pango.bst
    components/pygobject.bst: components/pygobject.bst
    components/vala.bst: components/vala.bst
    components/zenity.bst: components/zenity.bst
    components/xdg-desktop-portal-base.bst: components/xdg-desktop-portal.bst

