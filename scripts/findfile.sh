#!/bin/sh

for i in $(find build/${VERSION}/pkgs/ -type f -name "*.pkg") $(find build/${VERSION}/pkgs/ -type f -name "*.rlx") ; do
    tar -taf ${i} | grep "${1}" && \
        echo "Found in ${i}"
done