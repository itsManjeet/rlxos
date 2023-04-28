kind: autotools

sources:
- kind: tar
  url: github_files:espeak-ng/espeak-ng/archive/1.51.1/espeak-ng-1.51.1.tar.gz

  ref: 0823df5648659dcb67915baaf99118dcc8853639f47cadaa029c174bdd768d20
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  notparallel: true

config:
  configure-commands:
    (<):
    # force autogen
    - rm -f configure

  build-commands:
    (>):
    - make src/espeak-ng src/speak-ng
