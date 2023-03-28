kind: autotools

sources:
- kind: tar
  url: github_files:espeak-ng/espeak-ng/releases/download/1.50/espeak-ng-1.50.tgz

  ref: 80ee6cd06fcd61888951ab49362b400e80dd1fac352a8b1131d90cfe8a210edb
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
