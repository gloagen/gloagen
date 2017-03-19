#!/bin/sh
nohup /opt/server/jboss/wildfy/10.1.0/bin/standalone.sh --server-config standalone-full.xml > ../logs/server-startup.log
>2&1 &
exit 0
