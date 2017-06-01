#!/usr/bin/perl

package Utili::Numi;
use warnings;
use strict;

=head1 Utili::Numi

some number utilities with Number::Format
	
=cut


use Number::Format;


sub tester {

my $num = 12354888.6;

print "(1)" . formatNum($num);


}

=over

=item 7'654'321.25 = formatNum(7654321.25)

=cut
sub formatNum {
	my ($number) = @_;
	
  my $ch = new Number::Format(-thousands_sep   => "'",
                              -decimal_point   => '.');

  return $ch->format_number($number);

}

1;

=back