#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

echo ":: starting container ${VERSION} ::"
. ${BASEDIR}/common.sh

ARGS=()
PROFILE='desktop'
BUILD_ID=$(date +"%m%d%y%H%M")
DEPENDS_FILE='/tmp/depends'
export PKGUPD_NO_PROGRESS=1

function bootstrap() {
  echo ":: bootstraping toolchain ::"
  for i in kernel-headers glibc binutils gcc binutils glibc ; do
    echo ":: compiling toolchain - ${i} ::"
    NO_DEPENDS=1 pkgupd co ${i} --force
    if [[ $? != 0 ]] ; then
        echo ":: ERROR :: failed to build toolchain ${i}"
        exit 1
    fi
  done

  echo ":: bootstrapping success ::"
}

function rebuild() {
  echo ":: rebuilding packages ::"
  for pkg in ${PKGS} ; do
    if [[ -e /logs/${pkg}.log ]] ; then
      case ${pkg} in
        libgcc|gcc|libllvm|llvm|libboost|boost)
          continue
      esac
    fi
    if [[ -n ${CONTINUE_BUILD} ]] && [[ -e /logs/${pkg}.log ]] ; then
      pkgupd in ${pkg} --no-depends --force
      if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to install ${pkg}"
        mv /logs/${pkg}.{log,failed}
        exit 1
      fi
    else
      echo ":: compiling ${pkg}"
      NO_DEPENDS=1 pkgupd co ${pkg} --force 2>&1 | sed -r 's/\x1b\[[0-9;]*m//g' | tee /logs/${pkg}.log
      if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to build ${pkg}"
        mv /logs/${pkg}.{log,failed}
        exit 1
      fi
    fi
    case ${pkg} in
      libgcc|gcc)
        touch /logs/libgcc.log
        touch /logs/gcc.log
        ;;

      libllvm|llvm)
        touch /logs/libllvm.log
        touch /logs/llvm.log
        ;;

      libboost|boost)
        touch /logs/boost.log
        touch /logs/libboost.log
        ;;
    esac
    [[ -e /logs/${pkg}.failed ]] && rm /logs/${pkg}.failed
  done
  
  echo ":: rebuilding success ::"
}

function generating_rootfs() {
    temp_config=$(mktemp /tmp/pkgupd.XXXXXX)
    echo "RootDir: ${ROOTFS}
SystemDatabase: ${ROOTFS}/var/lib/pkgupd/data" > ${temp_config}
    pkgupd in ${@} --config ${temp_config} --no-ask --no-triggers
    ret=${?}
    rm ${temp_config}
    
    return ${ret}
}

