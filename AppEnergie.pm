#!/usr/bin/perl -Ilib 

################################################
# Appenzeller Energie
#  
#
# create db, tables in www, charts, pdfs
#
#

package AppEnergie;
use warnings;
use strict;
use Data::Dumper;

##############################################################################
# Define some constants
#

#my $ae_case = "appenergie";
my $ae_case = "test";


our $ae_dataStatus 		= "20.03.2015";    	# date of the db dump
our $ae_writeLog 		= 1;				#1=write logfile and entries
our $ae_stderrOutput 	= 1;				# 1=logfile output will also be sended to stderr
our $ae_logDir			= "../log/";
our $ae_logfile = $AppEnergie::ae_logDir . "logfile.csv";
our $ae_outputDir; # outputdir csv, pdf, ... 
our $ae_wwwDataDir; #upload dir for data
our $ae_db; # db dir
our $ae_dbImportDumps; # sto csv for ae_importCsv
our $ae_rawDataDir;	#sto raw data for $ae_importRaw

if ($ae_case eq "appenergie") {
	$ae_outputDir   	= "/data/bodies/appenergie/website/www_new/data/";
	$ae_wwwDataDir		= 'sysadmin@websrv01.eleph.ch:/var/www/appenergie/data';
	$ae_db			= "/data/bodies/appenergie/daten/db/sqlite/appenergie.db";		
	$ae_dbImportDumps	= "/data/bodies/appenergie/daten/db/";
	$ae_rawDataDir = "/data/bodies/appenergie/daten/raw/";
	
} elsif ($ae_case eq "test") {
	$ae_outputDir   	= "../testdata/output/";
	$ae_wwwDataDir		= "../testdata/www";	
	$ae_db			= "../testdata/db/test.db";
	$ae_dbImportDumps	= "../testdata/dumps/";
	$ae_rawDataDir = "../testdata/raw/";	
	
} #else error!






our $ae_ressDir			= "res/";		#ressourcen files (images, ....)
our $ae_baseWww			= "www/";		# base dir der www dateien (read and write)
our $ae_emptyValue		= "&nbsp;";		# empty values will be filled with this

 
our $ae_dbType			= "sqlite";				# 1=sqlite,

our $fileDbScvAnlagen	= "ae_anlagen_db_import.csv";
our $fileDbCsvArbeit	= "ae_arbeit_db_import_"; #ae_arbeit_db_import_furth.csv
our $fileRawArbeit		= "ae_raw_"; 
our $fileGesamt 		= "dataGesamt_";    #dataGesamt_2015.csv > dataGesamt_2015.html
our $fileAnlageJahr 	= "dataJahr_";	#Jahresproduktion_furth.csv
our $fileAnlageMonat	= "dataMonat_";
our $fileAnlageTag		= "dataTag_";
our $sep_char			= ";";


my $ae_createDb 		= 0;    #1=create db
my $ae_importDumps		= 0;	#1=import db dumps from csv (1.version) >>> create db !!!!

my $ae_importRaw		= 0;	#1=import raw data into db
my $ae_prodCsv			= 0;	# 1=create csv files
my $ae_prodTbl			= 0;	# 1=produce tables
#my $ae_prodCharts		= 0;	# 1=produce charts
#my $ae_prodPdf			= 0;	# 1=produce pdf
my $ae_uploadFiles		= 1;	# 1=upload files to fileserver


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


################## create csv files ##################
	if ($ae_prodCsv) {

		use Db::AeDb;
		Db::AeDb::dbOpen();
		
		use Prod::Csv;

#TODO del file before write

		
#csv für html-tbl
		Prod::Csv::prodGesamtAlleJahr();		

#csv für diagramme		
		Prod::Csv::prodAnlageJahr();
		Prod::Csv::prodAnlageMonate();
		Prod::Csv::prodAnlageTag();


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

