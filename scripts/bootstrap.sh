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

function generate_tar() {
  echo ":: generating tarball ::"
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
    rm -rf ${TEMPDIR}
    echo ":: ERROR :: failed to compress rootfilesystem"
    exit 1
  fi

  echo ":: generate tarball success ::"
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

      --tar)
        GENERATE_TAR=1
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


function main() {
  parse_args ${@}

  PROFILE_PKGS=$(cat /profiles/${VERSION}/${PROFILE}/pkgs)
  echo ":: calculating dependencies ::"

  PKGUPD_CONFIG=$(mktemp)
  echo "Version: ${VERSION}
SystemDatabase: /tmp" > ${PKGUPD_CONFIG}
  PKGS=$(pkgupd depends --config ${PKGUPD_CONFIG} ${PROFILE_PKGS} --force)
  if [[ $? != 0 ]] ; then
    echo ":: ERROR :: failed to calculate dependency tree"
    exit 1
  fi
  rm ${PKGUPD_CONFIG}

  # TODO: fix shadow usrbin split
  # patch for shadow
  rm /var/lib/pkgupd/data/shadow
  rm /var/lib/pkgupd/data/procps-ng
  rm /var/lib/pkgupd/data/util-linux
  rm /var/lib/pkgupd/data/e2fsprogs
  rm /var/lib/pkgupd/data/iptables

  if [[ -n ${CONTINUE_BUILD} ]] ; then 
    continue_build
  else
    [[ -n ${UPDATE_PKGUPD}  ]] && update_pkgupd
    [[ -n ${BOOTSTRAP}      ]] && bootstrap
  fi

  [[ -n ${REBUILD}        ]] && rebuild
  [[ -n ${GENERATE_TAR}   ]] && generate_tar
}

main ${@}