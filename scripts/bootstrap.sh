#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

CONTAINER_VERSION='2200-64'
SERVER_URL='https://apps.rlxos.dev'

if [[ -z "${NOCONTAINER}" ]]; then
    ROOTDIR="${ROOTDIR:-$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)/../}"
    
    if [[ ! -e ${ROOTDIR}/.version ]] && [[ -z ${VERSION} ]]; then
        echo "Error! no version specified"
        exit 1
    fi
    if [[ -z ${NO_INPUT} ]] ; then
        EXTRA_FLAGS='-i'
    fi

    STORAGE_DIR=${STORAGE_DIR:-${ROOTDIR}/build}
    VERSION=${VERSION:-$(cat ${ROOTDIR}/.version)}
    PKGUPD_FILE=${PKGUPD_FILE:-pkgupd.testing.yml}
    docker run \
        --rm \
        --network host \
        --device /dev/fuse \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        -v "${ROOTDIR}/scripts:/scripts" \
        -v "${ROOTDIR}/recipes:/var/cache/pkgupd/recipes" \
        -v "${STORAGE_DIR}/${VERSION}/pkgs:/var/cache/pkgupd/pkgs" \
        -v "${STORAGE_DIR}/sources:/var/cache/pkgupd/src" \
        -v "${STORAGE_DIR}/${VERSION}/logs:/logs" \
        -v "${STORAGE_DIR}/${VERSION}/releases:/releases" \
        -v "${ROOTDIR}/files:/var/cache/pkgupd/files" \
        -v "${ROOTDIR}/profiles:/profiles" \
        -v "${ROOTDIR}/${PKGUPD_FILE}:/etc/pkgupd.yml" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ${EXTRA_FLAGS} --privileged \
        -t itsmanjeet/rlxos-devel:${CONTAINER_VERSION} /usr/bin/env -i \
        HOME=/root \
        TERM=${TERM} \
        PS1='(container) \u:\w$ ' \
        PATH='/usr/bin:/opt/bin:/apps' \
        NOCONTAINER=1 \
        SERVER_URL=${SERVER_URL} \
        ROOTDIR=${ROOTDIR} \
        VERSION=${VERSION} "/scripts/$(basename ${0})" ${@}
    exit $?
fi

echo ":: starting container ${VERSION} ::"

ARGS=()
PROFILE='desktop'
BUILD_ID=$(date +"%m%d%y%H%M")
DEPENDS_FILE='/tmp/depends'
export PKGUPD_NO_PROGRESS=1

RECIPES_DIR='/var/cache/pkgupd/recipes/'
FILES_DIR='/var/cache/pkgupd/files/'
echo ":: updating system"
pkgupd update mode.ask=false

pkgupd install pkgupd force=true mode.ask=false

echo ":: updating system"
pkgupd update mode.ask=false

LOGDIR='/logs'
export DEBUG=1
export PKGUPD_NO_PROGRESS=1

# Log <tag> <id>
# Filter the required data from input stream and store them in file
function Log() {
  sed -r 's/\x1b\[[0-9;]*m//g' | tee ${LOGDIR}/${1}/${2}-$(date +%m-%d-%y:%I-%M%P).log
}

# printLogo
# print rlxos logo and related details
function printLogo() {
cat ${FILES_DIR}/logo/ascii

echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "Architecture : $(uname -m)"
echo "Container    : ${CONTAINER_VERSION}"
echo "GCC          : $(pkgupd info gcc info.value=version)"
echo "Binutils     : $(pkgupd info binutils info.value=version)"
echo "GLibc        : $(pkgupd info glibc info.value=version)"
echo "Pkgupd       : $(pkgupd info pkgupd info.value=version)"
}

function bootstrap() {
  local _tag='bootstrap'
  
  mkdir -p ${LOGDIR}/${_tag}

  echo ":: bootstraping toolchain ::"
  for i in kernel-headers glibc binutils gcc binutils glibc ; do
    echo ":: compiling toolchain - ${i} ::"
    pkgupd build \
      build.recipe=${RECIPES_DIR}/core/${i}.yml \
      build.depends=false \
      package.repository=core \
      mode.ask=false 2>&1 | Log "${_tag}" "${i}"
    if [[ $? != 0 ]] ; then
        echo ":: ERROR :: failed to build toolchain ${i}"
        exit 1
    fi
  done

  echo ":: bootstrapping success ::"
}

