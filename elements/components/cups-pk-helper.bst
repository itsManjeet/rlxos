kind: meson

sources:
- kind: tar
  url: freedesktop_software:cups-pk-helper/releases/cups-pk-helper-0.2.7.tar.xz
  ref: 66070ddb448fe9fcee76aa26be2ede5a80f85563e3a4afd59d2bfd79fbe2e831
- kind: local
  path: files/cups-pk-helper/cups-pk-helper.service

build-depends:
- components/glib.bst
- components/intltool.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/polkit.bst

config:
  install-commands:
    (>):
    - |
      cat <<EOF >>"%{install-root}%{datadir}/dbus-1/system-services/org.opensuse.CupsPkHelper.Mechanism.service"
      SystemdService=cups-pk-helper.service
      EOF

    - |
      systemdsystemunitdir="$(pkg-config --variable systemdsystemunitdir systemd)"
      install -Dm644 -t "%{install-root}${systemdsystemunitdir}" cups-pk-helper.service
