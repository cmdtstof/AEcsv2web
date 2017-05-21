#!/bin/bash
# start script for AppEnergie profile "server" import emon daily

#!!!! --migratedb

perl /opt/appenergie/aedataproc/scr/AEdataProc.pm \
--profile server \
--verbose \
--setupdb \
--importemon \
--csv \
--tbl \
--upload


chown -R www-data:www-data /var/www/appenergie
chmod -R 755 /var/www/appenergie
