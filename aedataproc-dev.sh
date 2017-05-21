#!/bin/bash
# start script for AppEnergie profile "dev"


perl /data/bodies/appenergie/scr/scr/AEdataProc.pm \
--profile dev \
--verbose \
--testing 


# perl /data/bodies/appenergie/scr/scr/AEdataProc.pm \
# --profile dev \
# --verbose \
# --testing \
# --setupdb \
# --migratedb
# --importraw \
# --importemon \
# --csv \
# --tbl \
# --upload \
# --wrtqserr
