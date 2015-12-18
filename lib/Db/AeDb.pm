#!/usr/bin/perl
# DBI functions
#

package Db::AeDb;

use warnings;
use strict;
use DBI;
use XML::Simple qw(:strict);

use Utili::LogCmdt;
use Data::Dumper;
use Utili::FileTools;
use SQL::Abstract;

my $dbh;

sub tester {

	return;

}

sub dbOpen {
### stof003 sqlight
	my $database = $AppEnergie::ae_db;

	if ($AppEnergie::ae_dbType eq "sqlite") {
		$dbh =
		  DBI->connect( "dbi:SQLite:dbname=$database", "", "",
			{ RaiseError => 1, AutoCommit => 1 } )
		  || die "Could not connect to database: $DBI::errstr";
		Utili::LogCmdt::logWrite( ( caller(0) )[3],
			"open db $database. dump from: $AppEnergie::ae_dataStatus" );
		
	}
		
	return;

}

sub dbClose {
	$dbh->disconnect();
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "close db" );
	return;

}

sub createAnlagen {

	my $stmt = qq(DROP TABLE IF EXISTS anlagen );
	my $rv   = $dbh->do($stmt);

	$stmt = qq(

CREATE TABLE anlagen (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`anlage`	TEXT,
	`beschreibung`	TEXT,
	`typ`	TEXT,
	`sort`	INTEGER	
);

	);
	$rv = $dbh->do($stmt);

	Utili::LogCmdt::logWrite( ( caller(0) )[3], "create tbl anlagen" );
	return;
}

sub createArbeit {

	my $stmt = qq(DROP TABLE IF EXISTS arbeit );
	my $rv   = $dbh->do($stmt);

	$stmt = qq(

CREATE TABLE arbeit (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`datum`	TEXT,
	`anlageid`	TEXT,
	`arbeit`	REAL
);

	);
	$rv = $dbh->do($stmt);

	Utili::LogCmdt::logWrite( ( caller(0) )[3], "create tbl arbeit" );
	return;
}

sub existsAnlageid {
	my ($anlageid) = @_;

	my $sth = $dbh->prepare('SELECT * FROM anlagen');
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	if ($result) {
		return 1;
	} else {
		return 0;
	}
}

sub insertHash {
	my ($tbl, %fieldvals) = @_;
	my $sql = SQL::Abstract->new;
	my($stmt, @bind) = $sql->insert($tbl, \%fieldvals );	
	my $sth = $dbh->prepare($stmt);
	$sth->execute(@bind);
	return;	
}

sub updateArbeit {
	my ($id, %fields) = @_;
	my $stmt = "UPDATE arbeit SET";
	while ( my ($key, $value) = each(%fields) ) {
        $stmt .= " $key = '$value',"; 
    }	
	chop $stmt;
	$stmt .= " WHERE id = '$id'";	
	my	$sth = $dbh->prepare($stmt);
	$sth->execute();
	return;
}


sub insertCsvAnlagenFull {
	my $file = $AppEnergie::ae_dbImportDumps . $AppEnergie::fileDbScvAnlagen;
	
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "start import dump\t$file" );
	
	open( CSV, $file ) || die "Can't open $file: $!\n";
	my $sth = $dbh->prepare(
		"INSERT INTO anlagen (anlage, beschreibung, typ, sort) VALUES (?,?,?,?)"
	);
	my $first_line = <CSV>;    #throw away first line
	while (<CSV>) {
		chomp;
		my ( $id, $anlage, $beschreibung, $typ, $sort ) = split /,/;
		$sth->execute( $anlage, $beschreibung, $typ, $sort );
	}
	return;
}

#TODO evtl only update data

#TODO QS check for douple entries!!!!


sub insertCsvArbeitFull {
	my $filePattern = $AppEnergie::fileDbCsvArbeit . "*.csv";
	
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "start importing dumps\t$filePattern" );
	
	my @files =
	  Utili::FileTools::getFileListFromPattern( $AppEnergie::ae_dbImportDumps,
		$filePattern );

	foreach my $fileCsv (@files) {
		open my $fh, '<', $fileCsv
		  or die "Could not open $fileCsv: $!\n";    # ohne utf-8!!!!!!!
		Utili::LogCmdt::logWrite( ( caller(0) )[3], "import from csv\t$fileCsv" );

		my $sth = $dbh->prepare(
"INSERT INTO arbeit (datum, anlageid, bArbeit, nArbeit) VALUES (?,?,?,?)"
		);
		my $first_line = <$fh>;                      #throw away first line
		while (<$fh>) {
			chomp;
			my ( $id, $datum, $anlageid, $bArbeit, $nArbeit ) = split /,/;
			$sth->execute(
				$datum, $anlageid, $bArbeit,
				$nArbeit
			  )                                      # or die $dbh->errstr;
		}
		close $fh;
	}
	return;
}


