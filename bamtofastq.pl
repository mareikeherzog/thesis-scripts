#!/usr/bin/env perl
# 
# Author:       mh23
# Maintainer:   mh23
# Created: 2014_11_22

# command should look like: bam2fastq -o reads#.fastq 13791_2#1.bam


use Carp;
use strict;
use warnings;

#Get sample name from the command line
my $samplename = '';
my $sample;
my $lanename;
my $lane;
my $number;
$samplename = shift; 
chomp $samplename;

#Split the file location by the'/' 
#s[8] is the sample name; s[10] is the lane number
#but I am matching for the pattern anyway in case the dicrectory numbers are different
my @s = split( /\//, $samplename );
foreach my $sp (@s){
	if ($sp  =~ /SC_MFY/i) {$sample = $sp;}
	if ($sp  =~ /_1#/i && $sp !~ /bam/i) {$lane = $sp; $number = '_1'; $lanename = $sample.$number;}
	if ($sp  =~ /_2#/i && $sp !~ /bam/i) {$lane = $sp; $number = '_2'; $lanename = $sample.$number;}
}
#Check that the matching works
#
print ("$sample \t $lane \n ");

#now I need to build the command.
my $cmd;
if (defined $lane){
	$cmd = 'bsub -q normal -R "select[type==X86_64 && mem > 1000] rusage[mem=1000]" -M1000 -o bam.o -e bam.e -J bam '."'".'bam2fastq --force -o '."$lanename".'#.fastq '."$samplename"."'";
}
else {
	$cmd = 'bsub -q normal -R "select[type==X86_64 && mem > 1000] rusage[mem=1000]" -M1000 -o bam.o -e bam.e -J bam '."'".'bam2fastq --force -o '."$sample".'#.fastq '."$samplename"."'";
}
#print ("$cmd\n");
system($cmd);