function rebuild() {
  local _tag='build'

  mkdir -p ${LOGDIR}/${_tag}

  echo ":: rebuilding packages ::"
  for pkg in ${PKGS} ; do
    if [[ -n ${CONTINUE_BUILD} ]] && [[ -e ${LOGDIR}/${_tag}/${pkg}-*.log ]] ; then
      pkgupd install ${pkg} force=true mode.ask=false 2>&1 | Log ${_tag} "${pkg}"
      if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to install ${pkg}"
        exit 1
      fi
    else
      if [[ -e ${LOGDIR}/${_tag}/${pkg}-*.log ]] ; then
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
        mode.ask=false 2>&1 | Log ${_tag} ${pkg}
      if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to build ${pkg}"
        exit 1
      fi
    fi
    case ${pkg} in
      libgcc|gcc)
        touch ${LOGDIR}/${_tag}/libgcc-xxx.log
        touch ${LOGDIR}/${_tag}/gcc-xxx.log
        ;;

      libllvm|llvm)
        touch ${LOGDIR}/${_tag}/libllvm-xxx.log
        touch ${LOGDIR}/${_tag}/llvm-xxx.log
        ;;

      libboost|boost)
        touch ${LOGDIR}/${_tag}/boost-xxx.log
        touch ${LOGDIR}/${_tag}/libboost-xxx.log
        ;;
    esac
  done
  
  echo ":: rebuilding success ::"
  return 0
}

function generating_rootfs() {
  mkdir -p ${ROOTFS}/var/lib/pkgupd/data
  DEBUG=1 \
    pkgupd install ${@} \
      mode.ask=false \
      dir.root=${ROOTFS} \
      dir.data=${ROOTFS}/var/lib/pkgupd/data \
      installer.triggers=false
    ret=${?}

  return ${ret}
}

