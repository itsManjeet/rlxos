kind: autotools

sources:
- kind: tar
  url: gitlab_files:sane-project/backends/uploads/104f09c07d35519cc8e72e604f11643f/sane-backends-1.0.32.tar.gz

  ref: 3a28c237c0a72767086202379f6dc92dbb63ec08dfbab22312cba80e238bb114
build-depends:
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
    (>):
    - install -Dm 644 tools/udev/libsane.rules %{install-root}$(pkg-config --variable=udevdir
      udev)/rules.d/60-libsane.rules
