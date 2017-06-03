#!/usr/bin/perl
# DBI functions
#

package Db::ImportRaw;

use warnings;
use strict;

use Utili::Datum;
use Utili::Dbgcmdt;

#TODO must be changed if more then 9 anlagen!!!
my $fileRawArbeitIdLength = 1;  
my @checkFieldList = qw( arbeit );

sub tester {




	return;

}

sub importRawArbeit {
	
	my $filePattern = $AEdataProc::config{fileRawArbeit} . "*.csv";
	
	$AEdataProc::log->logWrite( ( caller(0) )[3], "start importing raw data\t$filePattern" );
	
	my @files =
	  Utili::FileTools::getFileListFromPattern( $AEdataProc::config{rawDataDir},
		$filePattern );

	foreach my $fileCsv (@files) {

		$AEdataProc::log->logWrite( ( caller(0) )[3], "start importing from file \t$fileCsv" );
		open my $fh, '<', $fileCsv
		  or die "Could not open $fileCsv: $!\n";    # ohne utf-8!!!!!!!
	
		my $anlageid = getAnlageidFromRawArbeit($fileCsv);

#print "importRaw anlageid=$anlageid\n";

		if ($anlageid) {
			if (Db::AeDb::existsAnlageid($anlageid)) { # check if anlageid exist			
		
				my @data;
				while (my $line = <$fh>) {
				    chomp $line; #remove newline
				    my @fields = split(/$AEdataProc::config{sep_char}/, $line);
				    push @data, \@fields;
				}

				for (my $i = 0; $i < @data; $i++) {
					my %newFields;

					$newFields{'anlageid'} = $anlageid;

					$newFields{'datum'} = checkValueDatum($data[$i][0]);
					if ($newFields{'datum'} eq "-1") {
						$AEdataProc::log->logWrite( ( caller(0) )[3], "QS ERROR kein datum in row\t$i+1" );
						next;
					}
					
					$newFields{'arbeit'} = checkValueArbeit($data[$i][1]);

					my %oldFields;
					my $oldFieldsRef = Db::AeDb::getArbeitAsHash(%newFields);
					
					if ($oldFieldsRef) {
						%oldFields = (%oldFields, %$oldFieldsRef);

						if (! defined $oldFields{'arbeit'}) {
#Utili::Dbgcmdt::prnwo("oldFields");
#Utili::Dbgcmdt::dumper(\%oldFields);
							$oldFields{'arbeit'} = 0;	
						}
						if ($newFields{'arbeit'} ne $oldFields{'arbeit'}) {
							my %updateFields;
							$updateFields{'arbeit'} = $newFields{'arbeit'};
							Db::AeDb::updateArbeit($oldFields{'id'}, %updateFields);						
							$AEdataProc::log->logWrite( ( caller(0) )[3], "updated anlage datum arbeit:\t$anlageid\t$newFields{'datum'}\t$newFields{'arbeit'}" );
						}
					} else { #insert

						Db::AeDb::insertHash('arbeit', %newFields);
						$AEdataProc::log->logWrite( ( caller(0) )[3], "inserted anlage datum arbeit:\t$anlageid\t$newFields{'datum'}\t$newFields{'arbeit'}" );

					} #if ($oldFieldsRef) {
				} #for (my $i = 1; $i < @data; $i++) {
			} #if (AeDb::existsAnlageid($anlageid)) {	
			else {
				$AEdataProc::log->logWrite( ( caller(0) )[3], "QS ERROR anlageid existiert nicht in tbl anlagen:\t$anlageid" );
			}

		} else { 			#no analageid found!!!!
			$AEdataProc::log->logWrite( ( caller(0) )[3], "QS ERROR keine anlageid gefunden in filename\t$$fileCsv" );
		}
	
	} #end foreach file
	
	
return;	
	
}

sub checkValueDatum {
	my ($datumIn) = @_;
	
	if ($datumIn) {
		return Utili::Datum::dateRawToDb($datumIn);

#TODO check for valid date

		
	} else {
		return '-1';		
	}
	
}


sub checkValueArbeit {
	my ($value) = @_;
	
	if ($value) {
		return $value;
	} else {
		return "0";
	}
	
}


sub getAnlageidFromRawArbeit {
	my ($fileCsv) = @_;
	my $anlageid;
	my $length = length ($AEdataProc::config{fileRawArbeit}); 
	my $start = index($fileCsv, $AEdataProc::config{fileRawArbeit});
	
	if ($start != -1) {
		$anlageid = substr($fileCsv, $start + $length, $fileRawArbeitIdLength);	
	}
	
	return $anlageid;
}


1;
