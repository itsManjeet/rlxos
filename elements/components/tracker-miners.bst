kind: meson
sources:
- kind: tar
  url: gnome_downloads:tracker-miners/3.6/tracker-miners-3.6.0.tar.xz
  ref: c2ed9f6b0410195863b84c7b5467c5bc1255e96d658741192b5e92568a3bebd0
build-depends:
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/networkmanager.bst
- components/dconf.bst
- components/exempi.bst
- components/gexiv2.bst
- components/libcue.bst
- components/libgsf.bst
- components/libgxps.bst
- components/libosinfo.bst
- components/totem-pl-parser.bst
- components/upower.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/libsecret.bst
- components/tracker.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-base.bst
- freedesktop-sdk.bst:components/libexif.bst
- freedesktop-sdk.bst:components/libflac.bst
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:components/openjpeg.bst
- freedesktop-sdk.bst:components/poppler.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Diptc=disabled
    -Dminer_rss=false
