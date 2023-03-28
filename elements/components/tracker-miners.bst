kind: meson
sources:
- kind: tar
  url: gnome_downloads:tracker-miners/3.4/tracker-miners-3.4.2.tar.xz
  ref: 101e3608f1c28bfed8ae25522f7a720b559f889a76e280afbe50a4d8b064f92c
build-depends:
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/networkmanager.bst
- components/dconf.bst
- components/gexiv2.bst
- components/libcue.bst
- components/libgsf.bst
- components/libgxps.bst
- components/libosinfo.bst
- components/totem-pl-parser.bst
- components/upower.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gst-plugins-base.bst
- components/libsecret.bst
- components/tracker.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/libexif.bst
- freedesktop-sdk.bst:components/libflac.bst
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:components/openjpeg.bst
- freedesktop-sdk.bst:components/poppler.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dxmp=disabled
    -Diptc=disabled
    -Dminer_rss=false
    -Dtiff=disabled
    -Dgif=disabled
