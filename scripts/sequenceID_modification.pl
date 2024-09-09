#! /usr/bin/perl -w
use strict;

die "perl $0 <fna file 1><out file 1>" unless (@ARGV==2);
my $fq=$ARGV[0];
my $out=$ARGV[1];

open OUT1,">$out.raw"||die "Error in open $out\n";
open OUT2,">$out.num"|| die;
open FQ,$fq||die "Error in reading $fq\n";
my $seq="";
my $id="";
my $num=1;
chomp($id);
while (<FQ>) {
	chomp;
	if (/^\>/){
		if(length($seq) > 1) {
				$seq =~ s/(.*)/\U$1/; 
				print OUT1 "\>query".$num."_".$id."\n".$seq."\n";
				print OUT2 "\>query".$num."\n".$seq."\n";
				$num++;
		}
		$seq="";
		$id=$_;
		$id =~ s/>//;
	}
	else {$seq .= $_;}
}
if(length($seq) > 1) {$seq =~s/(.*)/\U$1/;print OUT1 "\>query".$num."_".$id."\n".$seq."\n";print OUT2 "\>query".$num."\n".$seq."\n";}
close FQ;
close OUT1;
close OUT2;