function generate_docker() {
  echo ":: generating docker ::"
  TEMPDIR=$(mktemp -d)

  echo ":: install required tools ::"
  pkgupd install docker mode.ask=false
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

  KERNEL_PACKAGE=linux
  if [[ -e /profiles/${VERSION}/${PROFILE}/kernel ]] ; then
    echo ":: using kernel ${KERNEL_PACKAGE}"
    KERNEL_PACKAGE=$(cat /profiles/${VERSION}/${PROFILE}/kernel)
  fi

  echo ":: install required tools ::"
  pkgupd install grub-i386 grub squashfs-tools lvm2 initramfs plymouth mtools ${KERNEL_PACKAGE} mode.ask=false
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

  # generate non changable system packages
  mkdir -p ${ROOTFS}/etc/pkgupd.conf.d/
  echo "system.packages: " > ${ROOTFS}/etc/pkgupd.conf.d/system-packages.yml
  ls ${ROOTFS}/var/lib/pkgupd/data/ | tr ' ' '\n' | sed 's@^@  - @' >> ${ROOTFS}/etc/pkgupd.conf.d/system-packages.yml

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

# systemd setup
systemctl enable getty@tty1.service

ln -sv /proc/self/mounts /etc/mtab
ln -sv /run/systemd/resolve/stub-resolv.conf /etc/resolve.conf

mkdir -p /usr/lib/locale
EOT
  if [[ $? != 0 ]] ; then
    rm -rf ${TEMPDIR}
    echo ":: ERROR :: failed to execute essentails"
    exit 1
  fi

  dbus-uuidgen > ${TEMPDIR}/etc/machine-id

  while read loc format ; do
    echo "adding locale ${loc}.${format}"
    chroot ${ROOTFS} /usr/bin/localedef -i ${loc} -f ${format} ${loc}.${format}
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

  if [[ -e /profiles/${VERSION}/${PROFILE}/services ]] ; then
    echo ":: enabling system services ::"
    SERVICES=$(cat /profiles/${VERSION}/${PROFILE}/services)
    for i in ${SERVICES} ; do
      echo " - ${i}"
      chroot ${ROOTFS} /usr/bin/systemctl enable ${i}
      if [[ ${?} != 0 ]] ; then
        rm -rf ${TEMPDIR}
        echo ":: ERROR :: failed to enable '${i}' service"
        exit 1
      fi
    done
  fi

  echo ":: compressing system ::"
  mksquashfs ${TEMPDIR} /releases/rlxos-${VERSION}-${BUILD_ID}.sfs -comp zstd -Xcompression-level 12 -noappend
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

  KERNEL_VERSION=$(pkgupd info ${KERNEL_PACKAGE} info.value=version)
  if [[ $? != 0 ]] || [[ -z ${KERNEL_VERSION} ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to get kernel version"
    exit 1
  fi

  pkgupd install ${KERNEL_PACKAGE} version=${VERSION} dir.root=${ISODIR} dir.data="/tmp" force=true mode.ask=false
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
  menuentry 'rlxos GNU/Linux [${VERSION}-${BUILD_ID}] Installer' {
    linux /boot/vmlinuz-${KERNEL_VERSION}-rlxos iso=1 root=LABEL=RLXOS system=${VERSION}-${BUILD_ID}
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

  mksquashfs ${TEMPDIR}/overlay/* ${ISODIR}/iso.img -noappend
  if [[ $? != 0 ]] ; then
    rm -rf ${ISODIR} ${TEMPDIR}
    echo ":: ERROR :: failed to install overlay image"
    exit 1
  fi

  # Injecting release version
  echo "${VERSION}-${BUILD_ID}" > ${ISODIR}/version

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

      --build-package)
        BUILD_PACKAGE=1
        ;;

      --generate-metadata)
        GENERATE_METADATA=1
        ;;

      --continue-build)
        CONTINUE_BUILD=1
        ;;

      --compile-all)
        COMPILE_ALL=1
        ;;

      --execute)
        EXECUTE=1
        ;;
      
      --list-depends)
        LIST_DEPENDS=1
        ;;

      --revdep)
        REV_DEP=1
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
  mkdir -p ${LOGDIR}/pkgupd

  echo ":: updating PKGUPD"
  pkgupd build pkgupd mode.ask=false 2>&1 | Log 'pkgupd' 'update'
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to upgrade PKGUPD"
    exit 1
  fi
}

function continue_build() {
  local _tag='build'
  echo ":: continuing build ::"

  [[ -n ${UPDATE_PKGUPD}  ]] && {
    echo ":: updating pkgupd ::"
    pkgupd install pkgupd force=yes
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
      pkgupd install ${i} force=true mode.ask=false | Log ${_tag} "${i}"
      if [[ $? != 0 ]] ; then
          echo ":: ERROR :: failed to installing toolchain ${i}"
          exit 1
      fi
    done
    echo ":: bootstrapping success ::"
  }

}

function compile_all() {
  local _tag='build'
  mkdir -p ${LOGDIR}/${_tag}

  local TotalPackagesToBuild=()
  local TotalBuildSuccess=()
  local TotalBuildFailed=()

  for pkg in ${PKGS};  do
    echo ":: compiling ${pkg}"
    if [[ -f ${LOGDIR}/${_tag}/${pkg}-*.log ]] ; then
      echo ":: skipping ${pkg}, already compiled"
      continue
    fi
    pkgupd build \
      build.recipe=${RECIPES_DIR}/core/${pkg}.yml \
      package.repository=core \
      build.depends=false \
      package.repository=core \
      mode.ask=false 2>&1 | Log ${_tag} ${pkg}
    if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo ":: ERROR :: failed to build ${pkg}"
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
" > ${LOGDIR}/${_tag}/report-$(date +"%m%d%y%H%M")
}

function calculatePackages() {
  PKGS=$(pkgupd depends dir.data=/tmp ${@} 2>&1)
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to calculate dependency tree: ${PKGS}"
    exit 1
  fi
}

function main() {
  parse_args ${@}

  # TODO: fix shadow usrbin split
  # patch for shadow
  # rm /var/lib/pkgupd/data/shadow
  # rm /var/lib/pkgupd/data/procps-ng
  # rm /var/lib/pkgupd/data/util-linux
  # rm /var/lib/pkgupd/data/e2fsprogs
  # rm /var/lib/pkgupd/data/iptables

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
    mkdir -p ${LOGDIR}/iso

    PROFILE_PKGS=$(cat /profiles/${VERSION}/${PROFILE}/pkgs)
    echo ":: listing required packages ::"
    calculatePackages ${PROFILE_PKGS}
    generate_iso 2>&1 | Log 'iso' ${BUILD_ID} 
  }

  [[ -n ${GENERATE_DOCKER}   ]] && {
    mkdir -p ${LOGDIR}/docker

    PROFILE_PKGS=$(cat /profiles/${VERSION}/docker/pkgs)
    echo ":: listing required packages ::"
    calculatePackages ${PROFILE_PKGS}
    generate_docker 2>&1 | Log 'docker' ${BUILD_ID}
    docker push itsmanjeet/rlxos-devel:${VERSION}-${BUILD_ID}
  }

  [[ -n ${REV_DEP} ]] && {
    [[ "${#ARGS[@]}" == 0 ]] && {
      echo "no package specified ${ARGS[@]}"
      exit 1
    }
    pkgid=${ARGS[0]}

    echo "calculating reverse dependency for ${pkgid}"
    pkgupd revdep ${pkgid}
    if [[ $? != 0 ]] ; then
      echo "Error! failed to build ${pkgid}"
      exit 1
    fi
  }

  [[ -n ${BUILD_PACKAGE} ]] && {
    [[ "${#ARGS[@]}" == 0 ]] && exit 1
    pkgid=${ARGS[0]}
    mkdir -p ${LOGDIR}/build
    pkgupd build /var/cache/pkgupd/${pkgid} \
      build.repository=$(echo ${pkgid} | cut -d '/' -f2) \
      mode.ask=false  2>&1 | Log 'build' "$(basename ${pkgid} | sed 's#.yml##g')"
      if [[ ${PIPESTATUS[0]} != 0 ]] ; then
          echo "Error! failed to build ${pkgid}"
          exit 1
      fi
  }

  [[ -n ${GENERATE_METADATA} ]] && {
    unset DEBUG
    pkgupd install squashfs-tools mode.ask=false || {
      echo "Error! failed to install required packages"
      exit 1
    }

    pkgupd meta || {
      echo "Error! failed to generate meta data"
      exit 1
    }
  }

  [[ -n ${EXECUTE} ]] && {
    echo ":: running in container ${ARGS[@]}"
    ${ARGS[@]} || {
      echo "Error! failed to execute command"
    }
  }
  
  return 0
}

printLogo

main ${@}
