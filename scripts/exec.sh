#!/bin/sh

BASEDIR="$(dirname $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P ))"
composefile=${composefile:-${BASEDIR}/docker/docker-compose.yml}

container_id=$(docker-compose -f ${composefile} ps -q)

[ -z ${NONINTERACTIVE} ] && _docker_flags='-it'

do_exec() {
    docker exec --privileged ${_docker_flags} ${container_id} /bin/env -i \
        HOME=/root \
        TERM=$TERM \
        PS1='(docker) \u:\w\$ ' \
        PATH=/usr/bin:/opt/bin:/tools/bin \
        $@
}

do_exec $@
