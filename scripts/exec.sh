#!/bin/sh

BASEDIR="$(dirname $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P ))"
composefile=${composefile:-${BASEDIR}/docker/docker-compose.yml}

function startService() {
    echo "starting service ${composefile}"
    docker-compose -f ${composefile} up -d
}

container_id=$(docker-compose -f ${composefile} ps -q)
[[ -z ${container_id} ]] && startService

container_id=$(docker-compose -f ${composefile} ps -q)

do_exec() {
    docker exec -it ${container_id} /bin/env -i \
        HOME=/root \
        TERM=$TERM \
        PS1='(docker) \u:\w\$ ' \
        PATH=/usr/bin:/opt/bin:/tools/bin \
        $@
}

do_exec $@
