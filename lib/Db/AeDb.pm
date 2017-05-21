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
### sqlight
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

# using real makes trouble when comparing!

	$stmt = qq(
CREATE TABLE arbeit (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`datum`	TEXT,
	`anlageid`	TEXT,
	`arbeit`	TEXT,
	`arbeitemon`	TEXT
);
	);
	$rv = $dbh->do($stmt);

	Utili::LogCmdt::logWrite( ( caller(0) )[3], "create tbl arbeit" );
	return;
}

sub migrateDb {
	
	#v0.4 tbl arbeit + arbeitemon(text)
Utili::LogCmdt::logWrite( ( caller(0) )[3], "migrate db to v0.4" );	
	
	my $stmt = qq(
alter table arbeit
  add arbeitemon TEXT;
	);
	my $rv = $dbh->do($stmt);	
	
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


sub _insertCsvArbeitFull {
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
"INSERT INTO arbeit (datum, anlageid, bArbeit, arbeit) VALUES (?,?,?,?)"
		);
		my $first_line = <$fh>;                      #throw away first line
		while (<$fh>) {
			chomp;
			my ( $id, $datum, $anlageid, $bArbeit, $arbeit ) = split /,/;
			$sth->execute(
				$datum, $anlageid, $bArbeit,
				$arbeit
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

sub getMaxDatum {
	my $stmt = qq(
select max(datum) as maxDatum from arbeit; 	
	);
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	my $maxDatum = $result->{'maxDatum'}; 
	return $maxDatum;
}

#gives back last datum with a value for a given anlageid
sub getMaxEmonDatumForAnlage {
	my ($anlageid) = @_;
	my $stmt = qq(
SELECT max(datum) as maxDatum from arbeit where arbeitemon is not null AND anlageid=$anlageid; 	
	);
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	my $maxDatum = $result->{'maxDatum'}; 
	return $maxDatum;
}


sub getAnlagen {
	my $sth;
	$sth = $dbh->prepare('SELECT * FROM anlagen order by sort');
	$sth->execute();
	return $sth;
}

sub getAnlage {
	my ($anlage) = @_;
	my $sth = $dbh->prepare("SELECT * FROM anlagen where anlage = '$anlage'");
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	return $result;	
}



sub getDataSetArbeit {
	my $sth;
	$sth = $dbh->prepare('SELECT * FROM arbeit');
	$sth->execute();
	return $sth;
}

#gives for anlageid arbeit (kwh) per day
sub getArbeitTag{
	my ($anlageid, $datum) = @_;
	my $sth = $dbh->prepare("SELECT * FROM arbeit where anlageid = $anlageid AND datum = '$datum'");
	$sth->execute();
	my $result = $sth->fetchrow_hashref(); #TODO check if double
	my $arbeit = $result->{arbeit};
	return $arbeit;
}


sub getAlleJahrMonatAnlageSumNArbeit {    #gesamtproduktion
	 #select anlageid,  strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit group by jahr, monat, anlageid
	my $sth;
	$sth = $dbh->prepare(
'select anlageid, strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(arbeit) as sumNarbeit from arbeit group by jahr, monat, anlageId'
	);
	$sth->execute();
	return $sth;

}

sub getAnlageTagBArbeitTotal {    #tagesproduktion brutto anlage
	my ( $id ) = @_;
	my $stmt = qq(
select datum, arbeit from arbeit where anlageId = $id order by datum; 	
	);
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	return $sth;
}

sub getAnlageTagBArbeit {    #tagesproduktion brutto anlage
	my ( $id, $DatumVon, $DatumBis ) = @_;

#select datum, bArbeit from arbeit where anlageId = '5' AND datum >= '2014-10-01' AND datum <= '2014-12-31' order by datum
	my $sth;
	$sth = $dbh->prepare(
'select * from arbeit where anlageId = ? AND datum >= ? AND datum <= ? order by datum'
	);
	$sth->execute( $id, $DatumVon, $DatumBis );
	return $sth;

}

sub getMonatSum { 	#monatsproduktion nur für einen monat+jahr+anlage
	my ($id, $jahr, $monat) = @_;
	my $sth;
#	select strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit where jahr = '2010' and monat = '01' and anlageId = "2" group by jahr, monat order by jahr, monat
	$sth = $dbh->prepare(
'select strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(arbeit) as sum from arbeit where anlageId = ? and jahr = ? and monat = ? group by jahr, monat'
);
	$sth->execute($id, $jahr, $monat);
	my $result = $sth->fetchrow_hashref();
	my $sum = $result->{sum};
	$sth->finish;
	return $sum;
}


#$result(hashref(id, datum, anlageid, arbeit, arbeitemon)) = getArbeitAsHash($hash(anlageid, datum)) 
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
'select strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(arbeit) from arbeit where jahr > "now"-5 and anlageId = ? group by jahr, monat order by jahr, monat'
	);
	$sth->execute($id);
	return $sth;

}

sub getGesamtProJahr {    #gives gesamt arbeit von bis
	my ($DatumVon, $DatumBis) = @_;
	my $sumNarbeit;
#select strftime("%Y", datum) as jahr, sum(arbeit) as summe from arbeit
# where datum >= '1994-01-01' AND datum <= '1994-12-31' order by jahr >>> ok
	my $stmt = qq(
select strftime("%Y", datum) as jahr, sum(arbeit) as summe from arbeit
 where datum >= '$DatumVon' AND datum <= '$DatumBis' order by jahr 	
	);
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	$sumNarbeit = $result->{'summe'};
	return $sumNarbeit; 
}



sub getAnlageJahrSumNArbeit {    ## jahresproduktion anlage
	my ($id) = @_;

#select strftime("%Y", datum) as jahr, sum(nArbeit) as sumNarbeit from arbeit where anlageId = "5" group by jahr order by jahr
	my $sth;
	$sth = $dbh->prepare(
'select strftime("%Y", datum) as jahr, sum(arbeit) as sumNarbeit from arbeit where anlageId = ? group by jahr order by jahr'
	);
	$sth->execute($id);
	return $sth;

}

sub _getJahrMonatAnlageSumArbeit {    #not used
	my ($dJahr) = @_;

#select anlageid,  strftime('%Y', datum) as jahr, strftime('%m', datum) as monat, sum(nArbeit) from arbeit where jahr = ? group by anlageid, jahr, monat
	my $sth;
	$sth = $dbh->prepare(
'select anlageId,  strftime("%Y", datum) as jahr, strftime("%m", datum) as monat, sum(arbeit) from arbeit where jahr = ? group by jahr, monat, anlageId'
	);
	$sth->execute($dJahr);
	return $sth;
}

sub normaliseMonate {

	#TODO evtl. normalise monate = add for empty month when there are no data 

}

1;
