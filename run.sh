#!/bin/bash

docker run -d --name=wsproxy -p 80:80 -p 443:443 \
           -v $(dirname $0):/data wsproxy
