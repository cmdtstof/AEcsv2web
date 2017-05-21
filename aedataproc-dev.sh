#!/bin/bash
# start script for AppEnergie profile "dev"

perl /data/bodies/appenergie/scr/scr/AEdataProc.pm \
--profile dev \
--setupdb \
--importraw \
--importemon \
--csv \
--tbl \
--upload
