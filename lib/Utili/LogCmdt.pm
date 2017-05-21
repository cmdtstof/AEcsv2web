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
use Data::Dumper;


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
	if ($AEdataProc::configae_writeLog) {

	my $logfile = $AEdataProc::configae_logfile;
	open $fhlog, ">:encoding(UTF-8)", $logfile or die "$logfile: $!";
	$AEdataProc::log->logWrite((caller(0))[3], "start");
	}
	return;

}

sub logClose {
=item $code = LogCmdt::logClose();
close log file
=cut
	if ($AEdataProc::configae_writeLog) {
	$AEdataProc::log->logWrite((caller(0))[3], "fin");
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
	if ($AEdataProc::configae_writeLog) {

	print $fhlog $str;
	}

	if ($AEdataProc::configae_stderrOutput) {
		print STDERR "$str";		
	}

	return;
}

sub logShowError {
	
	open($fhlog, $AEdataProc::configae_logfile);
	my @list=<$fhlog>;
	my $searchFor="QS ERROR";
	my @result=grep /$searchFor/,@list;
	close $fhlog;
	
print "***********QS ERRORs************\n";	
print Dumper @result;	

	
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
