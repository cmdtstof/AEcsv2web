#!/bin/bash

cd /data/bodies/appenergie/scr/scr/

perl AEdataProc.pm \
--profile dev \
--setupdb \
--importemon \
--csv \
--upload

