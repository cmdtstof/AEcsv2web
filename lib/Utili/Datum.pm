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

sub getSqliteTimestamp {
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   getLocaltimeFormated();
	return ($year."-".$month."-".$day." ".$hour.":".$min.":".$sec);	
	
}

sub getYYYYMMDD {
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   getLocaltimeFormated();
	return ($year . $month . $day);
}

sub getYYYYMMDDHHMMSS {
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   getLocaltimeFormated();
	return ($year . $month . $day . $hour . $min . $sec);
	
}

sub getLocaltimeFormated {
	my ($sec,$min,$hour,$day,$month,$year,@rest) = getLocaltime();
	($sec,$min,$hour,$day,$month,$year,@rest) = localtimeFormater($sec,$min,$hour,$day,$month,$year,@rest);
	return ($sec,$min,$hour,$day,$month,$year, @rest); 
}

sub getLocaltime {
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);#######To get the localtime of your system
	return ($sec,$min,$hour,$day,$month,$year,@rest);
}

sub getPosix2HumanFormStr{
	my ($dtPosix) = @_; 	#YYYYMMDDHHMMSS
	my ($sec,$min,$hour,$day,$month,$year, @rest) = getPosix2HumanFormatet($dtPosix);
	return "$year-$month-$day $hour:$min:$sec"; 
}

sub getPosix2HumanFormatet{
	my ($dtPosix) = @_;
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime($dtPosix);
	($sec,$min,$hour,$day,$month,$year,@rest) = localtimeFormater($sec,$min,$hour,$day,$month,$year,@rest);		
	return ($sec,$min,$hour,$day,$month,$year, @rest);
}

sub localtimeFormater{
	my ($sec,$min,$hour,$day,$month,$year,@rest) = @_;
	$year += 1900;
	$month += 1;  # !!!!!
	$month = sprintf("%02d", $month);
	$hour = sprintf("%02d", $hour);
	$min = sprintf("%02d", $min);
	$sec = sprintf("%02d", $sec);
	return ($sec,$min,$hour,$day,$month,$year, @rest);
}


1;