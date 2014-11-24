#!/bin/bash -x
### Reload the new configuration.

### update config/etc/hosts
cd $(dirname $0)
./update_hosts.sh

### update the configuration inside wsproxy
docker exec -t wsproxy rm -rf /etc/apache2/sites-available
docker exec -t wsproxy rm -rf /etc/apache2/sites-enabled
docker exec -t wsproxy cp -TdR /data/config/ /

### reload apache2 inside wsproxy
docker exec -t wsproxy /etc/init.d/apache2 reload
