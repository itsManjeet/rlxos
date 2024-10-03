#!/bin/sh

CACHE_PATH=$1
if [ -z "$CACHE_PATH" ] ; then
    echo "Usage: $0 <CACHE-PATH>"
    exit 1
fi

echo ":: cleaning target directory"
rm -rf "$CACHE_PATH"/target

echo ":: remove installation stamps"
find "$CACHE_PATH"/ -name ".stamp_target_installed" -delete
rm -rf "$CACHE_PATH"/build/host-gcc-final-*/.stamp_host_installed