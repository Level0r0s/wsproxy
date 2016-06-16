#!/bin/bash

usage() {
    echo "Usage: $0 <email> <domain>... [-t,--test]"
    exit 0
}

cd $(dirname $0)

### get the options and arguments
test=0
opts="$(getopt -o t -l test -- "$@")"
err=$?
eval set -- "$opts"
while true; do
    case $1 in
        -t|--test) test=1; shift ;;
        --) shift; break ;;
    esac
done
[[ $err == 0 ]] || usage

email=$1 ; shift
[[ -n $email ]] || usage

domains="$@"
[[ -n $domains ]] || usage

### build the certbot args
args="certonly --webroot -m $email --agree-tos -w /var/www"
for domain in $domains; do
    args+=" -d $domain"
done
[[ $test == 1 ]] && args+=" --dry-run"

### run certbot from inside the container
docker exec -it wsproxy env TERM=xterm \
    script /dev/null -c "certbot $args" -q

[[ $test == 1 ]] && exit 0

### update config files
first_domain=$(echo $domains | cut -d' ' -f1)
if [[ -d letsencrypt/live/$first_domain ]]; then
    certdir=/etc/letsencrypt/live/$first_domain
    for domain in $domains; do
        sed -i config/etc/apache2/sites-available/$domain-ssl.conf -r \
            -e "s|#?SSLCertificateFile .*|SSLCertificateFile      $certdir/cert.pem|" \
            -e "s|#?SSLCertificateKeyFile .*|SSLCertificateKeyFile   $certdir/privkey.pem|" \
            -e "s|#?SSLCertificateChainFile .*|SSLCertificateChainFile $certdir/chain.pem|"
    done
fi

### update config files
./reload.sh
