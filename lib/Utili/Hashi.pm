#!/usr/bin/perl

package Utili::Hashi;
#some hash utilities

use warnings;
use strict;


sub printSortedHash {
	my ( %hash_1 ) = @_;
 	my @keys_2 = sort { $a cmp $b } keys %hash_1;
    foreach my $key ( @keys_2 ) {
        print "$key = $hash_1{$key}\n";
    }	    
	return;	
}

sub printSortedHashTabbed {
	my ( %hash_1 ) = @_;
 	my @keys_2 = sort { $a cmp $b } keys %hash_1;
    foreach my $key ( @keys_2 ) {
        if ($hash_1{$key}) {
        	print "$key\t$hash_1{$key}\t";	
        } else {
        	print "$key\t$Alex1to2::a1t2_emptyString\t";
        }
        
    }
    print "\n";
	return;	
}

sub writeSortedHashTabbed {
	my ( $fh1, %hash_1 ) = @_;
 	my @keys_2 = sort { $a cmp $b } keys %hash_1;
    foreach my $key ( @keys_2 ) {
        if ($hash_1{$key}) {
        	print $fh1 "$key\t$hash_1{$key}\t";	
        } else {
        	print $fh1 "$key\t$Alex1to2::a1t2_emptyString\t";
        }
        
    }
    print $fh1 "\n";
	return;	
}


sub printSortedHashLengthValueTabbed {
	my ( %hash_1 ) = @_;
 	my @keys_2 = sort { $a cmp $b } keys %hash_1;
    foreach my $key ( @keys_2 ) {
        print "$key\t" . length($hash_1{$key}) . "\t";
    }
    print "\n";
	return;	
}


sub printHash{
	my ( %hash_1 ) = @_;

	while ( my ($key, $value) = each(%hash_1) ) { # unsortiert
	        print "$key => $value\n";
	    }
	    
	return;
}




1;