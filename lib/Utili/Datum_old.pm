#!/usr/bin/perl

package Utili::Datum;

use warnings;
use strict;

#use Data::Dumper;

my $sep = "-";

sub dateRawToDb {
	my ($rawDate) = @_; #DD.MM.YYYY
	
	#without quotes!!!!

	my $tag = substr($rawDate, 0, 2);
	my $monat = substr($rawDate, 3, 2);
	my $jahr = substr($rawDate, 6, 4);
	
	my $dbDate = $jahr . $sep . $monat . $sep . $tag; #YYYY-MM-DD
	return $dbDate;
	
}

sub subtractDateWithMonth {
	my ($dateIn, $subMonth) = @_; #YYYY-MM-DD
	my $dateOut;
	if (defined $dateIn) {
		my $jahr = substr($dateIn, 0, 4);
		my $monat = substr($dateIn, 5, 2);
		my $tag = substr($dateIn, 8, 2);
		
		my $newMonat = $monat - $subMonth;
		if ($newMonat < 1) {
			$newMonat = $monat + 12 - $subMonth;
			$jahr = $jahr - 1;
		}
		$newMonat = sprintf("%02d", $newMonat);
		$dateOut = $jahr . $sep . $newMonat . $sep . $tag; #YYYY-MM-DD
	}
	return $dateOut;

}

sub dtPosix2Human {
	my ($dtPosix) = @_;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($dtPosix);
	return 
	
}



1;