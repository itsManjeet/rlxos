kind: autotools

sources:
- kind: tar
  url: github_files:flatpak/flatpak/releases/download/1.14.4/flatpak-1.14.4.tar.xz

  ref: 8a34dbd0b67c434e7598b98ec690953d046f0db26e480aeafb46d72aec716799
- kind: remote
  url: https://flathub.org/repo/flathub.flatpakrepo

  ref: 3371dd250e61d9e1633630073fefda153cd4426f72f4afa0c3373ae2e8fea03a

build-depends:
- components/python-pyparsing.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/git-minimal.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/appstream.bst
- components/libostree.bst
- components/bubblewrap.bst
- components/xdg-dbus-proxy.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/fuse.bst
- freedesktop-sdk.bst:components/gpgme.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/libcap.bst
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/xorg-lib-xau.bst
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/xdg-desktop-portal-gnome.bst
- components/xdg-desktop-portal-gtk.bst

variables:
  conf-local: >-
    --with-curl
    --with-system-bubblewrap
    --with-system-dbus-proxy

config:
  install-commands:
    (>):
    - install -Dm644 %{build-root}/flathub.flatpakrepo -t %{install-root}/%{sysconfdir}/flatpak/remotes.d/
