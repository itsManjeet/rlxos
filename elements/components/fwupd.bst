kind: meson

sources:
- kind: tar
  url: github_files:fwupd/fwupd/releases/download/1.8.5/fwupd-1.8.5.tar.xz
  ref: 33e9d788f65d18259be619bb379708519a349014cb7f3467f42c55fae3522612

build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- components/gi-docgen.bst
- freedesktop-sdk.bst:components/cmake.bst
- freedesktop-sdk.bst:components/help2man.bst
- freedesktop-sdk.bst:components/liberation-fonts.bst
# Needed for docs/test-deps.py
- freedesktop-sdk.bst:components/python3-packaging.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libjcat.bst
- components/xmlb.bst
- components/protobuf-c.bst
- components/gcab.bst
- components/glib.bst
- components/pango.bst
- components/pygobject.bst
- freedesktop-sdk.bst:components/bluez-libs.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/efivar.bst
- freedesktop-sdk.bst:components/genpeimg.bst
- freedesktop-sdk.bst:components/harfbuzz.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libsmbios-maybe.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/pycairo.bst
- freedesktop-sdk.bst:components/python3-pil.bst
- freedesktop-sdk.bst:components/tpm2-tss.bst
- freedesktop-sdk.bst:components/gnu-efi-maybe.bst

(?):
- arch in ["arm", "aarch64", "x86_64", "i686", "riscv64"]:
    depends:
      (>):
      - components/fwupd-efi.bst

variables:
  meson-local: >-
    -Dcurl=enabled
    -Ddocs=enabled
    -Dintrospection=enabled
    -Dgudev=enabled
    -Dgusb=enabled
    -Dbluez=enabled
    -Dpolkit=enabled
    -Dsystemd=enabled
    -Dsoup_session_compat=false
    -Dplugin_intel_spi=%{plugin_intel_spi}
    -Dplugin_dell=%{plugin_dell}
    -Dplugin_msr=%{plugin_msr}
    -Dplugin_flashrom=disabled
    -Dplugin_uefi_capsule=%{plugin_uefi_capsule}
    -Defi_binary=%{efi_binary}
    -Dplugin_modem_manager=disabled

  plugin_dell: 'false'
  plugin_msr: 'false'
  plugin_uefi_capsule: 'false'
  plugin_intel_spi: 'false'
  efi_binary: 'false'
  (?):
  - arch in ["arm", "aarch64"]:
      plugin_uefi_capsule: 'true'
      efi_binary: 'true'
  - arch in ["i686", "x86_64"]:
      plugin_dell: 'true'
      plugin_msr: 'true'
      plugin_uefi_capsule: 'true'
      plugin_intel_spi: 'true'
      efi_binary: 'true'
      
