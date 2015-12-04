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
our $ae_dataStatus 		= "20.03.2015";    	# date of the db dump
our $ae_writeLog 		= 1;				#1=write logfile and entries
our $ae_stderrOutput 	= 1;				# 1=logfile output will also be sended to stderr
our $ae_logDir			= "log/";
#our $ae_outputDir   	= "output/";   		# outputdir csv, pdf, ... (ohne www!)
our $ae_outputDir   	= "/home/stof/04_bodies/appenergie/website/www_new/data/";

our $ae_ressDir			= "res/";		#ressourcen files (images, ....)
our $ae_baseWww			= "www/";		# base dir der www dateien (read and write)
our $ae_emptyValue		= "&nbsp;";		# empty values will be filled with this
our $ae_dbDir			= "/home/stof/04_bodies/appenergie/daten/db/sqlite/";		# db dir
our $ae_dbImportDumps	= "/home/stof/04_bodies/appenergie/daten/db/";


our $ae_dbType			= "1";				# 1=sqlite, 


our $fileDbScvAnlagen	= "ae_anlagen_db_import.csv";
our $fileDbCsvArbeit	= "ae_arbeit_db_import_"; #ae_arbeit_db_import_furth.csv 
our $fileGesamt 		= "dataGesamt_";    #dataGesamt_2015.csv > dataGesamt_2015.html
our $fileAnlageJahr 	= "dataJahr_";	#Jahresproduktion_furth.csv
our $fileAnlageMonat	= "dataMonat_";
our $fileAnlageTag		= "dataTag_";


my $ae_createDb 		= 0;    #1=create db
my $ae_prodCsv			= 1;	# 1=create csv files
my $ae_prodTbl			= 1;	# 1=produce tables
#my $ae_prodCharts		= 0;	# 1=produce charts
#my $ae_prodPdf			= 0;	# 1=produce pdf
my $ae_uploadFiles		= 0;	# 1=upload files to fileserver


############# main functions ##################








############# init ##################


use Utili::LogCmdt;
Utili::LogCmdt::logOpen();


################# testing ##################




################## create db ##################

if ($ae_createDb) {
	
#TODO only update db

		use Db::AeDb;
		Db::AeDb::dbOpen();
	
		Db::AeDb::createAnlagen();
		Db::AeDb::insertCsvAnlagenFull();
		
		Db::AeDb::createArbeit();
		Db::AeDb::insertCsvArbeitFull();


		Db::AeDb::dbClose();
	
}

################## create csv files ##################
	if ($ae_prodCsv) {

		use Db::AeDb;
		Db::AeDb::dbOpen();
		
		use Prod::Csv;
		
#csv für html-tbl
		Prod::Csv::prodGesamtAlleJahr(); #ok		

#csv für diagramme		
#		Prod::Csv::prodAnlageJahr(); #ok
#		Prod::Csv::prodAnlageMonate(); #ok
#		Prod::Csv::prodAnlageTag(); #ok


		Db::AeDb::dbClose();
		
	}
	
	

################## produce tables ##################
	if ($ae_prodTbl) {
	


		use Prod::Tbls;
		Prod::Tbls::prodGesamtTbl(); #html tbl gesamtproduktion ab 2014
		
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





########### #################



Utili::LogCmdt::logClose();

1;

