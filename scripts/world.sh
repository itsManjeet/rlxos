#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

STORAGE_DIR=${STORAGE_DIR:-${BASEDIR}/build}

trap "{ echo 'Terminated' ; exit 1; }" SIGINT

for repo in core extra apps fonts ; do
    repo_dir="${STORAGE_DIR}/../recipes/${repo}"
    [[ -d ${repo_dir} ]] || continue

    echo "compiling ${repo} packages"
    for pkg in ${repo_dir}/*.yml ; do
        echo "compiling ${pkg}"
        recipe_file="recipes/${repo}/$(basename ${pkg})"
        ${STORAGE_DIR}/../scripts/pkgupd-build.sh ${recipe_file}
        [[ $? != 0 ]] && exit 1
    done
done
