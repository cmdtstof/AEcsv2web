#!/usr/bin/perl
=head1 NAME

Utili::LogCmdtOO

=item $LogCmdt::fhlog = log filehandler

LogCmdt::logWrite((caller(0))[3], "start"); 
>>>> (caller(0))[3] works only out from subroutine, not out from main!!!

usage: initialize, open, write from main
	our $jplog = Utili::LogCmdtOO->new(1, "../log/jplog.txt", 1, 0); #=item nil = new( writeLog, logFile, verboser, logAppend );
	$jplog->logOpen();
	$jplog->logWrite($config{tool}, "start..."); #=item nil = LogCmdt::logWrite( $caller, $logtext );
and then:
	$Jobparser::jplog->logWrite(( caller(0) )[3], "start testing...");

fin:
	$log->logWrite($config{tool}, "...end");
	$log->logClose();
	$log->logShowError();
	
=cut

package Utili::LogCmdtOO;
use warnings;
use strict;
use Data::Dumper;


# __PACKAGE__
# __SUB__ # nur ab bestimmter perl version
# __LINE__
# __FILE__
# (caller(0))[3]
#


my $fhlog; 	#log file handler

sub new {
=item nil = new( writeLog, logFile, verboser, logAppend );
creates instance
#	my $writeLog	= shift; # 1=write log entry
#	my $logFile	= shift;		##path/logfilename
#	my $verboser	= shift; #1=output on screen
#	my $logAppend	= shift; #1= append log file to existing
=cut	
	my $class = shift;
	my $config = {
		writeLog	=> shift, # 1=write log entry
		logFile		=> shift,		##path/logfilename
		verboser	=> shift, #1=output on screen
		logAppend	=> shift, #1= append log file to existing
	};

	my $self = {};
	bless $self, $class;	
	$self->{config} = $config;
	return $self;
}	

sub logOpen {
=item nill = LogCmdt::logOpen();
creates log file
=cut
	my $self = shift;
	
	if ($self->{config}->{writeLog}) {
            if ($self->{config}->{logAppend}) {
                    open $fhlog, ">>:encoding(UTF-8)", $self->{config}->{logFile} or die "$self->{config}->{logFile}: $!";
            }
            else {
                open $fhlog, ">:encoding(UTF-8)", $self->{config}->{logFile} or die "$self->{config}->{logFile}: $!";
            }
#		$self->logWrite((caller(0))[3], "start");
	}
	return;

}

sub logInfo {
	my $self = shift;
	print "logInfo";
	print Dumper $self; #logInfo$VAR1 = \bless( {}, 'Utili::Log' );
	return;
}



sub logClose {
=item $code = LogCmdt::logClose();
close log file
=cut
	my $self = shift;
	if ($self->{config}->{writeLog}) {
#		$self->logWrite((caller(0))[3], "fin");
		close $fhlog;
	}
	return;
}

sub logWrite {
=item nil = LogCmdt::logWrite( $caller, $logtext );
writes $logtext into logfile
=cut
	my $self = shift;
	my $caller = shift;
	my $logtext = shift;
	my $str = localtime(time) . "\t $caller\t $logtext\n";
	if ($self->{config}->{writeLog}) {
		print $fhlog $str;	
	}
	if ($self->{config}->{verboser}) {
		print STDERR "$str";		
	}

	return;
}

sub logShowError {
	my $self = shift;
	open($fhlog, $self->{config}->{logFile});
	my @list=<$fhlog>;
	my $searchFor="QS ERROR";
	my @result=grep /$searchFor/,@list;
	close $fhlog;
	
print "***********QS ERRORs************\n";	
print Dumper @result;
print "***********QS ERRORs fin************\n";	
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
