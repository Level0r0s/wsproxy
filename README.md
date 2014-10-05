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

 + Customize the sites configuration on `config/etc/apache2/`.

 + For each container (webserver) find out its IP, like this:

   `docker inspect -f '{{ .NetworkSettings.IPAddress }}' ws1`

   Then update `config/etc/hosts` accordingly.

 + Build the docker image with the command `build.sh`, then create a container with the command `run.sh`.

In case that webservers have changed, update the configurations on
`config/etc/apache2/` and `config/etc/hosts`, and restart wsproxy:
`docker restart wsproxy`.


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

It is important to note that without a line like this on `/etc/hosts`:
`172.17.0.3 example.org`, apache2 would not know where to forward the
request.

Also these apache2 modules have to be enabled:
```
a2enmod ssl proxy proxy_http proxy_connect proxy_balancer cache headers rewrite
```
