#!/bin/bash

docker run -d --name=wsproxy \
    -p 80:80 -p 443:443 \
    --link=bcl:example.org \
    --link=btr:btr.example.org \
    wsproxy
