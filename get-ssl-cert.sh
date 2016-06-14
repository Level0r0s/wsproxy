#!/bin/bash

docker exec -it wsproxy env TERM=xterm \
    script /dev/null -c "get-ssl-cert $@" -q
