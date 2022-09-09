#!/bin/bash

BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

[[ -e ${BASEDIR}/.config ]] && source ${BASEDIR}/.config

VERSION=${VERSION:-2200}
KERNEL=${KERNEL:-5.18}
CONTAINER=${CONTAINER:-'itsmanjeet/rlxos-devel:2200-2'}
INTERACTIVE='-i'
PKGUPD_PATH='/var/cache/pkgupd'
BUILDDIR="${BASEDIR}/build"
LOGDIR="${BUILDDIR}/logs"

function printLogo() {
    [[ -z ${LOGO} ]] && cat ${BASEDIR}/files/logo/ascii || echo ${LOGO}
    echo -e "\n\n"
}

function printHelp() {
    printLogo

    echo "                rlxos GNU/Linux ${VERSION}"
    echo "            -----------------------------------"
    echo "Usage:"
    echo "  build <recipe-file>         build package from specified recipe file"
    echo "  test <file>                 test build inside rlxos container"
    echo ""
    echo "Flags:"
    echo "  --container                 specify docker container to run command inside"
    echo "  --non-interactive           non interactive docker run"
    echo "  --pkgupd-path               specify pkgupd cache path inside container"
    echo "  --kernel                    specify kernel version for release build"
    echo "  --build-dir                 specify build directory"
    echo "  --debug                     enable PKGUPD debug messages"
    echo ""
}

function runInsideDocker() {
    echo "INSIDE DOCKER: $@"
    docker run                              \
        --rm                                \
        --network host                      \
        --device    /dev/fuse               \
        --cap-add   SYS_ADMIN               \
        --security-opt apparmor:unconfined  \
        -v ${BASEDIR}/recipes:/recipes \
        -v ${BUILDDIR}/pkgs:${PKGUPD_PATH}/pkgs \
        -v ${BUILDDIR}/sources:${PKGUPD_PATH}/src \
        -v ${BUILDDIR}/releases:${PKGUPD_PATH}/releases \
        -v ${BUILDDIR}/screenshots:/screenshots \
        -v ${BASEDIR}/pkgupd.yml:/etc/pkgupd.yml \
        --privileged \
        ${INTERACTIVE} -t ${CONTAINER} /usr/bin/env -i \
            HOME=/root          \
            TERM=${TERM}        \
            PS1='[container] \u:\w$ '   \
            PATH='/usr/bin:/opt/bin:/apps' \
            PKGUPD_NO_PROGRESS=1 ${DEBUG_FLAG} \
            /usr/bin/bash -c "$@"        
}

mkdir -p ${LOGDIR}

function Log() {
    sed -r 's/\x1b\[[0-9;]*m//g' | tee ${LOGDIR}/${1}.log
}

function doGenerateSystem() {
    local _system_file=${1}
    [[ -z ${_system_file} ]] && {
        echo "no system image provided"
        exit 1
    }
    [[ ! -e ${_system_file} ]] && {
        echo "system image file ${_system_file} not exists"
        exit 1
    }
    _system_file=$(realpath $_system_file | sed "s#${BUILDDIR}#${PKGUPD_PATH}#g")

    local _overlay_file=${2}
    [[ -z ${_overlay_file} ]] && {
        echo "no overlay image provided"
        exit 1
    }
    [[ ! -e ${_overlay_file} ]] && {
        echo "overlay image file ${_overlay_file} not exists"
        exit 1
    }
    _overlay_file=$(realpath $_overlay_file | sed "s#${BUILDDIR}#${PKGUPD_PATH}#g")

    local _id=${3}
    [[ -z $_id ]] && {
        echo "no package id specified"
        exit 1
    }

    local _version=${4}
    [[ -z ${_version} ]] && {
        echo "no version specified"
        exit 1
    }

    echo "SYSTEM FILE : ${_system_file}"
    echo "OVERLAY FILE: ${_overlay_file}"
    echo "KERNEL      : ${KERNEL}"
    echo "VERSION     : ${_version}"
    local _isofile="rlxos-${_id}-${_version}.iso"

    runInsideDocker "pkgupd update mode.ask=false && \
        pkgupd install squashfs-tools rlxos-build-tools mtools mode.ask=false && \
        mkiso --system-image ${_system_file} \
              --overlay ${_overlay_file} \
              --kernel-version ${KERNEL} \
              --version ${_version} \
              --output ${PKGUPD_PATH}/releases/${_isofile}"
    if [[ $? != 0 ]] ; then
        echo "Error! failed generate system iso"
        exit 1
    fi

    if [[ ! -e ${BUILDDIR}/releases/${_isofile} ]] ; then
        echo "Error! no iso file build ${_isofile}"
        exit 1
    fi

    (
        cd ${BUILDDIR}/releases/;
        md5sum ${_isofile} > ${_isofile}.md5sum;
    )

    echo "SUCCESS ISO file ready"
}

