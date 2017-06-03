#!/usr/bin/perl -Ilib
package AEdataProc;
use warnings;
use strict;

=head1 AEdataProc

Appenzeller-Energie.ch DataProcessor.

=head2 VERSIONS



=head2 COMMENTS

create db, csv, tables for www from raw leistungsdata


=head2 SYNOPSIS

    perl AEdataProc options
    
=cut


##############################################################################
# what to use / require
#
use Utili::Dbgcmdt;
use Getopt::Long;
#use Data::Dumper;


##############################################################################
# Define some constants / defaults
#
our $log;
our %config = (
	app			=> "AEdataProc",
	version		=> "0.4",
	profile		=> "dev",  
#	profile		=> "local", 
#	profile		=> "server", 
	
	writeLog	=> 1,
	logFile		=> "../log/logfile.csv",
	verbose		=> 1, #output also to stderr
	logAppend	=> 0, #1=append log

	fileDbScvAnlagen	=> "ae_anlagen_db_import.csv",
	fileDbCsvArbeit		=> "ae_arbeit_db_import_", #ae_arbeit_db_import_furth.csv
	fileRawArbeit		=> "ae_raw_",
	fileGesamt 			=> "dataGesamt_",    #dataGesamt_2015.csv > dataGesamt_2015.html
	fileGesamtTotal		=> "dataGesamtTotal",	#gesamtproduktion aller analgen pro jahr
	fileAnlageJahr 		=> "dataJahr_",	#Jahresproduktion_furth.csv
	fileAnlageMonat		=> "dataMonat_",
	fileAnlageTag		=> "dataTag_",
	fileAnlageTagEmon	=> "dataTagEmon_", # for arbeitemon compare test phase
	fileAnlageTagDiff	=> "dataTagDiff_", #data/dataTagDiff_furth.csv
	fileAnlageTot		=> "dataTot_",

	sep_char			=> ";",
	emptyValue		=> "&nbsp;",		# empty values will be filled with this


);


##############################################################################
#what do do in dev (default) profile mode

my %doer = (
	setupDb			=> 0,	#1 if db is used
	testing			=> 0,	#1=do some testing
	createDb 		=> 0,   #1=create db
	migrateDb		=> 0,	#1=migrate db
	importDumps		=> 0,	#1=import db dumps from csv (1.version) >>> create db !!!!
	importRaw		=> 0,	#1=import raw data into db
	importEmon   	=> 0,  	#1=import from emoncms db
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
if ($doer{importRaw}) { importRaw(); }
if ($doer{importEmon}) { importEmon(); }
if ($doer{prodCsv}) { prodCsv(); }
if ($doer{prodTbl}) { prodTbl(); }
if ($doer{uploadFiles}) { uploadFiles(); }

fin();
if ($doer{writeQsError}) { writeQsError(); }

#################fin##############


##############################################################################
#not used!
sub new{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	$self->{config}	= \%config;
	$self->{doer}	= \%doer;
#	$self->{dba}	= {};
	return $self;
}

##############################################################################
# get options

=head2 OPTIONS

 [--profile test]	= default
 [--profile local]	= data processing on local maschine and upload to webserver
 [--profile server]	= perl code on webserver    
 [--setupDb]		= setup dbs
 [--verbose]		= show comment on screen
 [--testing]		= some testing
 [--createdb]		= creates new db
 [--migratedb]		= migrates db		
 [--importdumps]	= import dbdump into db
 [--importraw]		= import csv data into db
 [--importemon]		= import data from emoncms into db
 [--csv]			= creates csv from data
 [--tbl]			= creates html tables from data
 [--upload]			= uploads/moves data to webserver dir
 [--wrtqserr]		= write QS errors to stderr
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


if ($config{profile} eq "local") {
# codebase (ie): /data/prod/appenergie/aedataproc/scr/
	$config{outputDir}		= "/data/bodies/appenergie/website/www_new/data/";
	$config{wwwDataDir}		= 'root@vps288538.ovh.net:/var/www/appenergie/data';
	$config{dbImportDumps}	= "../data/dumps/";
	$config{rawDataDir}		= "../data/raw/";
	
	$config{dbAeType}		= "sqlite";
	$config{dbAeHost}		= "";
	$config{dbAePort}		= "";
	$config{dbAeName}		= "../data/db/sqlite/appenergie.db";
	$config{dbAeUser}		= "";
	$config{dbAePwd}		= "";
	


#dev	
} elsif ($config{profile} eq "dev") {

	$config{outputDir}   	= "../datatest/output/";
	$config{wwwDataDir}		= "../datatest/www";
	$config{dbImportDumps}	= "../datatest/dumps/";
	$config{rawDataDir}		= "../datatest/raw/";
	
	$config{dbAeType}		= "sqlite"; #Aedb
	$config{dbAeHost}		= "";
	$config{dbAePort}		= "";
	$config{dbAeName}		= "../datatest/db/test.db";
	$config{dbAeUser}		= "";
	$config{dbAePwd}		= "";
	
	$config{dbEmType}		= "mysql"; #emoncms
	$config{dbEmHost}		= "emoncms"; #emoncms.rosslan.home
	$config{dbEmPort}		= "3306";
	$config{dbEmName}		= "emoncms";
	$config{dbEmUser}		= "emoncms";
	$config{dbEmPwd}		= "emoncms";

#server
} elsif ($config{profile} eq "server") {
# codebase (ie): /opt/appenergie/aedataproc/scr/
# run: /opt/appenergie/aedataproc/scr/bin/*.sh

	$config{outputDir}   	= "../data/output/";
	$config{wwwDataDir}		= "/var/www/appenergie/data";	
	$config{dbType}			=	"mysql";
	$config{rawDataDir}		= "../data/raw/";

	$config{dbAeType}		= "sqlite"; #Aedb
	$config{dbAeHost}		= "";
	$config{dbAePort}		= "";
	$config{dbAeName}		= "../data/db/sqlite/appenergie.db";
	$config{dbAeUser}		= "";
	$config{dbAePwd}		= "";

	$config{dbEmType}		= "mysql"; #emoncms
	$config{dbEmHost}		= "localhost";
	$config{dbEmPort}		= "3306";
	$config{dbEmName}		= "emoncms";
	$config{dbEmUser}		= "emon";
	$config{dbEmPwd}		= "uOcl3UchAJI8NEZKQBZg";
	
} else {  #else error!
	die("Error wrong profile\n");
}
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
Utili::Dbgcmdt::dumper(\%doer);


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
		Db::ImportEmon::importNotImported();

}

################## create csv files ##################
sub prodCsv {

		use Prod::Csv;

#TODO del file before write

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

Copyright 2017 cmdt.ch L<http://cmdt.ch/>. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
    
=cut