function generate_iso() {
  echo ":: generating iso ::"
  TEMPDIR=$(mktemp -d)

  echo ":: install required tools ::"
  pkgupd in grub-i386 grub squashfs-tools lvm2 initramfs mtools linux --no-ask
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to install required tools"
    exit 1
  fi

  echo ":: generating rootfs ::"
  ROOTFS=${TEMPDIR}
  generating_rootfs ${PKGS}  
  if [[ $? != 0 ]] ; then
    rm -rf ${TEMPDIR}
    echo ":: ERROR :: failed to generate rootfilesystem"
    exit 1
  fi

  chroot ${ROOTFS} bash -e << "EOT"
pwconv
grpconv

# executing pkgupd triggers
pkgupd trigger

# settings up default root password
echo -e "rlxos\nrlxos" | passwd

# set default localtime
ln -sfv /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# setting up hostname
echo 'workstation' > /etc/hostname
EOT
  if [[ $? != 0 ]] ; then
    rm -rf ${TEMPDIR}
    echo ":: ERROR :: failed to execute essentails"
    exit 1
  fi

  if [[ -e /profiles/${VERSION}/${PROFILE}/script ]] ; then    
    echo ":: patching root filesystem ::"
    SCRIPT=$(cat /profiles/${VERSION}/${PROFILE}/script)
    chroot ${ROOTFS} bash -ec "${SCRIPT}"
    if [[ ${?} != 0 ]] ; then
      rm -rf ${TEMPDIR}
      echo ":: ERROR :: failed to execute pre patch script"
      exit 1
    fi
  fi

  echo ":: compressing system ::"
  mksquashfs ${TEMPDIR} /releases/rlxos-${VERSION}-${BUILD_ID}.sfs -comp zstd -Xcompression-level 22
  ret=${?}
  rm -rf ${TEMPDIR}

  if [[ ${ret} != 0 ]] ; then
    echo ":: ERROR :: failed to compress rootfilesystem"
    exit 1
  fi

  ISODIR=$(mktemp -d)
  TEMPDIR=$(mktemp -d)

  mkdir -p ${ISODIR}/boot/grub

  echo ":: installing rootfs.img"
  cp /releases/rlxos-${VERSION}-${BUILD_ID}.sfs ${ISODIR}/rootfs.img

  KERNEL_VERSION=$(pkgupd info linux | grep version: | awk '{print $2}')
  if [[ $? != 0 ]] || [[ -z ${KERNEL_VERSION} ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to get kernel version"
    exit 1
  fi

  PKGUPD_CONFIG=$(mktemp)
  echo "Version: ${VERSION}
SystemDatabase: /tmp
RootDir: ${ISODIR}" > ${PKGUPD_CONFIG}
  pkgupd install --config ${PKGUPD_CONFIG} linux --force --no-depends
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR} ${PKGUPD_CONFIG}
    echo ":: ERROR :: failed to calculate dependency tree"
    exit 1
  fi
  rm ${PKGUPD_CONFIG}

  # TODO: temporary fix, to be done in linux package itself
  mv ${ISODIR}/boot/vmlinuz ${ISODIR}/boot/vmlinuz-${KERNEL_VERSION}-rlxos && \
  mv ${ISODIR}/usr/lib/modules ${ISODIR}/boot/ && \
  rm -rf ${ISODIR}/usr/lib
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install linux kernel"
    exit 1
  fi

  echo ":: installing initrd kernel=${KERNEL_VERSION}-rlxos Modules=${ISODIR}/boot/modules"
  mkinitramfs -u -k=${KERNEL_VERSION}-rlxos -m=${ISODIR}/boot/modules -o=${ISODIR}/boot/initramfs-${KERNEL_VERSION}-rlxos
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install initramfs"
    exit 1
  fi

  echo "default='rlxos GNU/Linux [${VERSION}] Installer'
  timeout=5
  
  insmod all_video
  menuentry 'rlxos GNU/Linux [${VERSION}] Installer' {
    linux /boot/vmlinuz-${KERNEL_VERSION}-rlxos iso=1 root=LABEL=RLXOS system=${VERSION}
    initrd /boot/initramfs-${KERNEL_VERSION}-rlxos
  }" > ${ISODIR}/boot/grub/grub.cfg

  cp -a /profiles/${VERSION}/${PROFILE}/overlay ${TEMPDIR}/
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install iso overlay files"
    exit 1
  fi

  chown root:root ${TEMPDIR}/overlay -R
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to change overlay file permissions"
    exit 1
  fi

  ln -sv /run/iso/boot ${TEMPDIR}/overlay/boot
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to create boot symlink"
    exit 1
  fi

  mksquashfs ${TEMPDIR}/overlay/* ${ISODIR}/iso.img
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install overlay image"
    exit 1
  fi

  # Injecting release version
  echo "${VERSION}" > ${ISODIR}/version

  ISOFILE="/releases/rlxos-${PROFILE}-${VERSION}.iso"
  grub-mkrescue -volid RLXOS ${ISODIR} -o ${ISOFILE}
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install overlay image"
    exit 1
  fi

  md5sum ${ISOFILE} > ${ISOFILE}.md5

  echo ":: generating iso success ::"
}

function parse_args() {
  while [[ $# -gt 0 ]] ; do
    case "${1}" in
      --bootstrap)
        BOOTSTRAP=1
        ;;

      --rebuild)
        REBUILD=1
        ;;

      --iso)
        GENERATE_ISO=1
        ;;

      --profile)
        PROFILE=${2}
        shift
        ;;

      --build-id)
        BUILD_ID=${2}
        shift
        ;;

      --update-pkgupd)
        UPDATE_PKGUPD=1
        ;;
      
      --generate-docker-build)
        GENERATE_DOCKER_BUILD=1
        ;;

      --continue-build)
        CONTINUE_BUILD=1
        shift
        ;;

      --compile-all)
        COMPILE_ALL=1
        ;;

      -*|--*)
        echo ":: ERROR :: invalid option ${1}"
        exit 1
        ;;

      *)
        ARGS+=("${1}")
        ;;
    esac
    shift
  done
}

function update_pkgupd() {
  echo ":: updating PKGUPD"
  NO_DEPENDS=1 pkgupd co pkgupd --force
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to upgrade PKGUPD"
    exit 1
  fi
}

function continue_build() {
  echo ":: continuing build ::"

  [[ -n ${UPDATE_PKGUPD}  ]] && {
    echo ":: updating pkgupd ::"
    pkgupd in pkgupd --force --no-depends
    if [[ $? != 0 ]] ; then
      echo ":: ERROR :: failed to upgrade PKGUPD"
      exit 1
    fi

    echo ":: updating pkgupd success ::"
  }
  
  [[ -n ${BOOTSTRAP} ]]  && {
    echo ":: bootstraping toolchain ::"
    for i in kernel-headers glibc binutils libgcc gcc; do
      echo ":: installing toolchain - ${i} ::"
      pkgupd in ${i} --force --no-depends
      if [[ $? != 0 ]] ; then
          echo ":: ERROR :: failed to installing toolchain ${i}"
          exit 1
      fi
    done
    echo ":: bootstrapping success ::"
  }

}

function compile_all() {
  local TotalPackagesToBuild=()
  local TotalBuildSuccess=()
  local TotalBuildFailed=()

  for pkg in ${PKGS};  do
    echo ":: compiling ${pkg}"
    if [[ -f /logs/${pkg}.log ]] ; then
      echo ":: skipping ${pkg}, already compiled"
      continue
    fi
    pkgupd co ${pkg} 2>&1 | sed -r 's/\x1b\[[0-9;]*m//g' | tee /logs/${pkg}.log
    if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to build ${pkg}"
        mv /logs/${pkg}.{log,failed}
        TotalBuildFailed+=(${pkg})
        continue
    else
        TotalBuildSuccess+=(${pkg})
    fi
  done

  echo "
------- Report ----------
  Total Packages    : ${#PKGS[@]}
  Successful Builds : ${#TotalBuildSuccess[@]}
  Failed builds     : ${#TotalBuildFailed[@]}
" > /logs/report-$(date +"%m%d%y%H%M")
}

function calculatePackages() {
  PKGUPD_CONFIG=$(mktemp)
  echo "Version: ${VERSION}
SystemDatabase: /tmp" > ${PKGUPD_CONFIG}
  PKGS=$(pkgupd depends --config ${PKGUPD_CONFIG} ${@} --force)
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to calculate dependency tree"
    exit 1
  fi
  rm ${PKGUPD_CONFIG}
}

function main() {
  parse_args ${@}

  # TODO: fix shadow usrbin split
  # patch for shadow
  rm /var/lib/pkgupd/data/shadow
  rm /var/lib/pkgupd/data/procps-ng
  rm /var/lib/pkgupd/data/util-linux
  rm /var/lib/pkgupd/data/e2fsprogs
  
  if [[ -n ${CONTINUE_BUILD} ]] || [[ -n ${BOOTSTRAP} ]] ; then
    PROFILE_PKGS=$(cat /profiles/${VERSION}/${PROFILE}/pkgs)
    echo ":: calculating dependencies ::"
    calculatePackages ${PROFILE_PKGS}
  elif [[ -n ${COMPILE_ALL} ]] ; then
    echo ":: ordering all packages in dependency order"
    PROFILE_PKGS=$(ls /var/cache/pkgupd/recipes/core/ | sed 's|.yml||g')
    calculatePackages ${PROFILE_PKGS}
  fi

  if [[ -n ${CONTINUE_BUILD} ]] ; then 
    continue_build
  else
    [[ -n ${UPDATE_PKGUPD}  ]] && update_pkgupd
    [[ -n ${BOOTSTRAP}      ]] && bootstrap
  fi

  [[ -n ${REBUILD}        ]] && rebuild
  [[ -n ${GENERATE_ISO}   ]] && generate_iso

  [[ -n ${COMPILE_ALL}    ]] && compile_all
}

main ${@}