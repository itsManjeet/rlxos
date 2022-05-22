#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh
echo ":: starting container ${VERSION} ::"

ARGS=()
PROFILE='desktop'
BUILD_ID=$(date +"%m%d%y%H%M")
DEPENDS_FILE='/tmp/depends'
export PKGUPD_NO_PROGRESS=1

RECIPES_DIR='/var/cache/pkgupd/recipes/'

pkgupd in pkgupd --force --no-depends

pkgupd sync repos=core,

function bootstrap() {
  echo ":: bootstraping toolchain ::"
  for i in kernel-headers glibc binutils gcc binutils glibc ; do
    echo ":: compiling toolchain - ${i} ::"
    pkgupd build \
      build.recipe=${RECIPES_DIR}/core/${i}.yml \
      build.depends=false \
      package.repository=core \
      mode.all-yes=true
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
    if [[ -n ${CONTINUE_BUILD} ]] && [[ -e /logs/${pkg}.log ]] ; then
      pkgupd install ${pkg} force=true
      if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to install ${pkg}"
        mv /logs/${pkg}.{log,failed}
        exit 1
      fi
    else
      if [[ -e /logs/${pkg}.log ]] ; then
        case ${pkg} in
          libgcc|gcc|libllvm|llvm|libboost|boost)
            continue
        esac
      fi

      case ${pkg} in
        libgcc)   pkg=gcc   ;;
        libllvm)  pkg=llvm  ;;
        libboost) pkg=boost ;;
      esac
      echo ":: compiling ${pkg}"
      pkgupd build \
        build.recipe=${RECIPES_DIR}/core/${pkg}.yml \
        build.depends=false \
        package.repository=core \
        mode.all-yes=true 2>&1 | sed -r 's/\x1b\[[0-9;]*m//g' | tee /logs/${pkg}.log
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
  return 0
}

function generating_rootfs() {
  mkdir -p ${ROOTFS}/var/lib/pkgupd/data
    pkgupd install ${@} \
      mode.all-yes=true \
      dir.root=${ROOTFS} \
      dir.data=${ROOTFS}/var/lib/pkgupd/data
    ret=${?}
    rm ${temp_config}
    
    return ${ret}
}

function generate_docker() {
  echo ":: generating docker ::"
  TEMPDIR=$(mktemp -d)

  echo ":: install required tools ::"
  pkgupd install docker mode.all-yes=true
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

  if [[ -e /profiles/${VERSION}/docker/script ]] ; then    
    echo ":: patching root filesystem ::"
    SCRIPT=$(cat /profiles/${VERSION}/docker/script)
    chroot ${ROOTFS} bash -ec "${SCRIPT}"
    if [[ ${?} != 0 ]] ; then
      rm -rf ${TEMPDIR}
      echo ":: ERROR :: failed to execute pre patch script"
      exit 1
    fi
  fi

  echo ":: compressing system ::"
  tar -caf /releases/rlxos-${VERSION}-${BUILD_ID}.tar -C ${TEMPDIR} .
  ret=${?}
  rm -rf ${TEMPDIR}

  echo ":: generating docker image ::"
  cat /releases/rlxos-${VERSION}-${BUILD_ID}.tar | docker import - itsmanjeet/rlxos-devel:${VERSION}-${BUILD_ID}

  echo ":: generating docker success ::"
  return 0
}

