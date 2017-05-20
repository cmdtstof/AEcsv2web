#!/usr/bin/perl
# DBI functions
#

package Db::EmonDb;

use warnings;
use strict;
use DBI;
use XML::Simple qw(:strict);

use Utili::LogCmdt;

#use SQL::Abstract;

	my $dbh;
	my $config = {
# config in /var/www/html/emoncms/settings.php 
		dbType => "mysql",
		database	=> "emoncms",
		host	=> "emoncms.rosslan.home", #localhost
		port	=> "3306",
		user	=> "emoncms",
		pwd		=> "emoncms",
	};







sub tester {

	return;

}

sub dbOpen {
### stof006 virtualbox mysql

# grant any host!!!
#mysql -h emoncms -u emoncms -p


	my $connectString = "DBI:mysql:database=" . $config->{database} . ";host=" . $config->{host} . ";port=" . $config->{port};
	$dbh =
	  DBI->connect( $connectString, $config->{user}, $config->{pwd},
		{ RaiseError => 1, AutoCommit => 0 } )
	  || die "Could not connect to database: $DBI::errstr";
	
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "open db\t$config->{host} $config->{database}" );
	return;
}

sub dbClose {
	$dbh->disconnect();
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "close db" );
	return;

}

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
