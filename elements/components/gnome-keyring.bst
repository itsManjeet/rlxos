kind: autotools
sources:
- kind: tar
  url: gnome_downloads:gnome-keyring/42/gnome-keyring-42.1.tar.xz
  ref: c7f4d040cc76a6b7fe67e08ef9106911c3c80d40fc88cbfc8e2684a4c946e3e6
build-depends:
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/gcr-3.bst
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/openssh.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: --with-pam-dir=%{libdir}/security
