kind: autotools
sources:
- kind: tar
  url: ftp_gnu_org:mpc/mpc-1.3.1.tar.gz
  ref: ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:components/mpfr.bst
- freedesktop-sdk.bst:bootstrap-import.bst
