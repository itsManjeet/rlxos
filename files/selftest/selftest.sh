#!/bin/bash

ROOT_DIR=${ROOT_DIR:-''}

function check_filesystem_hierarchy() {
    echo "=> checking filesystem hierarchy"

    function check_filesystem_dir() {
        echo "    PATH ${1}"
        if [[ ! -d ${1} ]] ; then
            echo "ERROR ${1} must exists"
            return 1
        fi
    }

    function check_filesystem_link() {
        echo "    SYMLINK ${1} -> ${2}"
        if [[ ! -L ${1} ]] ; then
            echo "ERROR ${1} must be symlink to ${2}"
            return 1
        fi

        local original_path=$(readlink ${1})
        if [[ "$original_path" != "${2}" ]] ; then
            echo "ERROR: ${1} must symlink to ${2} but '${original_path}'"
            return 1
        fi

        return 0
    }

    check_filesystem_dir ${ROOT_DIR}/usr/bin
    check_filesystem_dir ${ROOT_DIR}/usr/lib

    check_filesystem_link ${ROOT_DIR}/usr/sbin   bin
    check_filesystem_link ${ROOT_DIR}/bin        usr/bin
    check_filesystem_link ${ROOT_DIR}/sbin       usr/sbin
    check_filesystem_link ${ROOT_DIR}/lib        usr/lib
    check_filesystem_link ${ROOT_DIR}/lib64      usr/lib64
    check_filesystem_link ${ROOT_DIR}/usr/lib64  lib
}

function check_dependent_libraries() {

    function get_missing_libraries() {
        local _missing_libraries=$(ldd ${1} 2>/dev/null | grep "not found" | awk '{print $1}' | tr '\n' ' ')
        if [[ ! -z ${_missing_libraries} ]] ; then
            echo -e "    ${1}\tNEED ${_missing_libraries} $(PKGUPD_NO_MESSAGE=1 pkgupd owner $(realpath ${1}))"
        fi
    }

    echo "=> checking broken dependencies"
    for bin in ${ROOT_DIR}/bin/* ; do
        get_missing_libraries $bin
    done

    for lib in $(find ${ROOT_DIR}/lib/ -type f -name "*.so*"); do
        get_missing_libraries $lib
    done
}

check_filesystem_hierarchy
check_dependent_libraries