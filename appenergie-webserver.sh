#!/bin/bash
# start script for AppEnergie case appenergie

perl /data/appenergie/scr/scr/AppEnergie.pm \
--profile webserver \
--importraw \
--csv \
--tbl \
--upload


