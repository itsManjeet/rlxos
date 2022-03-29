#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=${VERSION:-$(cat ${BASEDIR}/.version)}

ARCHPKG_URL='https://archlinux.org/packages'
ARCH=$(uname -m)
REPOS='core extra community'
RECIPEDIR="${BASEDIR}/build/${VERSION}/recipes/"

function check_updates_backend() {
    local pkg=${1}
    local repo=${2}
    local URL=${ARCHPKG_URL}/${repo}/${ARCH}/${pkg}/json/
    curl ${URL} -s  | jq -r '.pkgver'
}

function check_updates() {
    local version
    for repo in ${REPOS} ; do
        version=$(check_updates_backend ${1} ${repo} 2>/dev/null)
        if [[ $? == 0 ]] ; then
            echo "${version}"
            return 0
        fi
        echo ${version}
    done
    return 1
}

function check_local_version_backend() {
    local repo=${1}
    local pkg=${2}
    local version
    version=$(cat ${RECIPEDIR}/${repo}/${pkg}.yml 2>/dev/null | head -n 2 | tail -n1 | awk '{print $2}')
    if [[ $? != 0 || -z ${version} ]] ; then
        return 1
    fi
    echo "${version}"
    return 0
}

function check_local_version() {
    local version
    for repo in ${RECIPEDIR}/* ; do
        [[ ! -d ${repo} ]] && continue
        repo=$(basename ${repo})
        version=$(check_local_version_backend ${repo} ${1} 2>/dev/null)
        if [[ $? == 0 ]] ; then
            echo "${version}"
            return 0
        fi
    done
    return 1
}

for repo in ${RECIPEDIR}/* ; do
    for pkg in ${repo}/*.yml ; do
        repo=$(basename ${repo})
        pkg=$(basename ${pkg} | sed 's|.yml||')

        local_version=$(check_local_version_backend ${repo} ${pkg} 2>/dev/null)
        if [[ $? != 0 ]] ; then
            echo ":: Failed to get local version for ${repo}/${pkg}"
            continue
        fi
        archlinux_version=$(check_updates ${pkg} | tr -d '\n')
        if [[ ${PIPESTATUS[0]} != 0 ]] ; then
            echo ":: Failed to get version for ${pkg}"
            continue
        fi
        if [[ $local_version != ${archlinux_version} ]] ; then
            echo "${pkg}: ${local_version} -> ${archlinux_version}"
        fi
    done
done
