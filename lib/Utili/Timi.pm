#!/usr/bin/perl
package Utili::Timi;
use warnings;
use strict;

=head1 Utili::Timi

some date/time utilities with Date::Simple
	
=cut



use Date::Simple ('date', 'today');

=over

=cut


sub tester {

my $datum = getToday();
print getYear($datum);


}
=item yyyy-mm-dd = getToday()
=cut
sub getToday {
	return today(); 
}
=item yyyy = getYear(yyyy-mm-dd)
=cut
sub getYear {
	my ($datum) = @_; #yyyy-mm-dd 
	my $date = Date::Simple->new($datum);
	return $date->year;
}

=item yyyy = getYearToday()
=cut
sub getYearToday {
	#return yyyy
	my $date = Date::Simple->new(today());
	return $date->year;
}

1;

=back