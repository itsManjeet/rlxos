kind: autotools
sources:
- kind: tar
  url: spice:releases/spice-server/spice-0.15.0.tar.bz2
  ref: b320cf8f4bd2852750acb703c15b72856027e5a8554f8217dfbb3cc09deba0f5
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/spice-protocol.bst
depends:
- components/libcacard.bst
- components/glib.bst
- freedesktop-sdk.bst:components/jpeg.bst
- freedesktop-sdk.bst:components/opus.bst
- freedesktop-sdk.bst:components/pixman.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --enable-smartcard
