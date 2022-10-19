#!/bin/sh

. /lib/dracut-lib.sh

# validate_path <path>
# validate path string and remove '//' from path
validate_path() {
    local _path="$1"
    local _temp=""
    while [ "${_path#*//}" != "${_path}" ]; do
        _temp="${_path#*//}"
        _path="${_path%%//*}/${_temp}"
    done
}

# rewrite the fstab for overlay
update_fstab() {
    local input="$1" root_ro="${2:-/run/sysroot}"
    local root_rw="${3:-/run/root-rw}" dir_prefix="${4:-/root}"
    local recurse=${5:-1} swap=${6:-0} fstype=${7:-overlay}
    local hash="#" oline="" ospec="" upper="" dirs="" copy_opts=""
    local spec file vfstype opts pass freq line ro_line
    local workdir="" use_orig="" relfile="" needs_workdir=true

    [ -f "$input" ] || return 1

    while read spec file vfstype opts pass freq; do
        line="$spec $file $vfstype $opts $pass $freq"
        case ",$opts," in
        *,ro,*) ro_opts="$opts" ;;
        *) ro_opts="ro,${opts}" ;;
        esac
        ro_line="$spec ${root_ro}$file $vfstype ${ro_opts},nofail $pass 0"

        use_orig=""
        if [ "${spec#${hash}}" != "$spec" ]; then
            use_orig="comment"
        elif [ -z "$freq" ]; then
            use_orig="malformed-line"
        else
            case "$vfstype" in
            vfat | fat) use_orig="fs-unsupported" ;;
            proc | sysfs | tmpfs | dev | devpts | udev) use_orig="fs-virtual" ;;
            esac
        fi

        rel_file=${file#/}
        if [ -n "$use_orig" ]; then
            if [ "$use_orig" != "comment" ]; then
                echo "$line # $MYTAG:$use_orig"
            else
                echo "$line"
            fi
        elif [ "$vfstype" = "swap" ]; then
            if [ "$swap" = "0" ]; then
                # comment out swap lines
                echo "#$MYTAG:swap=${swap}#${line}"
            elif [ "${spec#/}" != "${spec}" ] &&
                [ "${spec#/dev/}" = "${spec}" ]; then
                # comment out swap files (spec starts with / and not in /dev)
                echo "#$MYTAG:swapfile#${line}"
            else
                echo "${line}"
            fi
        elif [ "$file" = "/" ]; then
            #ospec="${root_ro}${file}"
            ospec="${fstype}"
            copy_opts=""
            [ "${opts#*nobootwait*}" != "${opts}" ] &&
                copy_opts=",nobootwait"
            clean_path "${root_rw}/${dir_prefix}${file}"
            upper="$_RET"

            oline="${ospec} ${file} $fstype "
            clean_path "${root_ro}${file}"
            oline="${oline}lowerdir=$_RET"
            oline="${oline},upperdir=${upper}${copy_opts}"
            if [ "$fstype" = "overlayfs" -o "$fstype" = "overlay" ] &&
                ${needs_workdir}; then
                workdir="${root_rw}/workdir"
                oline="${oline},workdir=$workdir"
                dirs="${dirs} $workdir"
            fi
            oline="${oline} $pass $freq"

            if [ "$recurse" != "0" ]; then
                echo "$ro_line"
                echo "$oline"
                dirs="${dirs} ${upper}"
            else
                echo "$line"
                [ "$file" = "/" ] && dirs="${dirs} ${upper}"
            fi
        else
            echo "${line}"
        fi
    done <"$input"
    _RET=${dirs# }

}

mkdir -p /run/roots      || echo Fail create ro dir

mount --make-private ${NEWROOT} 2>>/run/.overlayroot.log
mount --make-private /          2>>/run/.overlayroot.log
mount --make-private /run       2>>/run/.overlayroot.log

mount --move ${NEWROOT} /run/roots 2>>/run/.overlayroot.log
if [ $? != 0 ] ; then
    echo Failed to move $NEWROOT to /run/roots
    return 1
fi

[ -d /run/roots/cache ] || mkdir -p /run/roots/cache
[ -d /run/roots/.work ] || mkdir -p /run/roots/.work

mount -t overlay -o lowerdir=/run/roots/sysroot,upperdir=/run/roots/cache,workdir=/run/roots/.work overlay $NEWROOT 
if [ $? != 0 ] ; then
    echo Failed to mount overlay root filesystem
    return 1
fi

mkdir -p /sysroot/run/roots
mount --move /run/roots /sysroot/run/roots

update_fstab /sysroot/run/roots/sysroot/etc/fstab > /sysroot/etc/fstab