kind: manual

# Thanks to carbon OS
# https://gitlab.com/carbonOS/build-meta/-/blob/main/elements/pkgs/nvidia/userspace.bst
build-depends:
  - proprietary/nvidia/source.bst
  - freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - |
    NVIDIAVER=$(cat /nvidia/nvidiaver)
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
    # firmware
    install -Dm644 /nvidia/firmware/gsp_{ad10x,tu10x}.bin -t %{install-root}%{indep-libdir}/firmware/nvidia/$NVIDIAVER/
    # systemd
    install -Dm644 /nvidia/systemd/system/*.service -t %{install-root}%{indep-libdir}/systemd/system
    install -Dm755 /nvidia/systemd/system-sleep/nvidia %{install-root}%{indep-libdir}/systemd/system-sleep/nvidia
    install -Dm755 /nvidia/systemd/nvidia-sleep.sh %{install-root}%{indep-libdir}/systemd/nvidia-sleep.sh
    # symlink fixes
    mkdir -pv %{install-root}%{libdir}/gbm
    ln -sr %{install-root}%{libdir}/libnvidia-allocator.so.$NVIDIAVER %{install-root}%{libdir}/gbm/nvidia-drm_gbm.so
    ln -s libnvidia-vulkan-producer.so.$NVIDIAVER %{install-root}%{libdir}/libnvidia-vulkan-producer.so.1
    ln -s libnvidia-vulkan-producer.so.$NVIDIAVER %{install-root}%{libdir}/libnvidia-vulkan-producer.so
