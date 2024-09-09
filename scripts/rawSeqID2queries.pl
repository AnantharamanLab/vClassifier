#! /usr/perl/bin -w 
use strict; 
my $file1 = shift; 
my $file2 = shift;
my $file3 = shift;
my $pair_reads = shift;
my $single_reads = shift;
my ($name,%read,@col,$n); 
open IN1,$file1 or die $!;
while(<IN1>){
	  if(/>/){
	s/>//;
	s/_/__/;
           @col=split;
	my @id=split(/__/,$col[0]);
			$read{$id[1]}="$id[0]";
			}
}
close IN1;

open IN2,"$file2";
while(<IN2>){
	my @col=split;
	if($read{$col[0]}){
		print "$read{$col[0]}\t$_";
	}
}
close IN2;
