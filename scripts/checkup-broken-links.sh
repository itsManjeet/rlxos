#!/bin/sh

for path in ${PATH//:/ } ; do
    for bin in $path/* ; do
        ldd $bin 2>&1 | grep -q "not found"
        if [ $? -eq 0 ] ; then
            echo "$bin has broken dependencies"
        fi
    done
done

for lib in $(find /usr/lib/ -type f -name "*.so") ; do
    ldd $lib 2>&1 | grep -q "not found"
    if [ $? -eq 0 ] ; then
        echo "$lib has broken dependencies"
    fi
done
