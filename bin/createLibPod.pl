#!/usr/bin/perl
use warnings;
use strict;

use File::Find;

 my @dir = qw(
	../lib
 );

my @filelist;
my $docDir	= "../doc";

find({ wanted => \&process_file, no_chdir => 1 }, @dir);

for (my $i = 0; $i < @filelist; $i++) { 
	my $docFile = substr($filelist[$i],2);
	my $docPathFile = "$docDir$docFile.html";
	print "**********perldoc $filelist[$i] to $docPathFile\n";

    my @args = ("perldoc", "-o", "html", "-d", $docPathFile, $filelist[$i]);
    system(@args);
#        or die "system @args failed: $?";	
	
	
}


sub process_file {
    if (-f $_) {
#        print "This is a file: $_\n";
        push(@filelist, $_); 
        
    } else {
        my $docDirSub = $docDir . substr($_, 2);
        my @args = ("mkdir", "-p", $docDirSub);
        system(@args);
    }
}