sub getAnlagenBeschreibungArray {
	my @array;
	my $sth = getAnlagen();
	while ( my $result = $sth->fetchrow_hashref() ) {
		my $value = $result->{beschreibung};
		push( @array, $value );
	}
	return @array;
}


sub getAnlagenArrayHash {
	my @array;
	my $sth = getAnlagen();
	while ( my $result = $sth->fetchrow_hashref() ) {
		push (@array, $result);
	}	
	return @array;	
}


sub getAnlagen {
	my $sth;
	$sth = $dbh->prepare('SELECT * FROM anlagen order by sort');
	$sth->execute();
	return $sth;
}

sub getDataSetArbeit {
	my $sth;
	$sth = $dbh->prepare('SELECT * FROM arbeit');
	$sth->execute();
	return $sth;
}

sub getAlleJahrMonatAnlageSumNArbeit {    #gesamtproduktion
	 #select anlageid,  strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit group by jahr, monat, anlageid
	my $sth;
	$sth = $dbh->prepare(
'select anlageid, strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(nArbeit) as sumNarbeit from arbeit group by jahr, monat, anlageId'
	);
	$sth->execute();
	return $sth;

}

sub getAnlageTagBArbeit {    #tagesproduktion brutto anlage
	my ( $id, $DatumVon, $DatumBis ) = @_;

#select datum, bArbeit from arbeit where anlageId = '5' AND datum >= '2014-10-01' AND datum <= '2014-12-31' order by datum
	my $sth;
	$sth = $dbh->prepare(
'select datum, bArbeit from arbeit where anlageId = ? AND datum >= ? AND datum <= ? order by datum'
	);
	$sth->execute( $id, $DatumVon, $DatumBis );
	return $sth;

}

sub getMonatSum { 	#monatsproduktion nur für einen monat+jahr+anlage
	my ($id, $jahr, $monat) = @_;
	my $sth;
#	select strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit where jahr = '2010' and monat = '01' and anlageId = "2" group by jahr, monat order by jahr, monat
	$sth = $dbh->prepare(
'select strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(nArbeit) as sum from arbeit where anlageId = ? and jahr = ? and monat = ? group by jahr, monat'
);
	$sth->execute($id, $jahr, $monat);
	my $result = $sth->fetchrow_hashref();
	my $sum = $result->{sum};
	$sth->finish;
	return $sum;
}

sub getArbeitAsHash {
	my (%newFields) = @_;

	my $anlageid = $newFields{'anlageid'};
	my $datum = $newFields{'datum'};
	my $stmt = "select * from arbeit where datum = '$datum' and anlageid = $anlageid;"; 
#print "aedb getarbeitashash stmt: $stmt\n";	
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	my $result = $sth->fetchrow_hashref();

#print "aedb getarbeitashash result";
#print Dumper \$result;

#TODO check if doppelte einträge!!!

	return $result;
}





sub getAnlageMonatSumNArbeit {    #monatsproduktion anlage
	my ($id) = @_;

#>>> not working: select strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit where jahr > "now"-5 and anlageId = "5" group by jahr, monat order by jahr, monat
#select strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit where jahr > '2010' and anlageId = "2" group by jahr, monat order by jahr, monat

	my $sth;
	$sth = $dbh->prepare(
'select strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(nArbeit) from arbeit where jahr > "now"-5 and anlageId = ? group by jahr, monat order by jahr, monat'
	);
	$sth->execute($id);
	return $sth;

}

sub getAnlageJahrSumNArbeit {    ## jahresproduktion anlage
	my ($id) = @_;

#select strftime("%Y", datum) as jahr, sum(nArbeit) as sumNarbeit from arbeit where anlageId = "5" group by jahr order by jahr
	my $sth;
	$sth = $dbh->prepare(
'select strftime("%Y", datum) as jahr, sum(nArbeit) as sumNarbeit from arbeit where anlageId = ? group by jahr order by jahr'
	);
	$sth->execute($id);
	return $sth;

}

sub _getJahrMonatAnlageSumArbeit {    #not used
	my ($dJahr) = @_;

#select anlageid,  strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit where jahr = ? group by anlageid, jahr, monat
	my $sth;
	$sth = $dbh->prepare(
'select anlageId,  strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(nArbeit) from arbeit where jahr = ? group by jahr, monat, anlageId'
	);
	$sth->execute($dJahr);
	return $sth;
}

sub normaliseMonate {

	#TODO evtl. normalise monate = add for empty month when there are no data 

}

1;
