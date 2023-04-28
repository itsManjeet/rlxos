kind: meson

sources:
- kind: tar
  url: gnome_downloads:rygel/0.42/rygel-0.42.3.tar.xz
  ref: 0fdec2128537e8b55c3c540d0a80dc7c249ab29153f4be0197a5f31025a5a5a0
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
