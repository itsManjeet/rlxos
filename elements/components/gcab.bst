kind: meson
sources:
- kind: tar
  url: gnome_downloads:gcab/1.5/gcab-1.5.tar.xz
  ref: 46bf7442491faa4148242b9ec2a0786a5f6e9effb1b0566e5290e8cc86f00f0c
- kind: patch
  path: patches/gcab/ad0baea50359c1978a9224ee60bf98d97bfb991f.patch
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgcab-1.0.so'
