#!/bin/bash -x
### Remove one or more domains from the configuration of the web proxy.

### get the domains
if [ $# -lt 1 ]
then
    echo "Usage: $0 <domain> <domain> ..."
    exit 1
fi
domains="$@"

### get the directory of the script
cd $(dirname $0)
wsproxy=$(pwd)

### remove apache2 config files for each domain
cd $wsproxy/config/etc/apache2/
for domain in $domains
do
    rm -f sites-available/$domain.conf
    rm -f sites-available/$domain-ssl.conf
    rm -f sites-enabled/$domain.conf
    rm -f sites-enabled/$domain-ssl.conf
done

### remove the domains from hosts.txt
for domain in $domains
do
    sed -i $wsproxy/hosts.txt -e "/ $domain/d"
done

### reload the configuration of wsproxy
$wsproxy/reload.sh

