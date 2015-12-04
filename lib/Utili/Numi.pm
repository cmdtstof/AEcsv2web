#!/usr/bin/perl

package Utili::Numi;
#some number utilities

use warnings;
use strict;


use Number::Format;


sub tester {

my $num = 12354888.6;

print "(1)" . formatNum($num);


}


sub formatNum {
	my ($number) = @_;
	
  my $ch = new Number::Format(-thousands_sep   => "'",
                              -decimal_point   => '.');

  return $ch->format_number($number);

}








1;