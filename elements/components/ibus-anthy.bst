kind: autotools

sources:
- kind: tar
  url: github_files:ibus/ibus-anthy/releases/download/1.5.12/ibus-anthy-1.5.12.tar.gz

  ref: e9e758ddd46ae292376eab171187fa8f20630f0a57cd128a41208fdcdfdf57bb
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/ibus-daemon.bst
- components/glib.bst
- components/pygobject.bst
- components/anthy.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --enable-private-png=yes
    --with-python=python3

config:
  configure-commands:
    (<):
    - rm {setup,engine}/python3/_config.py
