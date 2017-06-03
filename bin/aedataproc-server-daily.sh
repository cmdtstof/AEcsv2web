#!/bin/bash
# start script for AppEnergie profile "server" import emon daily

cd /opt/appenergie/aedataproc/scr

perl AEdataProc.pm \
--profile server \
--setupdb \
--importemon \
--csv \
--upload


chown -R www-data:www-data /var/www/appenergie
chmod -R 755 /var/www/appenergie
