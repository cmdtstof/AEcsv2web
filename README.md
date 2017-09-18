# AEdataProc

    Appenzeller-Energie.ch DataProcessor.

## COMMENTS

    creates db, csv, tables for www from raw leistungsdata, 
    as showed on https://appenzeller-energie.ch/.

    data now comming from hand via csv...
    ...and more and more direct by emonpi <https://openenergymonitor.org/>

## SYNOPSIS

    perl AEdataProc options

## REQUIREMENTs

    perl (!) :-)
    and a proper config file for the desired profile.
    have a look on cfg_dev.pl
    

## CRON

    example cron scripts can be found in ./bin 

## CODE

    see you on github <https://github.com/cmdtstof/AEcsv2web>

## OPTIONS

    [--profile <name>] = default = "dev". cfg_profile_dev.pl will overwrite cfg_app.pl
    [--createdb]       = creates new db (something like "MVC")
    [--setupDb]        = starts databases
    [--verbose]        = shows comments on STDOUT
    [--testing]        = for testing purpose
    [--migratedb]      = migrates db               
    [--importdumps]    = import dbdump into db
    [--importraw]      = import csv data into db
    [--importemon]     = import data from emoncms into db
    [--csv]            = creates csv from data
    [--tbl]            = creates html tables from data
    [--upload]         = uploads data to server dir
    [--wrtqserr]       = prints log "QS ERROR" to STDOUT

## PROCESSING INFO

    data will be handled according to config settings and option settings.

### --importemon

    - emonCMS data will be imported, according to "live" setting either to "arbeit" (live=1) or "arbeitemon" (live=0).
    - there is always a full import of emoncms data > changes will update AeDB.

### --importraw

    - raw data will be imported from csv files and written to AeDB.
    - there is always a full import of raw data > changes will update AeDB.

### import processing order

    manual changes of data can be done either in raw or emoncms,
    but must take note of the processing order:
    1. --importemon
    2. --importraw
    means, importraw overwrites importemon!

## COPYRIGHT

2017 cmdt.ch [http://cmdt.ch/](http://cmdt.ch/)

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
