#!/bin/bash
# start script for AppEnergie case prod (localhost > webserver)

cd /data/prod/appenergie/aegrapher/scr
git checkout master

perl AeGrapher.pm \
--profile prod \
--importraw \
--csv \
--tbl \
--upload


