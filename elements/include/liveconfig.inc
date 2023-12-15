post-script: |-
  mkdir -p %{install-root}
  mksquashfs %{liveconfig}/usr %{install-root}/liveconfig.img

build-depends:
  - components/squashfs-tools.yml