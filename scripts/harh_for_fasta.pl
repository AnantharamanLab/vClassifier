#!/usr/bin/perl -w
use strict;
use File::Copy;
my $file1 = shift; 
my $file2 = shift;
my $name;
my $count;
my %read;
open IN1,"$file1" or die $!;
while(<IN1>){
	chomp;
	if(/^>/){
		s/>//;
        	$name=$_;
	}
	else{
		$read{$name}.=$_;
	}
}
close IN1;

while(my($key,$value) = each %read){
	print ">$key\n$value\n";
}

