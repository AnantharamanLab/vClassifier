#!/usr/bin/perl -w
use strict;
my $file1 = shift; 
my $file2 = shift;
my $name;
my $count;
my %taxon;
open IN1,"$file1" or die $!;
while(<IN1>){
	chomp;
	my @col=split(/\t/,$_);	
	$taxon{$col[0]}=$col[1];
}
close IN1;

open IN2,"$file2" or die $!;
while (<IN2>){
	chomp;
	if($taxon{$_}){
		print "$_\t$taxon{$_}\n";
	}
	else {
		print "$_\tNA\n"
	}
}
close IN2;
