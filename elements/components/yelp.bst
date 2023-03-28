kind: autotools

sources:
- kind: tar
  url: gnome_downloads:yelp/42/yelp-42.2.tar.xz
  ref: a2c5fd0787a9089c722cc66bd0f85cdf7088d870e7b6cc85799f8e5bff9eac4b
build-depends:
- components/appstream-glib.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/webkit2gtk-4.1.bst
- components/yelp-xsl.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:bootstrap-import.bst

public:
  bst:
    integration-commands:
    - |
      update-desktop-database
    split-rules:
      devel:
        (>):
        - '%{libdir}/libyelp.so'
