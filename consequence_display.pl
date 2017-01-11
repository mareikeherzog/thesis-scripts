#!/usr/bin/env perl
# 
# Author:       mh23
# Maintainer:   mh23
# Created:  15.06.2015
# Name:  consequence_display.pl

# Description: This script will go through a vcf file and count the consequencesof the 
# mutations that were called. If a mutation is associated with more than one consequence
# the one deemed more sever will be displayed. (Severity is indicated by the order of
# consequences in the array.  

use Carp;
use strict;
use warnings;
use Getopt::Long;


######################
## Script Structure ##
######################

# 1 - Declare a hash for results and an array for consequences
# 2 - Open the vcf
# 3 - Cycle through vcf & match for consequences one by one
# 4 - If a consequence matches increase hash counter by one
# 5 - Otherwise increase counter for outside gene
# 6 - Print results


#########################
## Making Hash & Array ##
#########################


my @csqs = ('initiator_codon_variant','stop_gained','frameshift_variant','splice_donor_variant','splice_acceptor_variant','splice_region_variant' ,'missense_variant','stop_lost','inframe_insertion','inframe_deletion');
my %results_indel;
my %results_snp;
# Make a key in the hash for each consequence and set the counter to 0
foreach my $c (@csqs) {
	$results_indel{$c}=0;
	$results_snp{$c}=0;
}
# Make a key for no consequence match
$results_indel{'Outside_gene'}=0;
$results_snp{'Outside_gene'}=0;

##############
## Open vcf ##
##############
my $input;
GetOptions
(
    'i|input=s'         => \$input,
);

( $input && -f $input ) or die qq[Usage: $0 -i <input vcf>\n];

my $ifh;
if( $input =~ /\.gz/ ){open($ifh, qq[gunzip -c $input|]);}else{open($ifh, $input ) or die $!;}

#######################
## Cycle through vcf ##
#######################

my $counter;
while( my $l = <$ifh> ){
	$counter = 0;
	chomp( $l );
    next if( $l =~ /^#/);
   	
   	####################
   	## Match for CSQs ##
   	####################
   	#cycle through all consequences
   	foreach my $csq (@csqs) {
   		#if the conseqeunces match move on
   		if ( $l =~ /$csq/i ){
   			#be sure there is a mutation 
   			if ($l =~ /1\/1/ || $l =~ /0\/1/){
   			#now check whether SNP or INDEL
   			
   			######################
   			## Increase counter ##
   			###################### 
   				if ( $l =~ /INDEL/i ){
   					$results_indel{$csq}++;
   					$counter = 1;
   					next;
   				} #close if
   				else {	
   					$results_snp{$csq}++;
   					$counter = 1;
   					next;
   				}#close else
   			}#close if
   		}#close if
   	}#close foreach
   #if none of the consequences matched, increase the other counter
   	if ($counter == 0){
   		if ( $l =~ /INDEL/i ){$results_indel{'Outside_gene'}++;}
   		else {$results_snp{'Outside_gene'}++;}
   	}
}#close while
close( $ifh );

###################
## Print results ##
###################
#print a header line
#foreach my $cons (@csqs){print ("$cons\t");} print("Outside_gene\n");
#print SNP data
foreach my $cons (@csqs){
	print ("$results_snp{$cons}\t");
}
print("$results_snp{'Outside_gene'}\n");




