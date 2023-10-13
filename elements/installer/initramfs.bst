kind: script

build-depends:
  - installer/initramfs/deps.bst
  - installer/initramfs/initial-scripts.bst
  - freedesktop-sdk.bst:vm/prepare-image.bst

variables:
  uuidnamespace: aea54278-2587-4075-ae67-8688ace4ce3d
  install-root: /boot

  efi-arch: "%{arch}"
  (?):
    - arch == "x86_64":
        efi-arch: x64
    - arch == "i686":
        efi-arch: ia32

config:
  commands:
    - mkdir -p /tmp /var/tmp /boot
    - |
      prepare-image.sh \
         --seed "%{uuidnamespace}" \
         --rootsource LABEL="%{installer-volume-id}" \
         --rootfstype iso9660 \
         --noboot >/dev/null

    - |
      dracut -v --no-machineid \
             --kernel-image /boot/vmlinuz \
             --kver "$(ls -1 /usr/lib/modules | head -n1)" \
             --kernel-cmdline 'rw quiet splash root=live:LABEL=%{installer-volume-id} console=tty0 rd.live.overlay.overlayfs=1' \
             --add dmsquash-live \
             --add plymouth \
             --install grep \
             --install head \
             --install tail \
             --install less \
             --install lsof \
             --omit lvm

    - dbus-uuidgen >/etc/machine-id
    - SYSTEMD_ESP_PATH=/boot bootctl --no-variables install
    - rm /etc/machine-id

    - |
      cat <<EOF >/boot/loader/loader.conf
      timeout 3
      editor yes
      console-mode keep
      EOF

    - |
      rm -f /boot/System.map

    - |
      cat <<EOF >/boot/loader/entries/rlxos-installer.conf
      title RLXOS Installer
      version 1
      options rw quiet splash root=live:LABEL=%{installer-volume-id} console=tty0
      linux /vmlinuz
      initrd /initramfs-$(ls -1 /lib/modules | head -n1).img
      EOF
