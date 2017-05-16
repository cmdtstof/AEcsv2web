#!/usr/bin/perl
# DBI functions
#

package Db::ImportEmon;

use warnings;
use strict;

use Db::EmonDb;
use Utili::LogCmdt;
use Utili::Dbgcmdt;
use Utili::Datum;
use Time::Local;

#TODO check if emoncms time is gm/localtime???
#TODO check with schaltjahr 29.2.2016 ???



sub tester {

#	feed19tester(); #works
	
	
### getworkperday
	my $time = "20161028";	
	my $work = getWorkPerDay("feed_19", $time);
#	print "$time = $work (kWh)\n"; 
	
	
	
}

=pod
for all emonanlagen

	if emondb has newer date value then AeDB
		add emondb in AeDB  

endfor emonanlagen
write csv
upload csv


=cut
sub main {
	
	
	
}

# gives from feed the kwh for a day YYYYMMDD back
sub getWorkPerDay {
	my ($feed, $workday) = @_;

	my $year = substr($workday, 0, 4);
	my $mon = substr($workday, 4, 2);
	my $mday = substr($workday, 6, 2);
	
	$mon -= 1;
	my $timeFrom = timelocal(0,0,0,$mday,$mon,$year);
	my $timeTill = timelocal(59,59,23,$mday,$mon,$year);

Utili::Dbgcmdt::prnwo("from=$timeFrom till=$timeTill");

	my $kwSecSum = 0;
	my $secSum = 0;
	my $oldTime = 0;
	my $oldData = 0;
	
	my $querystr = "select * from feed_19 where time >= $timeFrom AND time <= $timeTill;";
Utili::Dbgcmdt::prnwo($querystr);	
	
	my $sth = Db::EmonDb::getQuerystrSth($querystr);	
	while (my $result = $sth->fetchrow_hashref() ) {

#Utili::Dbgcmdt::dumper($result);

		my $time = $result->{'time'};
		my $data = $result->{'data'};
		
		my $diffTime = $time - $oldTime;
		my $diffData = ($oldData + $data) / 2; #mittelwert ???
		
		$kwSecSum += $diffTime * $diffData;
		$secSum += $diffTime; #??? gibt das 24*3600 = 86400 ???
		
printTime($oldTime, $time, $data, $secSum, $kwSecSum);
		

		$oldTime = $time;
		$oldData = $data;
	
	}

	my $kwhSum = $kwSecSum / 86400;
print "day=$workday kWh=$kwhSum\n";

	return;

}





sub feed19tester {
	
# row1 = 1468312359
#perl -le 'print scalar localtime 1468312359;' >>>Tue Jul 12 10:32:39 2016
# row39767 = 1487127585
#perl -le 'print scalar localtime 1487127585;' >>>Wed Feb 15 03:59:45 2017

	
print "oldTime\tTime\tdiff\tdata\n";

	my $oldTime = 0;
	my $oldData = 0;

	my $sth = Db::EmonDb::getTableSth("feed_19");			
	while (my $result = $sth->fetchrow_hashref() ) {

#Utili::Dbgcmdt::dumper($result);
#  'data' => '47',
#          'time' => 1470877385

		my $time = $result->{'time'};
		my $data = $result->{'data'};
printTime($oldTime, $time, $data);
		$oldTime = $time;
		$oldData = $data;
	}

	return;		
}


sub printTime{
	my ($oldTime, $time, $data, $secSum, $kwSecSum) = @_;	

		my $oldTimeHuman = Utili::Datum::getPosix2HumanFormStr($oldTime);
		my $timeHuman = Utili::Datum::getPosix2HumanFormStr($time);
		my $diff = $time - $oldTime;
		my $str = "$oldTime\t$oldTimeHuman\t$time\t$timeHuman\t$diff\t$data\t$secSum\t$kwSecSum\n";
		print $str; 

	return;	
	
}



sub getFeeds{
	my $sth = Db::EmonDb::getFeedsSth();	
	while (my $result = $sth->fetchrow_hashref() ) {

Utili::Dbgcmdt::dumper($result);
	
	}
	return;
	
}








1;
