kind: autotools

sources:
- kind: tar
  url: github_files:ibus/ibus/releases/download/1.5.28/ibus-1.5.28.tar.gz

  ref: 6c9ff3a7576c3d61264f386030f47ee467eb7298c8104367002986e008765667
build-depends:
- components/vala.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:components/systemd.bst
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
    --enable-systemd

public:
  bst:
    split-rules:
      libibus:
      - '%{includedir}/**'
      - '%{libdir}/**'
      - '%{datadir}/gir-1.0/**'
      - '%{datadir}/vala/vapi/**'
