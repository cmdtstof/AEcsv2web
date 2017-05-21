#!/bin/bash
# start script for AppEnergie profile "server"

perl /data/bodies/appenergie/scr/scr/AEdataProc.pm \
--profile server \
--setupdb \
--importraw \
--importemon \
--csv \
--tbl \
--upload


chown -R www-data:www-data /var/www/appenergie
chmod -R 755 /var/www/appenergie