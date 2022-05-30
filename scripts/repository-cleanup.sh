#!/bin/bash

PKGS=" "

echo ":: scanning deprecated packages ::"
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

ALL_PKGS=$(cd build/2200/pkgs; find . -not -name "*.digest" -not -name "meta" -not -name "recipe" | sed 's|\./||g' | sort)
REQUIRED_PKGS=$(echo ${PKGS} | sort)

TO_REMOVE=""
for i in ${ALL_PKGS} ; do
    if [[ ${REQUIRED_PKGS} =~ "${i}" ]] ; then
        continue
    else
        TO_REMOVE+=" ${i}"
    fi
done

[[ -z ${TO_REMOVE} ]] && {
    echo "no deprecated package found"
    exit 0
}
echo ${TO_REMOVE} | tr ' ' '\n'

echo ":: Found $(echo ${TO_REMOVE} | tr ' ' '\n'| wc -l) extra packages"
echo "Type 'yes' to cleanup these packages"
read v
if [[ $v ==  "yes" ]] ; then
    for i in ${TO_REMOVE} ; do
        rm -f build/2200/pkgs/${i} -v
    done
fi