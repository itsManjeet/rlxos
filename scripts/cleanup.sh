#!/bin/sh

# TODO: better way to cleanup these

if [[ -z ${CACHE_PATH} ]] ; then
    echo "No cache path povided"
    exit 1
fi

rm -f ${CACHE_PATH}/cache/system-repo-*.pkg*
rm -f ${CACHE_PATH}/cache/system-deps-*.pkg*
rm -f ${CACHE_PATH}/cache/installer-image-*.pkg*
rm -f ${CACHE_PATH}/cache/apps-*.pkg*