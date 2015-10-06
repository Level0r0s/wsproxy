#!/bin/bash -x
### Add one or more domains to be served by the web proxy.

### get the container and the domains
if [ $# -lt 2 ]
then
    echo "Usage: $0 <container> <domain> <domain> ..."
    exit 1
fi
container=$1
shift
domains="$@"

### get the directory of the script
cd $(dirname $0)
wsproxy=$(pwd)

### remove these domains, if they exist
$wsproxy/domain-rm.sh $domains

### add apache2 config files for each domain
cd $wsproxy/config/etc/apache2/
for domain in $domains
do
    cp sites-available/{xmp.conf,$domain.conf}
    cp sites-available/{xmp-ssl.conf,$domain-ssl.conf}

    sed -i sites-available/$domain.conf \
        -e "s/example\.org/$domain/g"
    sed -i sites-available/$domain-ssl.conf \
        -e "s/example\.org/$domain/g"

    cd sites-enabled/
    ln -s ../sites-available/$domain.conf .
    ln -s ../sites-available/$domain-ssl.conf .
    cd ..
done

### add the domains on hosts.txt
echo "$container: $domains" >> $wsproxy/hosts.txt

### reload the configuration of wsproxy
$wsproxy/reload.sh

