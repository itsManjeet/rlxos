#!/bin/bash

PKGS=" "
VERSION=${VERSION:-"2200"}
LOGDIR=${LOGDIR:-"build/${VERSION}/logs/"}
STORAGE_DIR=${STORAGE_DIR:-"/home/itsmanjeet/storage.rlxos.dev"}

echo ":: scanning repositories ::"
for i in $(find recipes/ -type f -name "*.yml") ; do
    repo=$(echo ${i} | cut -d '/' -f2)
    id=$(cat ${i} | head -n1 | awk '{print $2}')
    version=$(cat ${i} | head -n2 | tail -n1 | awk '{print $2}' | tr -d "'" | tr -d '"')
    release=$(cat ${i} | grep '^release: ' | awk '{print $2}')
    [[ -z ${release} ]] || version="${version}-${release}"

    splits=$(cat ${i} | grep '^  - into: ' | cut -d ':' -f2)
    type=$(cat ${i} | grep '^type: ' | awk '{print $2}')
    [[ -z ${type} ]] && {
        cat ${i} | grep -q '^packages:' && type='rlx' || type='pkg'
    }
    PKGS+=" ${repo}/${id}-${version}.${type} "
    [[ -z ${splits} ]] || {
        for sp in ${splits} ; do
            PKGS+=" ${repo}/${sp}-${version}.${type} "
        done
    }
    unset type splits release
done

PKGS+=" "

ALL_PKGS=$(cd ${STORAGE_DIR}/; find . -not -name "*.digest" -not -name "meta" -not -name "recipe" -not -name "*.meta" -not -name "stable" -not -name "testing" | sed 's|\./||g' | sort)
REQUIRED_PKGS=$(echo ${PKGS} | sort)
FOUND_PACKAGES=""
MISSING_PACKAGES=""
TO_REMOVE=""

echo ":: listing deprecated packages ::"
for i in ${ALL_PKGS} ; do
    if [[ ${REQUIRED_PKGS} =~ "${i}" ]] ; then
        continue
    else
        TO_REMOVE+=" ${i}"
    fi
done

echo ":: listing missing packages ::"
for i in ${REQUIRED_PKGS} ; do
    if [[ ${ALL_PKGS} =~ "${i}" ]] ; then
        continue
    else
        MISSING_PACKAGES+=" ${i}"
    fi
done

if [[ -z ${TO_REMOVE} ]] ; then
    echo "no deprecated package found"
else
    echo ${TO_REMOVE} | tr ' ' '\n'

    echo ":: Found $(echo ${TO_REMOVE} | tr ' ' '\n'| wc -l) extra packages"
    echo "Type 'yes' to cleanup these packages"
    read v
    if [[ $v ==  "yes" ]] ; then
        for i in ${TO_REMOVE} ; do
            rm -f ${STORAGE_DIR}/${i} -v
        done
    fi
fi

if [[ -z ${MISSING_PACKAGES} ]] ; then
    echo "no missing package found"
else
    echo "${MISSING_PACKAGES}" | tr ' ' '\n'
    
    echo ":: Found $(echo ${MISSING_PACKAGES} | tr ' ' '\n' | wc -l) missing packages"
    echo "Type 'yes' to build these packages"
    read v
    if [[ $v == "yes" ]] ; then
        for i in ${MISSING_PACKAGES} ; do
            repository=$(echo $i | cut -d '/' -f1)
            pkgname=$(echo $i | cut -d '/' -f2 | rev | cut -d '-' -f2- | rev)
            recipefile="recipes/${repository}/${pkgname}.yml"

            echo ":: Building ${recipefile}"
            ./scripts/pkgupd-build.sh ${recipefile} | sed -r 's/\x1b\[[0-9;]*m//g' | tee ${LOGDIR}/${pkgname}.log
            if [[ ${PIPESTATUS[0]} != 0 ]] ; then
                echo ":: failed to build ${recipefile}"
                mv ${LOGDIR}/${pkgname}.{log,failed}
            fi
        done
    fi
fi
