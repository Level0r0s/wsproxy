#!/bin/bash

cd $(dirname $0)
docker run -d --name=wsproxy -p 80:80 -p 443:443 \
           -v $(pwd):/data wsproxy
