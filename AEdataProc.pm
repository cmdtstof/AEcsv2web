#!/usr/bin/perl -Ilib
package AEdataProc;
use warnings;
use strict;

=head1 AEdataProc

  Appenzeller-Energie.ch DataProcessor.


=head2 COMMENTS

  creates db, csv, tables for www from raw leistungsdata, 
  as showed on https://appenzeller-energie.ch/.

  data now comming from hand via csv...
  ...and more and more direct by emonpi <https://openenergymonitor.org/>


=head2 SYNOPSIS

    perl AEdataProc options


=head2 REQUIREMENTs

    perl (!) :-)
    and a proper config file for the desired profile.
    have a look on cfg_dev.pl
    

=head2 CRON

    example cron scripts can be found in ./bin 


=head2 CODE

  see you on github <https://github.com/cmdtstof/AEcsv2web>

=cut



##############################################################################
# what to use / require
#
use Utili::Dbgcmdt;
use Getopt::Long;

##############################################################################
# Define some constants / defaults
#
our $log;
our %config = (
	profile		=> "dev",  #default
	cfgDir		=> "cfg/",
	cfgApp		=> "cfg_app.pl", # general app config
	cfgProfile	=> "cfg_profile_",	#configs for choosen profile
);

##############################################################################
#what to do in dev (default) profile mode

my %doer = (
	setupDb			=> 0,	#1 if db is used
	testing			=> 0,	#1=do some testing
	createDb 		=> 0,   #1=create db (be careful!)
	migrateDb		=> 0,	#1=migrate db
	importDumps		=> 0,	#1=import db dumps from csv (1.version) >>> create db before!!!!
	importEmon   	=> 0,  	#1=import from emoncms db
	importRaw		=> 0,	#1=import raw data into db	
	prodCsv			=> 0,	# 1=create csv files
	prodTbl			=> 0,	# 1=produce tables
	#prodCharts		=> 0,	# 1=produce charts
	#prodPdf		=> 0,	# 1=produce pdf
	uploadFiles		=> 0,	# 1=upload files to fileserver
	writeQsError	=> 0,	#1=write qs errors to stderr
);


############# main ##################

#our $app = new($config{app}); 

getOptions();
getProfile();
setupLog();
	$log->logWrite($config{app}, "run with profile\t$config{profile}");

if ($doer{setupDb} ) { setupDb();}
if ($doer{testing}) { tester(); }
if ($doer{createDb}) { createDb(); }
if ($doer{migrateDb}) { migrateDb(); }
if ($doer{importDumps}) { importDumps(); }
if ($doer{importEmon}) { importEmon(); }
if ($doer{importRaw}) { importRaw(); }
if ($doer{prodCsv}) { prodCsv(); }
if ($doer{prodTbl}) { prodTbl(); }
if ($doer{uploadFiles}) { uploadFiles(); }

fin();
if ($doer{writeQsError}) { writeQsError(); }

#################fin##############


##############################################################################
# get options

=head2 OPTIONS

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
=cut

=head2 PROCESSING INFO

  data will be handled according to config settings and option settings.

=head3 --importemon

  - emonCMS data will be imported, according to "live" setting either to "arbeit" (live=1) or "arbeitemon" (live=0).
  - there is always a full import of emoncms data > changes will update AeDB.

=head3 --importraw

  - raw data will be imported from csv files and written to AeDB.
  - there is always a full import of raw data > changes will update AeDB.

=head3 import processing order

  manual changes of data can be done either in raw or emoncms,
  but must take note of the processing order:
  1. --importemon
  2. --importraw
  means, importraw overwrites importemon!

=cut



sub getOptions{
	GetOptions (
		"profile|p=s"	=> \$config{profile}, 
		"verbose"		=> \$config{verbose},
		"testing"		=> \$doer{testing},	
		"setupdb"		=> \$doer{setupDb},
		"createdb"		=> \$doer{createDb},
		"migratedb"		=> \$doer{migrateDb},
		"importdumps"	=> \$doer{importDumps},
		"importraw"		=> \$doer{importRaw},
		"importemon"	=> \$doer{importEmon},
		"csv"			=> \$doer{prodCsv},
		"tbl"			=> \$doer{prodTbl},
		"upload"		=> \$doer{uploadFiles},
		"wrtqserr"		=> \$doer{writeQsError},
	);
	return;
}

##############################################################################
# get profile data

