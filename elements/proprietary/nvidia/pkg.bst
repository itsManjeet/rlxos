kind: manual

build-depends:
  - proprietary/nvidia/source.bst
  - freedesktop-sdk.bst:bootstrap-import.bst
  - components/linux.bst
  - freedesktop-sdk.bst:components/zstd.bst
  - freedesktop-sdk.bst:components/openssl.bst
  - freedesktop-sdk.bst:components/pkg-config.bst
  - freedesktop-sdk.bst:components/systemd.bst
  - freedesktop-sdk.bst:components/patchelf.bst

config:
  configure-commands:
  - cp -a /nvidia/* .
  build-commands:
  - |
    cd kernel/
    NVIDIAVER=$(cat /nvidia/nvidiaver)
    KERNEL_VERSION=$(make -sC %{prefix}/src/linux kernelrelease)
    MODDIR=%{indep-libdir}/modules/${KERNEL_VERSION}
    make KERNEL_UNAME=$KERNEL_VERSION KERNEL_MODLIB=$MODDIR KERNEL_SOURCES=%{prefix}/src/linux modules

  install-commands:
  - |
    cd kernel/
    NVIDIAVER=$(cat /nvidia/nvidiaver)
    KERNEL_VERSION=$(make -sC %{prefix}/src/linux kernelrelease)
    MODDIR=%{indep-libdir}/modules/${KERNEL_VERSION}

    make modules_install INSTALL_MOD_PATH=%{install-root}%{prefix} KERNEL_UNAME=$KERNEL_VERSION KERNEL_MODLIB=$MODDIR KERNEL_SOURCES=%{prefix}/src/linux

  - |
    NVIDIAVER=$(cat nvidiaver)

    # Wayland/GBM
    install -Dm755 -t %{install-root}%{libdir} libnvidia-egl-gbm.so.1*
    install -Dm644 -t %{install-root}%{datadir}/egl/egl_external_platform.d/ 15_nvidia_gbm.json
    mkdir -p %{install-root}%{indep-libdir}/gbm
    ln -sr %{install-root}%{libdir}/libnvidia-allocator.so.${NVIDIAVER} %{install-root}%{indep-libdir}/gbm/nvidia-drm_gbm.so

    # Firmware
    install -Dm644 -t %{install-root}%{indep-libdir}/firmware/nvidia/${NVIDIAVER}/ firmware/*.bin

    # OpenGL libraries
    for lib in EGL GLESv1_CM GLESv2 ; do
      install -Dm755 -t %{install-root}%{libdir} lib${lib}_nvidia.so.${NVIDIAVER}
    done

    for lib in glcore eglcore glsi \
              fbc encode cfg ml \
              glvkspirv allocator vulkan-producer; do
      install -Dm755 -t %{install-root}%{libdir} libnvidia-${lib}.so.${NVIDIAVER}
    done
    install -Dm755 -t %{install-root}%{libdir} libnvidia-api.so.1
    install -Dm644 -t %{install-root}%{datadir}/glvnd/egl_vendor.d 10_nvidia.json
    patchelf --set-soname "libnvidia-vulkan-producer.so.1" %{install-root}/%{libdir}/libnvidia-vulkan-producer.so.${NVIDIAVER}

    # Vulkan ICD
    install -Dm644 -t %{install-root}%{datadir}/vulkan/icd.d nvidia_icd.json
    install -Dm644 -t %{install-root}%{datadir}/vulkan/implicit_layer.d nvidia_layers.json

    # VDPAU
    install -Dm755 -t %{install-root}%{libdir}/vdpau libvdpau_nvidia.so.${NVIDIAVER}

    # Nvidia-tls library
    install -Dm755 libnvidia-tls.so.${NVIDIAVER} -t %{install-root}%{libdir}/libnvidia-tls.so.${NVIDIAVER}

    # CUDA
    for lib in cuda nvcuvid cudadebugger \
              nvidia-nvvm nvidia-ptxjitcompiler \
              nvoptix nvidia-rtcore \
              nvidia-ngx nvidia-opticalflow; do
      install -Dm755 -t %{install-root}%{libdir} lib${lib}.so.${NVIDIAVER}
    done

    install -Dm755 -t %{install-root}%{bindir}/ nvidia-ngx-updater
    install -Dm755 _nvngx.dll -t %{install-root}%{indep-libdir}/nvidia/wine/
    install -Dm755 nvngx.dll -t %{install-root}%{indep-libdir}/nvidia/wine/


    # OpenCL
    install -Dm644 -t %{install-root}%{sysconfdir}/OpenCL/vendors nvidia.icd
    install -Dm755 -t %{install-root}%{libdir} libnvidia-compiler.so.${NVIDIAVER}
    install -Dm755 -t %{install-root}%{libdir} libnvidia-opencl.so.${NVIDIAVER}

    # Debug
    for bin in nvidia-debugdump \
              nvidia-bug-report.sh nvidia-smi \
              nvidia-cuda-mps-server \
              nvidia-cuda-mps-control nvidia-modprobe \
              nvidia-persistenced ; do
      install -Dm755 ${bin} -t %{install-root}%{bindir}
    done

    for _man in nvidia-smi \
              nvidia-cuda-mps-control \
              nvidia-modprobe \
              nvidia-persistenced ; do
      install -Dm644 ${_man}.1.gz -t %{install-root}%{datadir}/man/man1/
    done

    unitdir="$(pkg-config --variable=systemdsystemunitdir systemd)"
    install -Dm644 nvidia-persistenced-init/systemd/nvidia-persistenced.service.template %{install-root}${unitdir}/nvidia-persistenced.service
    sed -i 's/__USER__/nvidia-persistenced/' %{install-root}${unitdir}/nvidia-persistenced.service

    # Application profiles
    install -Dm644 nvidia-application-profiles-${NVIDIAVER}-rc -t %{install-root}%{datadir}/nvidia/
    install -Dm644 nvidia-application-profiles-${NVIDIAVER}-key-documentation -t %{install-root}%{datadir}/nvidia/

    # New power management support
    install -Dm644 systemd/system/*.service -t %{install-root}${unitdir}
    install -Dm755 systemd/system-sleep/nvidia -t %{install-root}%{indep-libdir}/systemd/system-sleep/
    install -Dm755 systemd/nvidia-sleep.sh -t %{install-root}%{bindir}/
    install -Dm755 nvidia-powerd -t %{install-root}%{bindir}
    install -Dm644 nvidia-dbus.conf -t %{install-root}%{datadir}/dbus-1/system.d/

    install -Dm644 nvidia.sysusers  %{install-root}%{indep-libdir}/sysusers.d/nvidia.conf
    install -Dm644 nvidia.rules %{install-root}/%{indep-libdir}/udev/rules.d/60-nvidia.rules

    mkdir -p %{install-root}%{indep-libdir}/modprobe.d/ %{install-root}%{indep-libdir}/modules-load.d/
    echo "blacklist nouveau" > %{install-root}%{indep-libdir}/modprobe.d/nvidia.conf
    echo "nvidia-uvm" > %{install-root}%{indep-libdir}/modules-load.d/nvidia.conf

    find "%{install-root}" -type f -name '*.so*' ! -path '*xorg/*' -print0 | while read -d $'\0' _lib; do
        _soname=$(dirname "${_lib}")/$(readelf -d "${_lib}" | grep -Po 'SONAME.*: \[\K[^]]*' || true)
        _base=$(echo ${_soname} | sed -r 's/(.*)\.so.*/\1.so/')
        [[ -e "${_soname}" ]] || ln -s $(basename "${_lib}") "${_soname}"
        [[ -e "${_base}" ]] || ln -s $(basename "${_soname}") "${_base}"
    done

sources:
- kind: local
  path: files/nvidia