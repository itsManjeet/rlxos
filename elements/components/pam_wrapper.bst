kind: cmake

sources:
- kind: git_tag
  url: https://git.samba.org/pam_wrapper.git
  track: pam_wrapper-1.1.4

  ref: pam_wrapper-1.1.4-0-gd938a84d88c5882a08babfb5e10f03a9135237a3
depends:
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/python3.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
