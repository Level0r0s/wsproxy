#!/bin/bash
# restart apache if it is down

if ! /usr/bin/pgrep apache2
then
    date >> /apachemonitor.log
    rm /var/run/apache2/apache2.pid
    /etc/init.d/apache2 restart
fi
