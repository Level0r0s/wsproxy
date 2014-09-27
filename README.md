Web Server Proxy
----------------

If we want to host several domains/subdomains on the same webserver
we can use *name-based virtual hosting*. If we need to host these
domains/subdomains in different webservers, each one in its own
docker container, there is a problem because the ports 80/443 can
be used (exposed to the host) only by one of the containers.

In such a case the *Reverse Proxy* module of apache2 comes to the
rescue. We can have a docker container with apache2 that forwards
all the http requests to the other containers (webservers), behaving
like a kind of http gateway or hub. This is what **wsproxy** does.

Usage
-----

 + Get the code from github: `git clone https://github.com/dashohoxha/wsproxy`

 + Make sure that the container of each webserver has been created, using commands like this:

   `docker run -d --name=ws1 --hostname=example.org webserver-1`

   Note that no HTTP ports are exposed to the host (for example using options `-p 80:80 -p 443:443`).

 + Customize the configuration of the domains on `config/etc/apache2/sites-available/`.
   Fix also the scripts `config.sh` and `run.sh` to reflect the change of domains.

 + Build the docker image with the command `build.sh`, then create a container with the command `run.sh`.

In case that web servers have changed, update the configurations and do again:

    ./rm.sh
    ./build.sh
    ./run.sh

Alternatively, do these:

 1. Enter the container: `docker-enter wsproxy`
 2. Make the neccessary configurations on `/etc/apache2/sites-enabled` and on `/etc/hosts`.
 3. Restart apache2: `supervisorctl restart apache2`.

**Note:** The command `docker-enter` can be installed like this:
`docker run -v /usr/local/bin:/target jpetazzo/nsenter`


How it works
------------

HTTP requests for a domain are redirected to HTTPS with a
configuration like this:
```
<VirtualHost *:80>
	ServerName example.org
	RedirectPermanent / https://example.org/
</VirtualHost>
```

HTTPS requests are forwarded to another webserver/container with a
configuration like this:
```
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerName example.org
		ProxyPass / https://example.org/
		ProxyPassReverse / https://example.org/

		ProxyRequests off

		SSLEngine on
		SSLCertificateFile     /etc/ssl/certs/ssl-cert-snakeoil.pem
		SSLCertificateKeyFile  /etc/ssl/private/ssl-cert-snakeoil.key

		SSLProxyEngine on
		SSLProxyVerify none
		SSLProxyCheckPeerCN off
		SSLProxyCheckPeerName off

		BrowserMatch "MSIE [2-6]" \
				nokeepalive ssl-unclean-shutdown \
				downgrade-1.0 force-response-1.0
		BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

	</VirtualHost>
</IfModule>
```

It is important to note that the parameter `--link=bcl:example.org`
that is passed to `docker run`, adds automatically a line like this
on `/etc/hosts` of **wsproxy**:
```
172.17.0.3      example.org
```
Without this, apache2 would not know where to forward the request,
or it might result in an endless loop if the domain is a real one.

Also these apache2 modules have to be enabled:
```
a2enmod ssl proxy proxy_http proxy_connect proxy_balancer cache headers rewrite
```
