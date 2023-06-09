kind: cmake

sources:
- kind: tar
  url: gnome_downloads:evolution-data-server/3.48/evolution-data-server-3.48.2.tar.xz
  ref: 1f3243df12b4f1d3298c9977d6221a6565fd279efc984e1ccf255245d04cffd5
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
- components/webkitgtk-6.0.bst
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
