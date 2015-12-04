#!/usr/bin/perl

package Prod::Tbls;

use warnings;
use strict;

use Data::Dumper;

use Utili::LogCmdt;
use Utili::FileTools;
use Utili::Timi;


sub prodGesamtTbl {

	my $filePattern		= $AppEnergie::fileGesamt . "????.csv";
	my @files = Utili::FileTools::getFileListFromPattern( $AppEnergie::ae_outputDir, $filePattern );

	my $i = 0;
	foreach (@files) {
		my $fileIn = $files[$i];
		my $fileOut = Utili::FileTools::getPathFilenamePref($fileIn) . ".html";
		prodCsv2Tbl($fileIn, $fileOut);
		$i++;
	}
	return;	
} 



sub prodCsv2Tbl {
	my ($fileIn, $fileOut) = @_;

		open my $fh, '<', $fileIn or die "Could not open $fileIn: $!\n";    # ohne utf-8!!!!!!!
		Utili::LogCmdt::logWrite( ( caller(0) )[3], "read from csv\t$fileIn" );

		open my $fhHtml, '>', $fileOut or die "Could not open $fileOut: $!\n";

		# remove html +body
#print $fhHtml
#"<!DOCTYPE html><html lang='de'>	<head><link rel='stylesheet' href='table.css' type='text/css' /><meta charset=utf-8></head><body>";
		print $fhHtml "<table class='prodData'>\n";
		while ( my $line = <$fh> ) {
			print $fhHtml "<tr>";
			my @cells = split ',', $line;
			foreach my $cell (@cells) {
				$cell = cellTrimmer($cell);
				print $fhHtml "<td>$cell</td>";
			}
			print $fhHtml "</tr>\n";
		}
		print $fhHtml "</table>\n";
#print $fhHtml "</body></html>\n";

		close $fh;
		close $fhHtml;
		Utili::LogCmdt::logWrite( ( caller(0) )[3], "html-tbl written to\t$fileOut" );

	return;
	
}



sub cellTrimmer {
	my ($str) = @_;
	if ( $str eq "" ) {
		$str = $AppEnergie::ae_emptyValue;
	}
	return $str;
}

1;