sub getProfile{

	#app config
	my $cfgFilename = $config{cfgDir}. $config{cfgApp};
	my $cfg = do($cfgFilename);
	die "Error parsing config file: $@" if $@;
	die "Error reading config file: $!" unless defined $cfg;
	%config = (%config, %$cfg);

	#profile config
	$cfgFilename = $config{cfgDir}. $config{cfgProfile} . $config{profile} . ".pl";
	$cfg = do($cfgFilename);
	die "Error parsing config file: $@" if $@;
	die "Error reading config file: $!" unless defined $cfg;
	%config = (%config, %$cfg);

	return;
}

##############################################################################
# log
sub setupLog{
	require Utili::LogCmdtOO;
	
	$log = Utili::LogCmdtOO->new($config{writeLog}, $config{logFile}, $config{verbose}, $config{logAppend});
	$log->logOpen();
	$log->logWrite($config{app}, "start...");

	return;
}

################# testing ##################
sub tester{
		
	$log->logWrite($config{app}, "testing...");	
	
#Utili::Dbgcmdt::dumper(\%config);	
#Utili::Dbgcmdt::dumper(\%doer);

		Db::ImportEmon::tester();


#	die;

	return;
}




################### setup db ##################
sub setupDb{

	use Db::AeDb;
	Db::AeDb::dbOpen($config{dbAeType}, $config{dbAeHost}, $config{dbAePort}, $config{dbAeName}, $config{dbAeUser}, $config{dbAePwd});

#TODO set dataStatus from last date in db 
#	dataStatus	=> "02.03.2017", #date of the db dump
#TODO check db version and maybe migrate data	
#	$app->{log}->logWrite($app->{config}->{app}, "db data status ???");

	use Db::EmonDb;
	Db::EmonDb::dbOpen($config{'dbEmType'}, $config{'dbEmHost'}, $config{'dbEmPort'}, $config{'dbEmName'}, $config{'dbEmUser'}, $config{'dbEmPwd'});

	return;
}





################## create db ##################
sub createDb {
		Db::AeDb::createAnlagen();
		Db::AeDb::createArbeit();
}

################## migratge db ##################
sub migrateDb {
	Db::AeDb::migrateDb();
}

################## import sql dumps ##################
sub importDumps {

		Db::AeDb::insertCsvAnlagenFull();
#		Db::AeDb::insertCsvArbeitFull();

 }


################## import from raw files ##################
sub importRaw {

		use Db::ImportRaw;
		Db::ImportRaw::importRawArbeit();
}

################## import from emoncms ##################
sub importEmon {

		use Db::ImportEmon;
		Db::ImportEmon::importEmon();

}

################## create csv files ##################
sub prodCsv {

		use Prod::Csv;

		Prod::Csv::delFiles();  # del files before generating

#csv tot / anlage
		Prod::Csv::prodAnlageTot();

#csv für html-tbl
		Prod::Csv::prodGesamtAlleJahr();

#csv für diagramme
		Prod::Csv::prodAnlageJahr();
		Prod::Csv::prodAnlageMonate();
		Prod::Csv::prodAnlageTag();
		Prod::Csv::prodAnlageTagEmon(); #TODO remove after test phase
		Prod::Csv::prodAnlageTagCompare(); #TODO remove after test phase

#csv für diagram gesamtproduktion pro jahr
		Prod::Csv::prodGesamtJahr();

}



################## produce tables ##################
sub prodTbl {

		use Prod::Tbls;
		Prod::Tbls::delFiles(); # del files before generating
		Prod::Tbls::prodGesamtTbl(); #html tbl gesamtproduktion from csv!!!
#TODO generate html tbl from db

}

################## produce charts ##################
#	if ($ae_prodCharts) {
#		use Prod::Charts;
#		Prod::Charts::prodAnlageTag();
#	}


########### produce pdfs #################
#if ($ae_prodPdf) {
#		use Prod::Pdf;
#		Prod::Pdf::prodGesamtAlleJahr();
#		Prod::Pdf::tester();
#}




########### upload files #################
sub uploadFiles {
	use Utili::Rsyncer;
	Utili::Rsyncer::upload();
}

##############################################################################
#fin
sub fin{

	Db::AeDb::dbClose();
	Db::EmonDb::dbClose();
	$log->logWrite($config{app}, "...end");
	$log->logClose();

	return;
}

##############################################################################
# write QS Error
sub writeQsError {
	$log->logShowError();
	return;
}


#######################

1;

=head2 COPYRIGHT

2017 cmdt.ch L<http://cmdt.ch/>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
    
=cut
