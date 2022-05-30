#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

ROOT_DIR=${ROOT_DIR:-${BASEDIR}}

trap "{ echo 'Terminated' ; exit 1; }" SIGINT

for repo in core extra apps fonts ; do
    repo_dir="${ROOT_DIR}/recipes/${repo}"
    [[ -d ${repo_dir} ]] || continue

    echo "compiling ${repo} packages"
    for pkg in ${repo_dir}/*.yml ; do
        echo "compiling ${pkg}"
        recipe_file="recipes/${repo}/$(basename ${pkg})"
        ${ROOT_DIR}/scripts/pkgupd-build.sh ${recipe_file}
        echo "failed: ${pkg}"
    done
done
