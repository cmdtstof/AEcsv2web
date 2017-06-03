#!/usr/bin/perl
# DBI functions
#

package Db::EmonDb;

use warnings;
use strict;
use DBI;
#use XML::Simple qw(:strict);

	my $dbh;

#update arbeit SET arbeitemon = null

sub tester {

	return;

}

sub dbOpen {
	my ($dbType, $dbHost, $dbPort, $dbName, $dbUser, $dbPwd) = @_;	
	
	if ($dbType eq "mysql") {
		my $connectString = "DBI:mysql:database=" . $dbName . ";host=" . $dbHost . ";port=" . $dbPort;
		$dbh =
		  DBI->connect( $connectString, $dbUser, $dbPwd,
			{ RaiseError => 1, AutoCommit => 0 } )
		  || die "Could not connect to database: $DBI::errstr";
		
		$AEdataProc::log->logWrite( ( caller(0) )[3], "open db\t$dbHost $dbName" );
	}
	return;
}

sub dbClose {
	if ($dbh) {
		$dbh->disconnect();
		$AEdataProc::log->logWrite( ( caller(0) )[3], "close db" );
	}
	return;

}

# epoch date = getMinTimeForFeed(feed tbl);
sub getMinTimeForFeed {
	my ($table) = @_;
	my $sth = $dbh->prepare("SELECT min(time) as time FROM $table");
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	my $time = $result->{'time'}; 	
	return $time; #epoch
}

sub getMaxTimeForFeed {
	my ($table) = @_;
	my $sth = $dbh->prepare("SELECT max(time) as time FROM $table");
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	my $time = $result->{'time'}; 	
	return $time; #epoch	
}


sub getFeedsSth {
	my $sth;
	$sth = $dbh->prepare('SELECT * FROM feeds order by name');
	$sth->execute();
	return $sth;
}

sub getTableSth {
	my ( $table ) = @_;
	my $sth = $dbh->prepare("SELECT * FROM $table order by time");
	$sth->execute();
	return $sth;
}

sub getQuerystrSth {
	my ($querystr) = @_;
	my $sth = $dbh->prepare("$querystr");
	$sth->execute();
	return $sth;	
} 


1;
