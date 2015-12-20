#!/usr/bin/perl

package Utili::Rsyncer;

use warnings;
use strict;

use Data::Dumper;

sub upload {



##!/bin/bash
#rsync -rvzuP --delete /data/bodies/appenergie/website/www_new/* sysadmin@websrv01.eleph.ch:/var/www/appenergie/data

	my $src = $AppEnergie::ae_outputDir;
#	my $src = "/data/bodies/appenergie/scr/testdata/output/";
	
	my $dst = $AppEnergie::ae_wwwDataDir;

Utili::LogCmdt::logWrite( ( caller(0) )[3], "start uploading" );
Utili::LogCmdt::logWrite( ( caller(0) )[3], "start uploading from\t$src" );
Utili::LogCmdt::logWrite( ( caller(0) )[3], "start uploading to\t$dst" );

	
	system('rsync', '-rvzuP', '--delete', $src, $dst);

Utili::LogCmdt::logWrite( ( caller(0) )[3], "finish uploading" );
	return;
	
}



1;