kind: meson

sources:
- kind: tar
  url: freedesktop:libfprint/fprintd/-/archive/v1.94.2/fprintd-v1.94.2.tar.gz

  ref: 79f422378162be60935ec4ecd14e845e297d36b62385659721319bb514d23e77
depends:
- components/libfprint.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/linux-pam.bst

build-depends:
- components/pam_wrapper.bst
- freedesktop-sdk.bst:components/patch.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

variables:
  meson-local: >-
    -Dpam_modules_dir=%{libdir}/security
    -Dman=false

config:
  configure-commands:
    (<):
    - |
      sed -i '/required by test suite not found/s/error/warning/' meson.build
      sed -i "/pam_wrapper_dep/s/get_option('pam')/false/" meson.build
      sed -i "/subdir('tests')/d" meson.build
      sed -i '/address_sanitizer/d' meson.build
