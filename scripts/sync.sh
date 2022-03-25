#!/bin/bash

VERSION=${VERSION:-$(cat .version)}

for repo in build/${VERSION}/pkgs/* ; do
    [[ ! -d ${repo} ]] && continue
    echo "syncing $(basename ${repo})"
    pkgupd gen-sync ${VERSION} ${repo}
done