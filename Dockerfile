FROM ubuntu:14.04
RUN export DEBIAN_FRONTEND=noninteractive; apt-get update; apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 supervisor vim

### Copy the source code and run the installer.
COPY . /usr/local/src/wsproxy/
ENV code_dir /usr/local/src/wsproxy
WORKDIR /usr/local/src/wsproxy/
RUN ["./config.sh"]

### Set the default command to run in the container.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]

