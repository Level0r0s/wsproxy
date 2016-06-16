FROM ubuntu-upstart:14.04

RUN apt-get update; apt-get -y upgrade
RUN apt-get -y purge openssh-server openssh-client ; apt-get -y autoremove
RUN apt-get -y install vim apache2 wget

# install certbot
RUN wget https://dl.eff.org/certbot-auto; \
    chmod +x certbot-auto ; \
    mv certbot-auto /usr/local/bin/certbot ; \
    certbot --os-packages-only --non-interactive ; \
    certbot --version

COPY . /data/
RUN ["/data/config.sh"]
