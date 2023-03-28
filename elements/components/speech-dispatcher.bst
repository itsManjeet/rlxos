kind: autotools

sources:
- kind: tar
  url: github_files:brailcom/speechd/releases/download/0.11.0/speech-dispatcher-0.11.0.tar.gz

  ref: 254c4279c7637ee815c9daee99597d208681f811af5188051f0c2e11f2ec77c7
build-depends:
- freedesktop-sdk.bst:components/texinfo.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/dotconf.bst
- components/espeak-ng.bst
- components/glib.bst
- freedesktop-sdk.bst:components/libpulse.bst
- freedesktop-sdk.bst:components/sndfile.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --with-espeak-ng
    --with-pulse
    --with-oss=no

config:
  install-commands:
    (>):
    - rm '%{install-root}%{infodir}/dir'
