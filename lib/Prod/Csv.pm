#!/usr/bin/perl
# writes csv files

package Prod::Csv;
use warnings;
use strict;

use Data::Dumper;

use Utili::LogCmdt;
use Db::AeDb;
use Utili::Timi;
use Utili::Numi;

use Date::Simple ('date', 'today');


my @monateDe = (
	"Jan", "Feb", "Mar",  "Apr", "Mai", "Jun",
	"Jul", "Aug", "Sept", "Okt", "Nov", "Dez"
);
my @monateEn = (
	"jan", "feb", "mar",  "apr", "may", "jun",
	"jul", "aug", "sep", "oct", "nov", "dec"
);

my $monateTot = @monateDe;

	my $jahr;
	my $monat;
	my $anlageId;
	my $fh;
	my $file;
	my $value;


###############tagesproduktion analge der letzten 3 monate 
#datum, wert
 
sub prodAnlageTag {

	
	###zeitspanne ausrechnen
	my $datumBis = today();
	my $datumVon = $datumBis - 90;
	
	my $sth = Db::AeDb::getAnlagen();	
	while (my $resultAnlagen = $sth->fetchrow_hashref() ) {
		my $anlageId = @$resultAnlagen{id};
		my $anlage = @$resultAnlagen{anlage};

		$file = $AppEnergie::ae_outputDir . $AppEnergie::fileAnlageTag . "$anlage" . ".csv";
		open $fh, '>', $file or die "Could not open $file: $!\n"; # ohne utf-8!!!!!!!
		
		###header
		print $fh "date,Brutto Tagesproduktion (kWh)\n";
		my $sthAnlage = Db::AeDb::getAnlageTagBArbeit($anlageId, $datumVon, $datumBis);

			while (my $anlageResult = $sthAnlage->fetchrow_hashref() ) {
				my $datum = @$anlageResult{datum};
				my $bArbeit = @$anlageResult{bArbeit};
#print Dumper $anlageResult;
				print $fh "$datum,$bArbeit\n";
			}
			Utili::LogCmdt::logWrite((caller(0))[3], "csv written\t$file");
			close $fh;
			
	}
	return;
}


###############monatsproduktion analge der letzten 5 jahre 
#date, jahrx, jahry, ...
#jan
#feb
sub prodAnlageMonate {
	my $jahrBegin = Utili::Timi::getYearToday() - 5;
	my $jahrEnd = Utili::Timi::getYearToday();

	my $sth = Db::AeDb::getAnlagen();
	while (my $resultAnlagen = $sth->fetchrow_hashref() ) {
		my $anlageId = $resultAnlagen->{id};
		my $anlage = $resultAnlagen->{anlage};

		$file = $AppEnergie::ae_outputDir . $AppEnergie::fileAnlageMonat . "$anlage" . ".csv";
		open $fh, '>', $file or die "Could not open $file: $!\n"; # ohne utf-8!!!!!!!
				
		###header
		print $fh "date";
		for (my $jahr = $jahrBegin; $jahr <= $jahrEnd; $jahr++) {
    		print $fh ",$jahr";
		}
		print $fh "\n";		

		##data
			for (my $monat = 1; $monat <= 12; $monat++) {
				print $fh $monateEn[$monat-1];
				my $monatNum = "" . sprintf("%.2d", $monat) . ""; 

				for (my $jahr = $jahrBegin; $jahr <= $jahrEnd; $jahr++) {
		
					my $sum = Db::AeDb::getMonatSum($anlageId, $jahr, $monatNum);
					if (!$sum) {
						$sum = 0;
					}

					print $fh ",$sum";
				}
				print $fh "\n";
			}

			Utili::LogCmdt::logWrite((caller(0))[3], "csv written\t$file");
			close $fh;
	}
	return;	
}

