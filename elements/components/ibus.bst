kind: autotools

sources:
- kind: tar
  url: github_files:ibus/ibus/releases/download/1.5.25/ibus-1.5.25.tar.gz

  ref: dea4f663c485267cc3313e40a0bc89b977c397e19644f8ab41df0e6eaec34330
build-depends:
- components/vala.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/dconf.bst
- components/glib.bst
- components/gtk+-3.bst
- components/gtk.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --enable-dconf
    --enable-memconf
    --disable-appindicator
    --disable-emoji-dict
    --enable-engine
    --disable-tests
    --disable-gconf
    --disable-gtk2
    --disable-gtk-doc
    --disable-glibtest
    --disable-libnotify
    --disable-python2
    --disable-schema-compile
    --disable-static
    --disable-setup
    --disable-ui
    --disable-unicode-dict
    --with-python=python3
    --enable-wayland
    --enable-introspection
    --enable-vala
    --enable-gtk4

public:
  bst:
    split-rules:
      libibus:
      - '%{includedir}/**'
      - '%{libdir}/**'
      - '%{datadir}/gir-1.0/**'
      - '%{datadir}/vala/vapi/**'
