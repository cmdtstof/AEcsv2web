#!/usr/bin/perl
=head1 NAME

Utili::LogCmdt

=item $LogCmdt::fhlog = log filehandler

LogCmdt::logWrite((caller(0))[3], "start"); 
>>>> (caller(0))[3] geht nur in einer subroutine drin. nicht aus main!!!

=cut

package Utili::LogCmdt;
use warnings;
use strict;


# __PACKAGE__
# __SUB__ # nur ab bestimmter perl version
# __LINE__
# __FILE__
# (caller(0))[3]
#

my $fhlog;


sub logOpen {
=item nill = LogCmdt::logOpen();
creates log file
=cut
	if ($AppEnergie::ae_writeLog) {

	my $logfile = $AppEnergie::ae_logDir . "logfile.csv";
	open $fhlog, ">:encoding(UTF-8)", $logfile or die "$logfile: $!";
	Utili::LogCmdt::logWrite((caller(0))[3], "start");
	}
	return;

}

sub logClose {
=item $code = LogCmdt::logClose();
close log file
=cut
	if ($AppEnergie::ae_writeLog) {
	Utili::LogCmdt::logWrite((caller(0))[3], "fin");
	close $fhlog;
	}
	return;
}



sub logWrite {
=item nil = LogCmdt::logWrite( $caller, $logtext );
writes $logtext into logfile
=cut
	my ($caller, $logtext ) = @_;
	my $str = localtime(time) . "\t $caller\t $logtext\n";
	if ($AppEnergie::ae_writeLog) {

	print $fhlog $str;
	}

	if ($AppEnergie::ae_stderrOutput) {
		print STDERR "$str";		
	}

	return;
}



1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

cmdt.ch

=for COPYRIGHT END

=for LICENSE BEGIN

CC-BY-SA cmdt L<http://cmdt.ch/>.

=for LICENSE END
