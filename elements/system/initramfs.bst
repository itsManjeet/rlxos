kind: script

build-depends:
- system/initramfs/deps.bst
- system/initramfs/initial-scripts.bst
- freedesktop-sdk.bst:vm/prepare-image.bst

variables:
  uuidnamespace: aea54278-2587-4075-ae67-8688ace4ce3d

config:
  layout:
  - element: ''
    destination: '/tmp'
  - element: ''
    destination: '/efi'
  - element: ''
    destination: '/var/tmp'
  - element: system/initramfs/deps.bst
    destination: '/'
  - element: system/initramfs/initial-scripts.bst
    destination: '/'
  - element: vm/prepare-image.bst
    destination: '/'

  commands:
  - |
    prepare-image.sh \
       --seed "%{uuidnamespace}" \
       --rootsource /dev/gpt-auto-root \
       --efisource LABEL=EFI \
       --efipath /boot >/dev/null

  - |
    mkdir -p "%{install-root}/usr/lib/"
    cp -r /usr/lib/modules "%{install-root}/usr/lib/"

  - |
    version="$(ls -1 /lib/modules | head -n1)"
    mkdir -p "%{install-root}/usr/lib/modules/${version}"
    dracut -v --fstab \
           --no-machineid \
           --kver "${version}" \
           --add ostree \
           --add plymouth \
           --install 'fsck.ext4' \
           "%{install-root}/usr/lib/modules/${version}/initramfs"

  - |
    version="$(ls -1 /lib/modules | head -n1)"
    cp /boot/vmlinuz "%{install-root}/usr/lib/modules/${version}/vmlinuz"

  - dbus-uuidgen >/etc/machine-id
  - SYSTEMD_RELAX_ESP_CHECKS=1 bootctl --path='/efi' --no-variables install
  - rm /etc/machine-id

  - |
    cp -r /efi "%{install-root}/boot"

  - |
    cat <<EOF >%{install-root}/boot/loader/loader.conf
    timeout 3
    editor yes
    console-mode keep
    EOF
