#!/bin/bash
# start script for AppEnergie profile "server" import emon daily

perl /opt/appenergie/aedataproc/scr/AEdataProc.pm \
--profile server \
--setupdb \
--importemon \
--csv \
--tbl \
--upload
