#!/bin/bash -x

### customize the shell prompt
echo wsproxy > /etc/debian_chroot
sed -i /root/.bashrc \
    -e '/^#force_color_prompt=/c force_color_prompt=yes'
PS1='\\n\\[\\033[01;32m\\]${debian_chroot:+($debian_chroot)}\\[\\033[00m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\e[32m\\]\\n==> \\$ \\[\\033[00m\\]'
sed -i /root/.bashrc \
    -e "/^if \[ \"\$color_prompt\" = yes \]/,+2 s/PS1=.*/PS1='$PS1'/"

### copy config files over to the system
dir=$(dirname $0)
cp -TdR $dir/config/ /

### configure apache2
a2enmod ssl proxy proxy_http proxy_connect proxy_balancer cache headers rewrite
a2dissite 000-default
a2ensite bcl bcl-ssl btr btr-ssl

### generates the file /etc/defaults/locale
update-locale
