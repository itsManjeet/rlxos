kind: meson

sources:
- kind: tar
  url: gnome_downloads:rygel/0.42/rygel-0.42.4.tar.xz
  ref: 6310dfaa2d332b66119b9b020fad6a4bd27d9bc61faf780ca5ca0b62813303f7
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gssdp.bst
- components/gst-editing-services.bst
- components/gupnp-av.bst
- components/gupnp-dlna.bst
- components/gupnp.bst
- components/libmediaart.bst
- components/libgee.bst
- components/tracker.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dplugins=external,gst-launch,lms,media-export,mpris,playbin,ruih,tracker3
