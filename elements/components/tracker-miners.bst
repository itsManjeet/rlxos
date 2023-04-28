kind: meson
sources:
- kind: tar
  url: gnome_downloads:tracker-miners/3.5/tracker-miners-3.5.1.tar.xz
  ref: a18912edbd993abfe0236dfa6b81a4c72de1b8f5a4aee1cdbce3d8ef0a1ec8b8
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
