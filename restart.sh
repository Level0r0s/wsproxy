#!/bin/bash -x

cd $(dirname $0)
./update_hosts.sh
docker restart wsproxy

