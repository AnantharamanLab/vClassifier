#!/usr/bin/perl -w
use strict;
use File::Copy;
my $file1 = shift; 
my $file2 = shift;
my $name;
my $seqlength;
my %read;
open IN1,"$file1" or die $!;
while(<IN1>){
	chomp;
	if(/^>/){
		s/>//;
		my @col=split(/-/,$_);
        	$name=$col[0];
	}
	else{
		$read{$name}=$_;
	}
}
close IN1;

while(my($key,$value) = each %read){
	$seqlength=length($value);
}

open IN2,"$file2" or die $!;
while(<IN2>){
	chomp;
	if($read{$_}){
		print ">$_\n$read{$_}\n";
	}
	else{
		print ">$_\n";
		for(my $i = 1; $i <= $seqlength; $i++){print "-";}
		print "\n";
	}
}
close IN2;

