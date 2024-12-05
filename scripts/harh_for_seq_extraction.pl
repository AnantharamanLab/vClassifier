#!/usr/bin/perl -w
use strict;
use File::Copy;
my $file1 = shift; 
my $file2 = shift;
my $dir = shift;
my $name;
my %read;
open IN1,"$file1" or die $!;
while(<IN1>){
	chomp;
	if(/^>/){
		s/>//;
		s/\..*//;
        	$name=$_;
	}
	else{
		$read{$name}.=$_;
	}
}
close IN1;

open IN2,"$file2" or die $!;
while(<IN2>){
	chomp;
	if($_){
		open OUT,">$dir/$_";
		s/.fasta//;
		print OUT ">$_\n$read{$_}\n";
		close OUT;
	}
}
close IN2;
