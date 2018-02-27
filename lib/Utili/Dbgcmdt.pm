#!/usr/bin/perl 
###########################################
# some cmdt used debug functions


package Utili::Dbgcmdt;
use warnings;
use strict;

use Data::Dumper;
#use Devel::Peek;

#perl -d yourcode.pl #http://perldoc.perl.org/perldebug.html

my $before	= "";
my $after	= "\n";
my $delimiter	= "\t";

###################################
# prints caller, linenumber + string (optional)

sub prnwo {
	my ($text) = @_;
 	my ($package, $filename, $line) = caller;
 	print $before;
 	print "$package:$line";
 	if ($text) {
 		print "$delimiter$text";
 	}
 	print $after;

}

###################################
# Devel::Peek 

#SV = IV(0x1117de8) at 0x1117df8
#  REFCNT = 1
#  FLAGS = (ROK)
#  RV = 0x110d1b0
#  SV = PVHV(0x14cfd30) at 0x110d1b0
#    REFCNT = 3
#    FLAGS = (OBJECT,SHAREKEYS)
#    STASH = 0x1117870	"OOP51"
#    ARRAY = 0x111d050  (0:7, 1:1)
#  hash quality = 100.0%
#    KEYS = 1
#    FILL = 1
#    MAX = 7
#    Elt "config" HASH = 0x8e0b5f50
#    SV = IV(0x15ff108) at 0x15ff118
#      REFCNT = 1
#      FLAGS = (ROK)
#      RV = 0x110d198
#      SV = PVHV(0x14cfd10) at 0x110d198
#        REFCNT = 1
#        FLAGS = (SHAREKEYS)
#        ARRAY = 0x160de30  (0:7, 1:1)
#        hash quality = 100.0%
#        KEYS = 1
#        FILL = 1
#        MAX = 7
#        Elt "oop51param1" HASH = 0xabd0924f
#        SV = PV(0x10edc90) at 0x110d030
#          REFCNT = 1
#          FLAGS = (POK,IsCOW,pPOK)
#          PV = 0x11781c0 "oop51param1"\0
#          CUR = 11
#          LEN = 13
#          COW_REFCNT = 1


#sub dump{
#	my $self = shift;
# 	my ($package, $filename, $line) = caller;
# 	print $before;
# 	print "$package:$line";
# 	print $after;
#	Dump($self);
#}

###################################
# prints caller, linenumber + string (optional) + the whole $self in Dumper (what's coming in)

sub dumper{
	my ($self) = @_;
 	my ($package, $filename, $line) = caller;
 	print $before;
 	print "$package:$line";
# 	print $after;
	print Dumper $self;
}



1;