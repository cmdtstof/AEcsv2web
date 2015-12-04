#!/usr/bin/perl

package Utili::Timi;
#some date/time utilities

use warnings;
use strict;

use Date::Simple ('date', 'today');

sub tester {

my $datum = getToday();
print getYear($datum);




}

sub getToday {
	#return yyyy-mm-dd
	return today(); 
}

sub getYear {
	#return yyyy
	my ($datum) = @_; #yyyy-mm-dd 
	my $date = Date::Simple->new($datum);
	return $date->year;
}

sub getYearToday {
	#return yyyy
	my $date = Date::Simple->new(today());
	return $date->year;
}



1;