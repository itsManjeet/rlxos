kind: cmake

sources:
- kind: tar
  url: gnome_downloads:evolution-data-server/3.46/evolution-data-server-3.46.3.tar.xz
  ref: 0938e2279e5cfbc2204766ca9d3fea570911699b07c10cbe01aca62a7e8b2bee
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/gperf.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- components/gnome-online-accounts.bst
- components/libcanberra.bst
- components/libgweather.bst
- components/openldap.bst
- components/gcr.bst
- components/gtk+-3.bst
- components/libsecret.bst
- components/libsoup.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/libical.bst
- freedesktop-sdk.bst:components/nspr.bst
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  cmake-local: >-
    -DLIB_INSTALL_DIR=%{libdir}
    -DSYSCONF_INSTALL_DIR=%{sysconfdir}
    -DENABLE_INTROSPECTION=ON
    -DENABLE_VALA_BINDINGS=ON
    -DENABLE_UOA=OFF
    -DENABLE_GOOGLE_AUTH=OFF
    -DWITH_GWEATHER4=ON
    -DWITH_LIBDB=OFF
    -DENABLE_GOOGLE=OFF
    -DENABLE_OAUTH2_WEBKITGTK4=OFF