function generate_iso() {
  echo ":: generating iso ::"
  TEMPDIR=$(mktemp -d)

  echo ":: install required tools ::"
  pkgupd install grub-i386 grub squashfs-tools lvm2 initramfs plymouth mtools linux mode.all-yes=true
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

  while read loc format ; do
    chroot ${ROOTFS} /usr/bin/localdef -i ${loc} -f ${format} ${loc}.${format}
  done < /var/cache/pkgupd/files/supported_locales

  echo "${BUILD_ID}" > ${TEMPDIR}/etc/rlxos-release

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

  pkgupd install linux version=${VERSION} dir.data="/tmp" force=true
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR} ${PKGUPD_CONFIG}
    echo ":: ERROR :: failed to calculate dependency tree"
    exit 1
  fi


  echo ":: installing initrd kernel=${KERNEL_VERSION}-rlxos Modules=${ISODIR}/boot/modules"
  mkinitramfs -u -k=${KERNEL_VERSION}-rlxos -m=${ISODIR}/boot/modules -o=${ISODIR}/boot/initrd-${KERNEL_VERSION}-rlxos
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install initrd"
    exit 1
  fi

  echo "default='rlxos GNU/Linux [${VERSION}] Installer'
  timeout=5
  
  insmod all_video
  menuentry 'rlxos GNU/Linux [${VERSION}] Installer' {
    linux /boot/vmlinuz-${KERNEL_VERSION}-rlxos iso=1 root=LABEL=RLXOS system=${VERSION}
    initrd /boot/initrd-${KERNEL_VERSION}-rlxos
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

  ISOFILE="/releases/rlxos-${PROFILE}-${VERSION}-${BUILD_ID}.iso"
  grub-mkrescue -volid RLXOS ${ISODIR} -o ${ISOFILE}
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install overlay image"
    exit 1
  fi

  md5sum ${ISOFILE} > ${ISOFILE}.md5

  echo ":: generating iso success ::"
  return 0
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

      --docker)
        GENERATE_DOCKER=1
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
      
      --list-depends)
        LIST_DEPENDS=1
        shift
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
      pkgupd install ${i} force=true
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
    pkgupd build \
      build.recipe=${RECIPES_DIR}/core/${pkg}.yml \
      package.repository=core \
      build.depends=false \
      package.repository=core \
      mode.all-yes=true 2>&1 | sed -r 's/\x1b\[[0-9;]*m//g' | tee /logs/${pkg}.log
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
  PKGS=$(pkgupd depends dir.data=/tmp repos=core, ${@} 2>&1)
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to calculate dependency tree: ${PKGS}"
    exit 1
  fi
}

function main() {
  parse_args ${@}

  # TODO: fix shadow usrbin split
  # patch for shadow
  rm /var/lib/pkgupd/data/shadow
  rm /var/lib/pkgupd/data/procps-ng
  rm /var/lib/pkgupd/data/util-linux
  rm /var/lib/pkgupd/data/e2fsprogs
  rm /var/lib/pkgupd/data/iptables

  if [[ -n ${LIST_DEPENDS} ]] ; then
    PROFILE_PKGS=$(cat /profiles/${VERSION}/${PROFILE}/pkgs)
    echo ":: listing dependencies ::"
    calculatePackages ${PROFILE_PKGS} grub-i386 grub squashfs-tools lvm2 initramfs plymouth mtools linux

    echo "Packages: ${PKGS}"
    exit 0
  fi
  
  if [[ -n ${CONTINUE_BUILD} ]] || [[ -n ${BOOTSTRAP} ]] ; then
    PROFILE_PKGS=$(cat /profiles/${VERSION}/${PROFILE}/pkgs)
    echo ":: calculating dependencies ::"
    calculatePackages ${PROFILE_PKGS} grub-i386 grub squashfs-tools lvm2 initramfs plymouth mtools linux

    echo "Packages: ${PKGS}"
  elif [[ -n ${COMPILE_ALL} ]] ; then
    echo ":: ordering all packages in dependency order"
    PROFILE_PKGS=$(find /var/cache/pkgupd/recipes/ -type f -name "*.yml" -exec basename {} \; | sed 's|.yml||g')
    calculatePackages ${PROFILE_PKGS}

    echo "Packages: ${PKGS}"
  fi

  if [[ -n ${CONTINUE_BUILD} ]] ; then 
    continue_build
  else
    [[ -n ${UPDATE_PKGUPD}  ]] && update_pkgupd
    [[ -n ${BOOTSTRAP}      ]] && bootstrap
  fi

  [[ -n ${REBUILD}        ]] && rebuild

  [[ -n ${COMPILE_ALL}    ]] && compile_all

  [[ -n ${GENERATE_ISO}   ]] && {
    PROFILE_PKGS=$(cat /profiles/${VERSION}/${PROFILE}/pkgs)
    echo ":: listing required packages ::"
    calculatePackages ${PROFILE_PKGS}
    generate_iso
  }

  [[ -n ${GENERATE_DOCKER}   ]] && {
    PROFILE_PKGS=$(cat /profiles/${VERSION}/docker/pkgs)
    echo ":: listing required packages ::"
    calculatePackages ${PROFILE_PKGS}
    generate_docker
    docker push itsmanjeet/rlxos-devel:${VERSION}-${BUILD_ID}
  }
  return 0
}

main ${@}
