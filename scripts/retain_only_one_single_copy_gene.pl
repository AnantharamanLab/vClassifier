#! /usr/perl/bin -w 
use strict; 
my $file1 = shift; 
my $file2 = shift;
my ($name,%read,@col,$n); 
open IN1,$file1 or die $!;
while(<IN1>){
        @col=split;
	$read{$col[0]}=$_;
}
close IN1;

open OUT1,">$file2";
foreach my $key (sort keys %read){
	print OUT1 $read{$key};
}
