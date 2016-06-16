#!/bin/bash

args="$@"
docker exec -it wsproxy env TERM=xterm \
    script /dev/null -c "/data/get-ssl-cert $args" -q
