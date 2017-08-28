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

    [--profile <name>] = default = "dev", will be read cfg_dev.pl in root
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

## COPYRIGHT

Copyright 2017 cmdt.ch [http://cmdt.ch/](http://cmdt.ch/). All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
