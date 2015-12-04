#!/usr/bin/perl

package Utili::FileTools;

use warnings;
use strict;

use Data::Dumper;


sub getFileListFromPattern {
#searchDir inkl. / on end!
	my ($searchDir, $filePattern) = @_;
	my $pathFilePattern = $searchDir . $filePattern;
	
	opendir my $dir,  $searchDir or die "Cannot open directory: $!";
	my @files = glob( $pathFilePattern );
	closedir $dir;
	
#	print Dumper \@files;

	return @files;
}

sub getPathFilenamePref {
#returns path/filename without extension
	my ($pathFilename) = @_;

	(my $without_extension = $pathFilename) =~ s/\.[^.]+$//;
#print Dumper $without_extension;
	return $without_extension;
	
 	
}
	



1;