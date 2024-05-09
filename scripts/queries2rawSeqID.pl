#! /usr/perl/bin -w 
use strict; 
my $file1 = shift; 
my $file2 = shift;
my $file3 = shift;
my $pair_reads = shift;
my $single_reads = shift;
my %read; 
open IN1,"$file1" or die $!;
while(<IN1>){
	  if(/>/){
	s/>//;
	s/_/__/;
        my @col=split;
	my @id=split(/__/,$col[0]);
			$read{$id[0]}="$id[1]";
			}
}
close IN1;

open IN2,"$file2" or die $!;
while(<IN2>){
	my @col=split;
	print "$read{$col[0]}\t$_";
	}
close IN2;
