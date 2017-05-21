#!/usr/bin/perl

package Utili::Rsyncer;

use warnings;
use strict;

use Data::Dumper;

sub upload {



##!/bin/bash
#rsync -rvzuP --delete /data/bodies/appenergie/website/www_new/* root@vps288538.ovh.net:/var/www/appenergie/data

	my $src = $AEdataProc::config{outputDir};
#	my $src = "/data/bodies/appenergie/scr/testdata/output/";
	
	my $dst = $AEdataProc::config{wwwDataDir};

$AEdataProc::log->logWrite( ( caller(0) )[3], "start uploading" );
$AEdataProc::log->logWrite( ( caller(0) )[3], "start uploading from\t$src" );
$AEdataProc::log->logWrite( ( caller(0) )[3], "start uploading to\t$dst" );

	
	system('rsync', '-rvzuP', '--delete', $src, $dst);

$AEdataProc::log->logWrite( ( caller(0) )[3], "finish uploading" );
	return;
	
}



1;