#!/bin/bash
# start script for AppEnergie profile "server"

cd /opt/appenergie/aedataproc/scr

perl AEdataProc.pm \
--profile server \
--setupdb \
--importraw \
--importemon \
--csv \
--tbl \
--upload


chown -R www-data:www-data /var/www/appenergie
chmod -R 755 /var/www/appenergie