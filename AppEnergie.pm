#!/usr/bin/perl -Ilib

##AEcsv2web##############################################
# Appenzeller-Energie.ch DataProcessor
#
# create db, csv, tables for www from raw leistungsdata
#
# uses different profiles (ae_case):
# - test
# - appenergie (local processing and rsync to webserver)
# - webserver (processing on webserver)
#
# info (ät) cmdt.ch
#

#TODO sensible data in config file and not versioned


package AppEnergie;
use warnings;
use strict;
#use Data::Dumper;

use Getopt::Long;

##############################################################################
# Define some constants / defaults
#

my $ae_case = "dev";
#my $ae_case = "prod"; # localhost > webserver
#my $ae_case = "webserver"; #perl code direct on webserver

our $ae_dataStatus 		= "20.03.2015";    	# date of the db dump
#TODO set dataStatus from last date in db
our $ae_writeLog 		= 1;				#1=write logfile and entries
our $ae_stderrOutput 	= 1; 				# 1=logfile output will also be sended to stderr
our $ae_logDir			= "../log/";
our $ae_logfile = $AppEnergie::ae_logDir . "logfile.csv";
our $ae_outputDir; # outputdir csv, pdf, ...
our $ae_wwwDataDir; #upload dir for data
our $ae_db; # db dir
our $ae_dbImportDumps; # sto csv for ae_importCsv
our $ae_rawDataDir;	#sto raw data for $ae_importRaw


our $ae_ressDir			= "res/";		#ressourcen files (images, ....)
our $ae_baseWww			= "www/";		# base dir der www dateien (read and write)
our $ae_emptyValue		= "&nbsp;";		# empty values will be filled with this


our $ae_dbType			= "sqlite";				# 1=sqlite,

our $fileDbScvAnlagen	= "ae_anlagen_db_import.csv";
our $fileDbCsvArbeit	= "ae_arbeit_db_import_"; #ae_arbeit_db_import_furth.csv
our $fileRawArbeit		= "ae_raw_";
our $fileGesamt 		= "dataGesamt_";    #dataGesamt_2015.csv > dataGesamt_2015.html
our $fileGesamtTotal	= "dataGesamtTotal";	#gesamtproduktion aller analgen pro jahr
our $fileAnlageJahr 	= "dataJahr_";	#Jahresproduktion_furth.csv
our $fileAnlageMonat	= "dataMonat_";
our $fileAnlageTag		= "dataTag_";
our $fileAnlageTagEmon	= "dataTagEmon_"; # for arbeitemon compare test phase
our $fileAnlageTagDiff	= "dataTagDiff_"; #data/dataTagDiff_furth.csv
our $fileAnlageTot		= "dataTot_";
our $sep_char			= ";";


my $ae_createDb 		= 0;    #1=create db
my $ae_migrateDb		= 0;	#1=migrate db
my $ae_importDumps		= 0;	#1=import db dumps from csv (1.version) >>> create db !!!!

my $ae_importRaw		= 0;	#1=import raw data into db
my $ae_importEmon   	= 1;  	#1=import from emoncms db
my $ae_prodCsv			= 1;	# 1=create csv files
my $ae_prodTbl			= 1;	# 1=produce tables
#my $ae_prodCharts		= 0;	# 1=produce charts
#my $ae_prodPdf			= 0;	# 1=produce pdf
my $ae_uploadFiles		= 1;	# 1=upload files to fileserver


############# get options ##################
GetOptions (
	"profile|p=s" => \$ae_case,
	"verbose!" => \$ae_stderrOutput,
	"createdb" => \$ae_createDb,
	"migratedb"	=> \$ae_migrateDb,
	"importdumps" => \$ae_importDumps,
	"importraw" => \$ae_importRaw,
	"importemon"	=> \$ae_importEmon,
	"csv" => \$ae_prodCsv,
	"tbl" => \$ae_prodTbl,
	"upload" => \$ae_uploadFiles
);


############# get profile data ##################

if ($ae_case eq "prod") {
# codebase (ie): /data/prod/appenergie/aegrapher/scr/
	$ae_outputDir   	= "/data/bodies/appenergie/website/www_new/data/";
	$ae_wwwDataDir		= 'root@vps288538.ovh.net:/var/www/appenergie/data';
#	$ae_db			= "/data/bodies/appenergie/daten/db/sqlite/appenergie.db";
	$ae_db			= "../data/db/sqlite/appenergie.db";
	$ae_dbImportDumps	= "../data/dumps/";
	$ae_rawDataDir = "../data/raw/";
	
} elsif ($ae_case eq "dev") {
	$ae_outputDir   	= "../data/output/";
	$ae_wwwDataDir		= "../data/www";	
	$ae_db			= "../data/db/test.db";
	$ae_dbImportDumps	= "../data/dumps/";
	$ae_rawDataDir = "../data/raw/";	

} elsif ($ae_case eq "webserver") {
# codebase (ie): /opt/appenergie/aegrapher/scr/
# run: /data/appenergie/scr/scr/appenergie.sh
	$ae_outputDir   	= "../data/output/";
	$ae_wwwDataDir		= "/var/www/appenergie/data";	
	$ae_db			= "../data/db/sqlite/appenergie.db";
	$ae_dbImportDumps	= "../data/dumps/";
	$ae_rawDataDir = "../data/raw/";	
	
} else {  #else error!
	die("Error wrong profile\n");
}




############# main functions ##################



############# init ##################


use Utili::LogCmdt;
Utili::LogCmdt::logOpen();


################# testing ##################




################## create db ##################

if ($ae_createDb) {
		use Db::AeDb;
		Db::AeDb::dbOpen();
		Db::AeDb::createAnlagen();
		Db::AeDb::createArbeit();
		Db::AeDb::dbClose();
}

################## migratge db ##################
if ($ae_migrateDb) {
	use Db::AeDb;
	Db::AeDb::dbOpen();	
	Db::AeDb::migrateDb();
	Db::AeDb::dbClose();	
}

################## import sql dumps ##################
 if ($ae_importDumps) {
		use Db::AeDb;
		Db::AeDb::dbOpen();
		Db::AeDb::insertCsvAnlagenFull();
#		Db::AeDb::insertCsvArbeitFull();
		Db::AeDb::dbClose();
 }


################## import from raw files ##################
if ($ae_importRaw) {
		use Db::AeDb;
		Db::AeDb::dbOpen();
		use Db::ImportRaw;
		Db::ImportRaw::importRawArbeit();
		Db::AeDb::dbClose();

}

################## import from emoncms ##################
if ($ae_importEmon) {
		use Db::AeDb;
		Db::AeDb::dbOpen();
		use Db::EmonDb;
		Db::EmonDb::dbOpen();
		use Db::ImportEmon;
		Db::ImportEmon::importNotImported();
		Db::EmonDb::dbClose();
		Db::AeDb::dbClose();
}

################## create csv files ##################
	if ($ae_prodCsv) {

		use Db::AeDb;
		Db::AeDb::dbOpen();

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



		Db::AeDb::dbClose();

	}



################## produce tables ##################
	if ($ae_prodTbl) {



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

if ($ae_uploadFiles) {
	use Utili::Rsyncer;

	Utili::Rsyncer::upload();

}

#######################

Utili::LogCmdt::logClose();


########### write QS Error  #################

if ($ae_writeLog && $ae_stderrOutput) {

	Utili::LogCmdt::logShowError();

}


#######################


1;
