#!/bin/bash

BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

[[ -e ${BASEDIR}/.config ]] && source ${BASEDIR}/.config
KERNEL=${KERNEL:-'5.18'}
PKGUPD_PATH=${PKGUPD_PATH:-'/storage/'}
SERVER_STABILITY='testing'

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
    echo "  --pkgupd-path               specify pkgupd cache path inside container"
    echo "  --kernel                    specify kernel version for release build"
    echo "  --build-dir                 specify build directory"
    echo "  --debug                     enable PKGUPD debug messages"
    echo ""
}


function Log() {
    sed -r 's/\x1b\[[0-9;]*m//g' | tee /var/log/${1}.log
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
    _system_file=$(realpath $_system_file)

    local _overlay_file=${2}
    [[ -z ${_overlay_file} ]] && {
        echo "no overlay image provided"
        exit 1
    }
    [[ ! -e ${_overlay_file} ]] && {
        echo "overlay image file ${_overlay_file} not exists"
        exit 1
    }
    _overlay_file=$(realpath $_overlay_file)

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

    mkiso --system-image ${_system_file} \
              --overlay ${_overlay_file} \
              --kernel-version ${KERNEL} \
              --version ${_version} \
              --output ${PKGUPD_PATH}/releases/${_isofile}
    if [[ $? != 0 ]] ; then
        echo "Error! failed generate system iso"
        exit 1
    fi

    if [[ ! -e ${PKGUPD_PATH}/releases/${_isofile} ]] ; then
        echo "Error! no iso file build ${_isofile}"
        exit 1
    fi

    (
        cd ${PKGUPD_PATH}/releases/;
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

    local _appimage_inside=${_appimage_file}
    echo "TESTING: ${_appimage_inside}"

    # runInsideDocker "_pkgupd update mode.ask=false; \
    #     _pkgupd install xorg imagemagick gtk dbus-glib libnl mode.ask=false; \
        
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

    if [[ -z ${SKIP_BUILD} ]] ; then
        _pkgupd build /${_recipefile} build.repository="${_repository}" | Log ${_package_id}
        if [[ ${PIPESTATUS[0]} != 0 ]] ; then
            echo "Error! failed to build ${_repository}/${_package_id}"
            exit 1
        fi
    else
        echo "SKIPPING BUILD"
    fi

    local _package_meta="${PKGUPD_PATH}/${_repository}/${_package_id}.meta"
    if [[ ! -e $_package_meta ]] ; then 
        echo "Error! no meta file generated at ${_package_meta}"
        exit 
    fi
    local _package_version="$(cat ${_package_meta} | grep 'version:' | awk '{print $2}')"
    local _package_type="$(cat ${_package_meta} | grep 'type:' | awk '{print $2}')"
    local _package_file="${PKGUPD_PATH}/${_repository}/${_package_id}-${_package_version}.${_package_type}"

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

            if [[ "${_recipefile}" =~ '-docker.yml' ]] ; then
                pkgupd install docker mode.ask=false
                cat ${_package_file} | zstd -d | docker import - "itsmanjeet/${_package_id}:${_package_version}"
                exit 0
            fi

            local _overlay_meta=$(echo ${_package_meta} | sed 's#.meta#-overlay.meta#g')
            local _overlay_version="$(cat ${_overlay_meta} | grep 'version:' | awk '{print $2}')"
            local _overlay_type="$(cat ${_overlay_meta} | grep 'type:' | awk '{print $2}')"
            local _overlay_file="${PKGUPD_PATH}/${_repository}/${_package_id}-overlay-${_overlay_version}.${_overlay_type}"
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
        --kernel)
            KERNEL=${2}
            shift
            ;;

        --pkgupd-path)
            PKGUPD_PATH=${2}
            shift
            ;;

        --debug)
            DEBUG=1
            DEBUG_FLAG='DEBUG=1'
            ;;
        
        --skip-build)
            SKIP_BUILD=1
            ;;
        
        --server-stability)
            SERVER_STABILITY=${2}
            shift
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

function _pkgupd() {
    pkgupd $@ dir.pkgs=${PKGUPD_PATH}

}

case ${TASK} in
    build)
        if [[ ${#ARGS[@]} -ne 1 ]] ; then
            echo "Error! exactly 1 argument required for 'build' task"
            exit 1
        fi

        doBuild $(realpath ${ARGS[0]})
        exit $?
        ;;

    refresh)
        _pkgupd meta server.stability=${SERVER_STABILITY}
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
