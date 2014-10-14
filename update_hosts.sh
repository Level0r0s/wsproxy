#!/bin/bash

### got to the script directory
cd $(dirname $0)

### cleanup the previous entries from /etc/hosts
sed -i config/etc/hosts -e '/^### containers/,$ d'

### add new entries to /etc/hosts
echo "### containers" >> config/etc/hosts
while read line
do
    ### skip empty lines and comments
    test -z "$line" && continue
    test ${line:0:1} = '#' && continue

    ### get the container name and domain
    container=$(echo $line | cut -d: -f1)
    domains=$(echo $line | cut -d: -f2)
    test -z "$container" && continue
    test -z "$domains" && continue

    ### get the ip of the container
    ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $container)
    test -z "$ip" && continue

    ### add a new entry for this ip
    echo "$ip $domains" >> config/etc/hosts
    echo "$ip $domains"
done < hosts.txt
