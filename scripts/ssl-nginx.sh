#!/bin/bash

# Stop script on error
set -e 

NEXUS_DOMAIN="yourdomain.com"
NEXUS_DIR="/opt/nexus"

apt update
apt install nginx

cp nexus.conf /etc/nginx/sites-available/
cp ${NEXUS_DIR}/certs/* /etc/nginx/certs/


ln -s /etc/nginx/sites-available/nexus.conf /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx  


