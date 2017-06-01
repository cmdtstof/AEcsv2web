#!/bin/bash
#appenergie raw csv upload to server for processing on server

rawDir="/data/prod/appenergie/aedataproc/data/raw/*"
uploadDir="root@vps288538.ovh.net:/opt/appenergie/aedataproc/data/raw"


rsync -rvzuP --delete $rawDir $uploadDir
