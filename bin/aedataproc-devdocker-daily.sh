#!/bin/bash

perl AEdataProc.pm \
--profile devdocker \
--setupdb \
--importemon \
--csv \
--upload

