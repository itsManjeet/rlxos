kind: autotools

sources:
- kind: tar
  url: gnupg:ftp/gcrypt/pinentry/pinentry-1.2.1.tar.bz2

  ref: 457a185e5a85238fb945a955dc6352ab962dc8b48720b62fc9fa48c7540a4067
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/gcr-3.bst
- components/libsecret.bst
- freedesktop-sdk.bst:components/libgpg-error.bst
- freedesktop-sdk.bst:components/libassuan.bst

variables:
  conf-local: >-
    --enable-pinentry-gome
    --enable-fallback-curses
    --disable-pinentry-curses
    --disable-pinentry-qt
    --disable-pinentry-gtk2
    --disable-pinentry-fltk
    --enable-libsecret
