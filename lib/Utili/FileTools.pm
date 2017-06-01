#!/usr/bin/perl
package Utili::FileTools;
use warnings;
use strict;

#use Data::Dumper;

=head1 Utili::FileTools

some file utilities
	
=cut



=over

=item @files = getFileListFromPattern($searchDir, $filePattern)
=cut
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

=item $without_extension = getPathFilenamePref($pathFilename)
=cut

sub getPathFilenamePref {
	my ($pathFilename) = @_;

	(my $without_extension = $pathFilename) =~ s/\.[^.]+$//;
#print Dumper $without_extension;
	return $without_extension;
	
 	
}


1;

=back