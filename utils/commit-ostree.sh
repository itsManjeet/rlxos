#!/bin/bash

set -eu

gpg_opts=()
main_opts=()

help() {
    cat <<EOF
$0 [OPTIONS] REPO ELEMENT REF
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
	--gpg-*=*)
	    gpg_opts+=("$1")
	    ;;
	--gpg-*)
	    gpg_opts+=("$1" "$2")
	    shift
	    ;;
	--collection-id=*)
	    collection_id="${1#--collection-id=}"
	    ;;
	--collection-id)
	    collection_id="${2}"
	    shift
	    ;;
	--help)
	    help
	    exit 0
	    ;;
	--)
	    main_opts+=("$@")
	    shift $(($#-1))
	    ;;
	--*)
	    echo "Unknown option '$1'" 1>&2
	    exit 1
	    ;;
	-*)
	    for ((i=1;i < ${#1};++i)); do
		case "${1:i}" in
		    h)
			help
			exit 0
			;;
		    *)
			echo "Unknown option '${1:i}'" 1>&2
			exit 1
			;;
		esac
	    done
	    ;;
	*)
	    main_opts+=("$1")
	    ;;
    esac
    shift
done

if [ ${#main_opts[*]} -ne 3 ]; then
    echo "Wrong number of parameters" 1>&2
    exit 1
fi

OSTREE_REPO="${main_opts[0]}"
export OSTREE_REPO
element="${main_opts[1]}"
ref="${main_opts[2]}"

if [[ -f commit_body ]] ; then
	COMMIT_MESSAGE="--body-file commit_body"
fi

checkout="$(mktemp --suffix="-update-repo" -d -p "$(dirname "$(basename $OSTREE_REPO)")")"

on_exit() {
    rm -rf "${checkout}"
}
trap on_exit EXIT

${BST:-bst} -o variant ${VARIANT} build "${element}"
${BST:-bst} -o variant ${VARIANT} checkout --hardlinks "${element}" "${checkout}"

if ! [ -d "${OSTREE_REPO}" ]; then
    ostree init --repo="${OSTREE_REPO}" --mode=archive
fi

commit="$(ostree --repo="${checkout}" rev-parse "${ref}")"
ostree pull-local --repo="${OSTREE_REPO}" "${checkout}" "${commit}"

prev_commit="$(ostree rev-parse "${ref}" 2>/dev/null || true)"

ostree commit ${gpg_opts[*]} \
       --branch="${ref}" --tree=ref="${commit}" --skip-if-unchanged ${COMMIT_MESSAGE}

new_commit="$(ostree rev-parse "${ref}")"

if [ "${new_commit}" != "${prev_commit}" ]; then
    ostree prune --refs-only --keep-younger-than="6 months ago"

    if [ -n "${prev_commit}" ]; then
        ostree static-delta generate "${ref}"
    fi

    ostree summary \
           ${collection_id:+--add-metadata=ostree.deploy-collection-id='"'"${collection_id}"'"'} \
           ${gpg_opts[*]} \
           --update
fi
