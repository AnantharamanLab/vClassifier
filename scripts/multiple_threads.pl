#!/usr/bin/perl -w

use strict;

use Getopt::Long;

my ($cpu,@line,$i);

GetOptions("c|cpu:i"=>\$cpu);

my $usage=<<"USAGE";

        Program:perl $0 <Shell_Script_file> -c 20

        <Shell_Script_file> should put all commands in a single line,separated with ";",a single line will be processed by a cpu

        Usage:perl $0 [options]

                -c      set the cpu number to use in parallel, default 5

USAGE

$cpu||=5;

die $usage if (@ARGV==0);

open IN,$ARGV[0] or die $usage;

while(<IN>){

    s/\&//g;

    next unless /\S+/;

    push @line,$_;

}

close IN;

for($i=0;$i<@line;$i++){

    if(fork){

    wait if $i+1 >= $cpu;

    }else{

    exec $line[$i];

    exit;

    }

}

wait while wait != -1;

