Web Server Proxy
================

If we want to host several domains/subdomains on the same webserver
we can use *name-based virtual hosting*. If we need to host these
domains/subdomains in different webservers, each one in its own
docker container, there is a problem because the ports 80/443 can
be used (exposed to the host) only by one of the containers.

In such a case the *Reverse Proxy* module of apache2 comes to the
rescue. We can have a docker container with apache2 that forwards
all the http requests to the other containers (webservers), behaving
like a kind of http gateway or hub. This is what **wsproxy** does.
