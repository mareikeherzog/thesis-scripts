#!/usr/bin/env perl

# Author:       mh23
# Maintainer:   mh23
# Created: 		January 2016
# Name:			av_cov_bait_regions.pl

use Carp;
use strict;
use warnings;

#Get the bam file as input
my $input = shift;

#Locations of location files
my $gene_file='/lustre/scratch109/sanger/mh23/ReferenceFiles/BAIT_REGIONS.027612_D_BED_20110119.GRCm38.plus100.nr.bed';
#my $gene_file='/lustre/scratch109/sanger/mh23/ReferenceFiles/Josep_drugscreen_25_Covered.bed';
#my $gene_file = '/lustre/scratch109/sanger/mh23/Scripts/all_yeast_genes.txt';

my $num_of_nts = 0;
my $sum_of_covs = 0;

my @coverages;

my $chrom; my $st; my $en;
my $check=0; my $check_count=0;
my $length_of_gene=0;
my $ifi;
my $bait_range;

my @baits;

# Open the Conversion file and make arrays for the exonic location of the gene:
if( $gene_file =~ /\.gz/ ){open($ifi, qq[gunzip -c $gene_file|]);}else{open($ifi, $gene_file ) or die $!;}
        #go through file line by line
        while( my $line = <$ifi> ) {
                chomp $line;
                #split the line into its columns
                my $ln = $line;
                my($f2, $f3, $f4, $f5) = split '\t', $line;
                my $f6 = $f4 - $f3 +1;
                $chrom = $f2; $st = $f3; $en = $f4;
         		$bait_range = "$chrom".':'."$st".'-'."$en";
         		my $length = abs($en - $st +1);
         		$num_of_nts=$num_of_nts+$length;
         		push @baits, $bait_range;	       
        }#close while          

close( $ifi );

print ("$num_of_nts\n"); exit;


foreach my $range (@baits) {
	# empty array withs samtools results
	# define the array to store the samtools mpileup output
	my @mpileup_out;

	# use samtools mpileup to get the coverage for that position
	# execute samtools mpileup as a systems command and store the output in an array
	# capture results in array
	@mpileup_out =  `samtools mpileup  -A -Q 0 -r $range -f /nfs/users/nfs_m/mh23/ReferenceGenomes/Mouse/GRCm38_68.fa $input 2>/dev/null`; 
	#calculate average coverage of bait region
	#The output comes in the format: 
	#chr is $s[0] & the position is $s[1] & coverage is $s[3]
	my $coverage=0; 
	foreach my $l (@mpileup_out) {
		my($s0, $s1, $s2, $s3, $s4) = split '\t', $l;	
		push @coverages, $s3;
	}
}


# Getting the averages

foreach my $dp (@coverages){
	$sum_of_covs=$sum_of_covs+$dp;
}

my $average_cov = $sum_of_covs/$num_of_nts;

print ("$sum_of_covs\t$num_of_nts\t$average_cov\n");