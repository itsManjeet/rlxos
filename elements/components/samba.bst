kind: autotools

sources:
- kind: tar
  url: samba:samba/stable/samba-4.17.4.tar.gz
  ref: c0512079db4cac707ccea4c18aebbd6b2eb3acf6e90735e7f645a326be1f4537
- kind: patch
  path: patches/samba/fix-root-build.patch

build-depends:
- components/perl-parse-yapp.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/python3.bst

depends:
- components/openldap.bst
- components/rpcsvc-proto.bst
- components/krb5.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  # not a real autotools project
  conf-global: --host=%{triplet} --build=%{triplet}
  conf-local: >-
    --enable-fhs
    --without-ad-dc
    --without-json
    --with-system-mitkrb5

config:
  install-commands:
    (>):
    - mv %{install-root}/var/run %{install-root}
