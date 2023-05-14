kind: manual

# Thanks to carbon OS
# https://gitlab.com/carbonOS/build-meta/-/blob/main/elements/pkgs/nvidia/userspace.bst
build-depends:
  - proprietary/nvidia/source.bst
  - freedesktop-sdk.bst:bootstrap-import.bst
  - components/linux.bst
  - freedesktop-sdk.bst:components/zstd.bst
  - freedesktop-sdk.bst:components/openssl.bst
  - freedesktop-sdk.bst:components/pkg-config.bst
  - freedesktop-sdk.bst:components/systemd.bst

config:
  configure-commands:
  - cp /nvidia/kernel/* . -a
  build-commands:
  - |
    NVIDIAVER=$(cat /nvidia/nvidiaver)
    KERNEL_VERSION=$(make -sC %{prefix}/src/linux kernelrelease)
    MODDIR=%{indep-libdir}/modules/${KERNEL_VERSION}
    make KERNEL_UNAME=$KERNEL_VERSION KERNEL_MODLIB=$MODDIR KERNEL_SOURCES=%{prefix}/src/linux modules

  install-commands:
  - |
    NVIDIAVER=$(cat /nvidia/nvidiaver)
    KERNEL_VERSION=$(make -sC %{prefix}/src/linux kernelrelease)
    MODDIR=%{indep-libdir}/modules/${KERNEL_VERSION}

    make modules_install INSTALL_MOD_PATH=%{install-root}%{prefix} KERNEL_UNAME=$KERNEL_VERSION KERNEL_MODLIB=$MODDIR KERNEL_SOURCES=%{prefix}/src/linux

  - |
    NVIDIAVER=$(cat /nvidia/nvidiaver)

    install -Dm644 nvidia.rules %{install-root}%{indep-libdir}/udev/rules.d/60-nvidia.rules
    install -Dm644 blacklist-nouveau.conf %{install-root}%{indep-libdir}/modprobe.d/blacklist-nouveau.conf
    install -Dm644 nvidia-modeset.conf %{install-root}%{indep-libdir}/modprobe.d/nvidia-modeset.conf
    install -Dm644 load-nvidia.conf %{install-root}%{indep-libdir}/modules-load.d/nvidia.conf

    # json/icd
    install -Dm644 /nvidia/10_nvidia_wayland.json %{install-root}%{datadir}/egl/egl_external_platform.d/10_nvidia_wayland.json
    install -Dm644 /nvidia/10_nvidia.json %{install-root}%{datadir}/glvnd/egl_vendor.d/10_nvidia.json
    install -Dm644 /nvidia/15_nvidia_gbm.json %{install-root}%{datadir}/egl/egl_external_platform.d/15_nvidia_gbm.json
    install -Dm644 /nvidia/nvidia_icd.json %{install-root}%{datadir}/vulkan/icd.d/nvidia_icd.json
    install -Dm644 /nvidia/nvidia_layers.json %{install-root}%{datadir}/vulkan/implicit_layer.d/nvidia_layers.json


    # lib
    install -Dm755 /nvidia/libcuda* -t %{install-root}%{libdir}
    install -Dm755 /nvidia/lib*_nvidia* -t %{install-root}%{libdir}
    install -Dm755 /nvidia/libnv* -t %{install-root}%{libdir}
    rm -f %{install-root}%{libdir}/libnvidia-opencl*
    rm -f %{install-root}%{libdir}/libnvoptix*


    # bin
    install -Dm4755 /nvidia/nvidia-modprobe %{install-root}%{bindir}/nvidia-modprobe
    install -Dm755 /nvidia/nvidia-powerd %{install-root}%{bindir}/nvidia-powerd
    install -Dm755 /nvidia/nvidia-smi %{install-root}%{bindir}/nvidia-smi
    install -Dm755 /nvidia/nvidia-debugdump %{install-root}%{bindir}/nvidia-debugdump
    install -Dm755 /nvidia/nvidia-bug-report.sh %{install-root}%{bindir}/nvidia-bug-report.sh
    install -Dm755 /nvidia/nvidia-settings %{install-root}%{bindir}/nvidia-settings
    install -Dm755 /nvidia/systemd/nvidia-sleep.sh %{install-root}%{bindir}/nvidia-sleep.sh

    # firmware
    install -Dm644 /nvidia/firmware/gsp_{ga10x,tu10x}.bin -t %{install-root}%{indep-libdir}/firmware/nvidia/$NVIDIAVER/
    
    # systemd
    unitdir="$(pkg-config --variable=systemduserunitdir systemd)"
    presetdir="$(pkg-config --variable=systemduserpresetdir systemd)"
    
    install -Dm644 /nvidia/systemd/system/*.service -t %{install-root}${unitdir}
    install -Dm644 nvidia.preset -t %{install-root}${presetdir}

    # desktop
    install -Dm644 /nvidia/nvidia-settings.desktop %{install-root}/%{datadir}/applications/nvidia-settings.desktop
    sed -i 's#__UTILS_PATH__#%{bindir}#g' %{install-root}/%{datadir}/applications/nvidia-settings.desktop
    sed -i 's#__PIXMAP_PATH__#%{datadir}/pixmaps#g' %{install-root}/%{datadir}/applications/nvidia-settings.desktop
    install -Dm644 /nvidia/nvidia-settings.png %{install-root}%{datadir}/pixmaps/nvidia-settings.png
    
    # symlink fixes
    mkdir -pv %{install-root}%{libdir}/gbm
    ln -sr %{install-root}%{libdir}/libnvidia-allocator.so.$NVIDIAVER %{install-root}%{libdir}/gbm/nvidia-drm_gbm.so
    ln -s libnvidia-vulkan-producer.so.$NVIDIAVER %{install-root}%{libdir}/libnvidia-vulkan-producer.so.1
    ln -s libnvidia-vulkan-producer.so.$NVIDIAVER %{install-root}%{libdir}/libnvidia-vulkan-producer.so

sources:
- kind: local
  path: files/nvidia