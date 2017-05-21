#!/usr/bin/perl
# import data from emoncms power/kraft (kW) feed and produce work/arbeit (kwday) for adding in AeDb


# TODO arbeitemon inserted into tbl "arbeit", field "arbeitemon". > after test phase write into field "arbeit" 
#

#TODO check if emoncms time is gm/localtime???
#TODO check with schaltjahr 29.2.2016 ???
#TODO sub importFull ?????? for update values in emoncms db AND just in case something went wrong ????

#TODO wie sollte das ablaufen?
#cronjob täglich 
#- daten aus emoncms auslesen (vom jüngsten datum an) und in sqlight schreiben
#- csv erstellen und uploaden
#cronjob monatlich: alle daten erstellen (als security)


package Db::ImportEmon;

use warnings;
use strict;

use DateTime;

my %feeds = (
	furth => {
		feed      => "feed_19",
    },
 );


sub tester {

#	feed19tester(); #works
	
	
### getworkperday >> works
#	my $day = DateTime->new(year => 2016, month => 7, day => 28 );  
#	my $work = getWorkPerDay("feed_19", $day);
#Utili::Dbgcmdt::prnwo("$day $work");

#	compareData();

	importNotImported();
	
	
}

# imports all "feeds" into tbl "arbeit" 
sub importNotImported {

	foreach my $anlage ( keys %feeds ) {

		my $result	 = Db::AeDb::getAnlage($anlage);
		my $an_id	 = $result->{'id'};
		my $an_anlage = $result->{'anlage'};
		my $feed	 = $feeds{$anlage}{feed};
		
		my $importFrom;
		my $datum = Db::AeDb::getMaxEmonDatumForAnlage($an_id); 		#getmax date in AeDb for id (2007-12-13)
		if (! defined $datum) {
			$datum = Db::EmonDb::getMinTimeForFeed($feed); #get min time from emondb (1468312359) >>> load all data
			$importFrom = DateTime->from_epoch( epoch => $datum );
		} else {
			$importFrom = DateTime->new(year => substr($datum,0,4), month => substr($datum,5,2), day => substr($datum,8,2) );
		}
		$importFrom->add(days => 1); # next (full) day
		
		$datum = Db::EmonDb::getMaxTimeForFeed($feed);
		my $importTill = DateTime->from_epoch( epoch => $datum );
		$importTill->subtract(days => 1); # last full day
$AEdataProc::log->logWrite( ( caller(0) )[3], "$an_anlage ($an_id, feed=$feed) from=$importFrom till=$importTill" );
		while ($importFrom < $importTill) { 
			my %newFields = (
				anlageid	=> $an_id,
				datum		=> $importFrom->strftime("%Y-%m-%d"), #2017-05-19
				arbeitemon	=> getWorkPerDay($feed, $importFrom),
			);

#$newFields{'datum'} = "2018-01-01"; #TODO for test, remove after!!! 	
			my $oldFields = Db::AeDb::getArbeitAsHash(%newFields); #$result(hashref(id, datum, anlageid, arbeit, arbeitemon)) = getArbeitAsHash($hash(anlageid, datum))
			if ($oldFields) { #row exist > update
#Utili::Dbgcmdt::dumper(\$oldFields);
				my %updateFields = (
					arbeitemon	=> $newFields{'arbeitemon'},
				);
				Db::AeDb::updateArbeit($oldFields->{'id'}, %updateFields);
				$AEdataProc::log->logWrite( ( caller(0) )[3], "updated\tid=$oldFields->{'id'}\tanlage=$newFields{'anlageid'}\tdatum=$newFields{'datum'}\tarbeitemon=$updateFields{'arbeitemon'}" );
			} else { #row not exist > insert
				Db::AeDb::insertHash('arbeit', %newFields);
				$AEdataProc::log->logWrite( ( caller(0) )[3], "inserted\t\tanlage=$newFields{'anlageid'}\tdatum=$newFields{'datum'}\tarbeitemon=$newFields{'arbeitemon'}" );
			}
			
			$importFrom->add(days => 1);
		}
	} #foreach anlage
	return;
}


#compares existing data with emoncms data (test)
sub compareData{

	my $compareFrom = DateTime->new(year => 2016, month => 07, day => 13 ); 
	my $compareTill = DateTime->new(year => 2017, month => 02, day => 14 );
#	my $compareTill = DateTime->new(year => 2016, month => 07, day => 21 );

	my @array1;
	while ($compareFrom <= $compareTill) {
Utili::Dbgcmdt::prnwo($compareFrom);

		my %hash1;
		$hash1{'date'} = $compareFrom->strftime("%Y%m%d");

#get emon data for day
		$hash1{'emon'} = getWorkPerDay("feed_19", $compareFrom); # feed-table, day as DateTime object

#get existing arbeit for day
		$hash1{'arbeit'} = Db::AeDb::getArbeitTag(4, $compareFrom->strftime("%Y-%m-%d"));

#Utili::Dbgcmdt::dumper(\%hash1);

		push ( @array1, \%hash1);
		$compareFrom->add(days => 1);
	}

#Utili::Dbgcmdt::dumper(\@array1);

#print Dumper $array1[0];

	my $outfile = $AEdataProc::config{outputDir} . "compareData.csv"; 
	open my $fh, "> $outfile" or die "problem opening $outfile\n"; #write new
	for (my $i = 0; $i < @array1; $i++) {
		print $fh "$array1[$i]->{'date'}\t$array1[$i]{'arbeit'}\t$array1[$i]{'emon'}\n"; 
	}
	close $fh;


	
	return;
}



# gives back from feed the kwday for YYYYMMDD
sub getWorkPerDay {
	my ($feed, $dt) = @_; # feed-table, day as DateTime object
	
	my $timeFrom = DateTime->new(year=>$dt->year(),month=>$dt->month(),day=>$dt->day(),hour=>0,minute=>0,second=>0);
	my $timeTill = DateTime->new(year=>$dt->year(),month=>$dt->month(),day=>$dt->day(),hour=>23,minute=>59,second=>59);
#Utili::Dbgcmdt::prnwo("from=$timeFrom till=$timeTill");

	my $workSecSum = 0; #kWsec 
	my $secSum = 0;
	my $timeLast = $timeFrom->epoch();
	my $dataLast = 0;
	
	my $querystr = "select * from $feed where time >= ". $timeFrom->epoch() . " AND time <= " . $timeTill->epoch() . ";";
#Utili::Dbgcmdt::prnwo($querystr);
	
	my $sth = Db::EmonDb::getQuerystrSth($querystr);	
	while (my $result = $sth->fetchrow_hashref() ) {
##Utili::Dbgcmdt::dumper($result);

		my $timeNow = $result->{'time'}; #posix
		my $dataNow = $result->{'data'};
		my $timeDif = $timeNow - $timeLast;
##		my $dataAvg = ($dataNow + $dataLast) / 2; #mittelwert ??? day=20161028 w avg= 44.2528587962963, w/o avg=44.2580324074074
		my $dataAvg = $dataNow;
		$workSecSum += ($timeDif * $dataAvg);
		$secSum += $timeDif; 
		$timeLast = $timeNow;
		$dataLast = $dataNow;
	
	}

	$workSecSum += ((86400 - $secSum) * $dataLast ); # add for remaing sec 
	my $workdaySum = $workSecSum / 3600; #why 3600 and not 86400????

	return ($workdaySum);

}


1;