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
### stof006 virtualbox

# grant any host!!!
#mysql -h emoncms -u emoncms -p


	my $connectString = "DBI:mysql:database=" . $config->{database} . ";host=" . $config->{host} . ";port=" . $config->{port};
	$dbh =
	  DBI->connect( $connectString, $config->{user}, $config->{pwd},
		{ RaiseError => 1, AutoCommit => 0 } )
	  || die "Could not connect to database: $DBI::errstr";
	
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "open db" );
	return;
}

sub dbClose {
	$dbh->disconnect();
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "close db" );
	return;

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
