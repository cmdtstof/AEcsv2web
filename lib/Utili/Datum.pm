#!/usr/bin/perl

package Utili::Datum;

use warnings;
use strict;

use Data::Dumper;

sub dateRawToDb {
	my ($rawDate) = @_; #DD.MM.YYYY
	
	my $sep = "-";

#without quotes!!!!

	my $tag = substr($rawDate, 0, 2);
	my $monat = substr($rawDate, 3, 2);
	my $jahr = substr($rawDate, 6, 4);
	
	my $dbDate = $jahr . $sep . $monat . $sep . $tag; #YYYY-MM-DD
	return $dbDate;
	
}



1;