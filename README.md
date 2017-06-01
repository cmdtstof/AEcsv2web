[1mAEdataProc[0m
    Appenzeller-Energie.ch DataProcessor.

  [1mVERSIONS[0m
  [1mCOMMENTS[0m
    create db, csv, tables for www from raw leistungsdata

  [1mSYNOPSIS[0m
        perl AEdataProc options

  [1mOPTIONS[0m
     [--profile test]       = default
     [--profile local]      = data processing on local maschine and upload to webserver
     [--profile server]     = perl code on webserver    
     [--setupDb]            = setup dbs
     [--verbose]            = show comment on screen
     [--testing]            = some testing
     [--createdb]           = creates new db
     [--migratedb]          = migrates db           
     [--importdumps]        = import dbdump into db
     [--importraw]          = import csv data into db
     [--importemon]         = import data from emoncms into db
     [--csv]                        = creates csv from data
     [--tbl]                        = creates html tables from data
     [--upload]                     = uploads/moves data to webserver dir
     [--wrtqserr]           = write QS errors to stderr

  [1mCOPYRIGHT[0m
    Copyright 2017 cmdt.ch <http://cmdt.ch/>. All rights reserved.

    This library is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