function doTestAppImage() {
    local _appimage_file=${1}
    [[ -z ${_appimage_file} ]] && {
        echo "no app image provided"
        exit 1
    }

    _appimage_file=$(realpath ${_appimage_file})
    [[ ! -e ${_appimage_file} ]] && {
        echo "no appimage file exists"
        exit 1
    }

    local _appimage_inside=$(echo ${_appimage_file} | sed "s#${BUILDDIR}#${PKGUPD_PATH}#g")
    echo "TESTING: ${_appimage_inside}"

    # runInsideDocker "pkgupd update mode.ask=false; \
    #     pkgupd install xorg imagemagick gtk dbus-glib libnl mode.ask=false; \
        
    #     Xvfb :100 -screen 5 1024x768x8 &
    #     sleep 2
    #     DISPLAY=:100 ${_appimage_inside} &
    #     sleep 2
    #     DISPLAY=:100 xwd -root -silent | convert xwd:- png:/screenshots/icon.png;
    #     killall Xvfb
    #     killall ${_appimage_inside}"
}

function doBuild() {
    local _recipefile=${1}
    [[ -z ${_recipefile} ]] && {
        echo "no recipe file provided"
        exit 1
    }

    local _repository=$(echo ${_recipefile} | rev | cut -d '/' -f3 | rev)
    local _package_id=$(echo ${_recipefile} | rev | cut -d '/' -f1 | rev | sed 's#.yml##g')

    echo "REPOSITORY: ${_repository}"
    echo "PACKAGE ID: ${_package_id}"
    
    runInsideDocker "pkgupd update mode.ask=false && \
        pkgupd install squashfs-tools mode.ask=false && \
        pkgupd build /${_recipefile} build.repository=${_repository}" | Log ${_package_id}
    if [[ ${PIPESTATUS[0]} != 0 ]] ; then
        echo "Error! failed to build ${_repository}/${_package_id}"
        exit 1
    fi

    local _package_meta="${BUILDDIR}/pkgs/${_repository}/${_package_id}.meta"
    if [[ ! -e $_package_meta ]] ; then 
        echo "Error! no meta file generated"
        exit 
    fi
    local _package_version="$(cat ${_package_meta} | grep 'version:' | awk '{print $2}')"
    local _package_type="$(cat ${_package_meta} | grep 'type:' | awk '{print $2}')"
    local _package_file="${BUILDDIR}/pkgs/${_repository}/${_package_id}-${_package_version}.${_package_type}"

    echo "PACKAGE FILE: ${_package_file}"
    if [[ ! -e ${_package_file} ]] ; then
        echo "Error! no package file generated ${_package_file}"
        exit 1
    fi
    echo "Build success ${_repository}/${_package_id}"
    case "${_repository}" in
        app)
            doTestAppImage ${_package_file}
            ;;

        system)
            if [[ "${_recipefile}" =~ '-overlay.yml' ]] ; then
                echo "finishing overlay"
                exit 0
            fi

            local _overlay_meta=$(echo ${_package_meta} | sed 's#.meta#-overlay.meta#g')
            local _overlay_version="$(cat ${_overlay_meta} | grep 'version:' | awk '{print $2}')"
            local _overlay_type="$(cat ${_overlay_meta} | grep 'type:' | awk '{print $2}')"
            local _overlay_file="${BUILDDIR}/pkgs/${_repository}/${_package_id}-overlay-${_overlay_version}.${_overlay_type}"
            if [[ ! -e ${_overlay_file} ]] ; then
                echo "Error! no overlay file ${_overlay_file} not exists"
                exit 1
            fi
            doGenerateSystem ${_package_file} ${_overlay_file} ${_package_id} ${_package_version} 
            ;;
    esac
}

# Parse input arguments
ARGS=()
while [[ $# -gt 0 ]] ; do
    case $1 in
        --container)
            container=${2}
            shift
            ;;

        --non-interactive)
            INTERACTIVE=''
            ;;

        --pkgupd-path)
            PKGUPD_PATH=${2}
            shift
            ;;

        --kernel)
            KERNEL=${2}
            shift
            ;;

        --build-dir)
            BUILDDIR=${2}
            shift
            ;;

        --debug)
            DEBUG=1
            DEBUG_FLAG='DEBUG=1'
            ;;
        
        -*|--*)
            echo "Error! unknown option $1"
            exit 1
            ;;
        *)
            [[ -z ${TASK} ]] && TASK=${1} || ARGS+=("$1")
            ;;
    esac
    shift
done

if [[ -z ${TASK} ]] ; then
    printHelp
    exit 1
fi

case ${TASK} in
    build)
        if [[ ${#ARGS[@]} -ne 1 ]] ; then
            echo "Error! exactly 1 argument required for 'build' task"
            exit 1
        fi

        doBuild ${ARGS[0]}
        exit $?
        ;;

    test-appimage)
        if [[ ${#ARGS[@]} -ne 1 ]] ; then
            echo "Error! exactly 1 argument required for 'test-appimage' task"
            exit 1
        fi
        doTestAppImage ${ARGS[0]}
        exit $?
        ;;

    *)
        printHelp
        exit 1
        ;;
esac
