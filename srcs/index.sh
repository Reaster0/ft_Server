#!/bin/bash

if [ "$1" = "1" ]; then
cp /nginxconf /etc/nginx/sites-available/localhost
else
  cp /nginxconf_no_index /etc/nginx/sites-available/localhost
fi
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/