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