#jahresproduktion anlage
sub prodAnlageJahr { 
	my $sth = Db::AeDb::getAnlagen();
	
	while (my $resultAnlagen = $sth->fetchrow_hashref() ) {
		my $anlageId = $resultAnlagen->{id};
		my $anlage = $resultAnlagen->{anlage};

		$file = $AppEnergie::ae_outputDir . $AppEnergie::fileAnlageJahr . "$anlage" . ".csv";
		open $fh, '>', $file or die "Could not open $file: $!\n"; # ohne utf-8!!!!!!!		
		
		###header
		print $fh "date,Netto Jahresproduktion (kWh)\n";

		
		my $sthAnlage = Db::AeDb::getAnlageJahrSumNArbeit($anlageId);
			while (my $anlageResult = $sthAnlage->fetchrow_hashref() ) {
#print Dumper \$anlageResult;
				my $jahr = $anlageResult->{jahr};
				if ($jahr) { 
					my $date = $jahr . "-12-31";
					my $sumNarbeit = $anlageResult->{sumNarbeit};
					print $fh "$date,$sumNarbeit\n";
				} else {
					Utili::LogCmdt::logWrite((caller(0))[3], "DATA ERROR anlage=\t$anlageId");
				}
				
			}
			Utili::LogCmdt::logWrite((caller(0))[3], "csv written\t$file");
			close $fh;
	}
	return;
}

# creates csv jahresproduktion ab 2014
sub prodGesamtAlleJahr {
	
	my $jahrBegin = 2014; #	ab 2014 bis today
	my $jahrEnd = Utili::Timi::getYearToday();
	

	my @anlagenArray = Db::AeDb::getAnlagenArrayHash();
	my $anlageTot = @anlagenArray; #=5
	
	for (my $jahr = $jahrBegin; $jahr <= $jahrEnd; $jahr++) {

		$file = $AppEnergie::ae_outputDir . $AppEnergie::fileGesamt . $jahr . ".csv";
		open $fh, '>', $file or die "Could not open $file: $!\n"; # ohne utf-8!!!!!!!

		my @sumAnlage = (0) x ($anlageTot + 1); #[0] vergessen wir!!!!
		my $sumJahr = 0;
		
		#add header
		print $fh ","; # 1.col empty!
		my $i = 0;
		foreach (@anlagenArray) { 
			print $fh $anlagenArray[$i]->{'beschreibung'} . ",";  
			$i++;
		}
		print $fh "Summe Monat,Summe ab Anfang Jahr\n";
		
		
		#data
		for (my $monat = 1; $monat <= 12; $monat++) {
			my $sumMonat = 0;
			my $monatNum = "" . sprintf("%.2d", $monat) . "";
			print $fh $monateDe[ $monat - 1 ];
			my $i = 0;
			foreach (@anlagenArray) {
				my $anlageId = $anlagenArray[$i]->{'id'};
				my $sum = Db::AeDb::getMonatSum($anlageId, $jahr, $monatNum);
				if (!$sum) {
					$sum = 0;
				}
				print $fh "," . Utili::Numi::formatNum($sum);
				$sumMonat = $sumMonat + $sum;
				$sumAnlage[$anlageId] = $sumAnlage[$anlageId] + $sum;
				$i++;
			}
			$sumJahr = $sumJahr + $sumMonat;
			print $fh "," . Utili::Numi::formatNum($sumMonat) . "," . Utili::Numi::formatNum($sumJahr) . "\n";
		}
		
		#footer
		print $fh "Summe";
		$i = 0;
		foreach (@anlagenArray) {
			my $anlageId = $anlagenArray[$i]->{'id'};		
			print $fh "," . Utili::Numi::formatNum($sumAnlage[$anlageId]);
			$i++;
		}
		print $fh "," . Utili::Numi::formatNum($sumJahr) . "," . Utili::Numi::formatNum($sumJahr) . "\n"; 
		
		Utili::LogCmdt::logWrite((caller(0))[3], "csv written\t$file");	
		close $fh;
	
	}
	
}



1;