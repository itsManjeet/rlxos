kind: autotools

sources:
- kind: tar
  url: openldap:software/download/OpenLDAP/openldap-release/openldap-2.6.0.tgz

  ref: b71c580eac573e9aba15d95f33dd4dd08f2ed4f0d7fc09e08ad4be7ed1e41a4f
build-depends:
- freedesktop-sdk.bst:components/groff.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --disable-slapd
