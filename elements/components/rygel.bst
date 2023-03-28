kind: meson

sources:
- kind: tar
  url: gnome_downloads:rygel/0.42/rygel-0.42.0.tar.xz
  ref: 006da78677df28caee287c44c29fcd9edcb1b2162423bc7f2dd2dc856b8e2bbb
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
