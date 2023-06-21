#!/bin/sh

set -e
set -f # disable path expansion
REMOUNTS=""

error() {
    printf "ERROR: $@\n" 1>&2
}
fail() {
    [ $# -eq 0 ] || error "$@"
    exit 1
}

info() {
    printf "INFO: $@\n" 1>&2
}

get_lowerdir() {
    local overlay=""
    overlay=$(awk \
        '$1 == "overlay" && $2 == "/" { print $0 }' /proc/mounts)
    if [ -n "${overlay}" ]; then
        lowerdir=${overlay##*lowerdir=}
        lowerdir=${lowerdir%%,*}
        if mountpoint "${lowerdir}" >/dev/null; then
            _RET="${lowerdir}"
        else
            fail "Unable to find the overlay lowerdir"
        fi
    else
        fail "Unable to find an overlay filesystem"
    fi
}

clean_exit() {
    local mounts="$1" rc=0 d="" lowerdir="" mp=""
    for d in ${mounts}; do
        if mountpoint ${d} >/dev/null; then
            umount ${d} || rc=1
        fi
    done
    for mp in $REMOUNTS; do
        mount -o remount,ro "${mp}" ||
            error "Note that [${mp}] is still mounted read/write"
    done
    [ "$2" = "return" ] && return ${rc} || exit ${rc}
}

# Try to find the overlay filesystem
get_lowerdir
lowerdir=${_RET}

recurse_mps=$(awk '$1 ~ /^\/dev\// && $2 ~ starts { print $2 }' \
    starts="^$lowerdir/" /proc/mounts)

mounts=
for d in proc dev run sys; do
    if ! mountpoint "${lowerdir}/${d}" >/dev/null; then
        mount -o bind "/${d}" "${lowerdir}/${d}" || fail "Unable to bind /${d}"
        mounts="$mounts $lowerdir/$d"
        trap "clean_exit \"${mounts}\" || true" EXIT HUP INT QUIT TERM
    fi
done

# Remount with read/write
for mp in "$lowerdir" $recurse_mps; do
    mount -o remount,rw "${mp}" &&
        REMOUNTS="$mp $REMOUNTS" ||
        fail "Unable to remount [$mp] writable"
done
info "Chrooting into [${lowerdir}]"
chroot ${lowerdir} "$@"

# Clean up mounts on exit
clean_exit "${mounts}" "return"
trap "" EXIT HUP INT QUIT TERM

# vi: ts=4 noexpandtab
