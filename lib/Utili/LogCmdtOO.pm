#!/usr/bin/perl
=head1 Utili::LogCmdtOO


=head2 usage: initialize, open, write from main

	our $log = Utili::LogCmdtOO->new(1, "../log/log.csv", 1, 0);
	$log->logOpen();
	$log->logWrite($config{tool}, "start..."); #=item nil = LogCmdt::logWrite( $caller, $logtext );

=head2 and then:

	$app::log->logWrite(( caller(0) )[3], "start testing...");

=head2 fin:

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

=over

=item $log = new( writeLog, logFile, verboser, logAppend );
=cut	
sub new {
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

=item nil = $log->logOpen();
creates log file
=cut
sub logOpen {

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

sub logClose {
=item nil = $log->logClose();
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
=item nil = $log->logWrite( $caller, $logtext );
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
=item nil = $log->logShowError();
prints all "QS ERROR" lines
=cut
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


=back

=head2 COPYRIGHT

Copyright 2017 cmdt.ch L<http://cmdt.ch/>. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
    
=cut
