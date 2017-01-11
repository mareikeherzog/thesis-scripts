#!/usr/bin/env perl

#Author:       mh23
# Maintainer:   mh23
# Created: 2014


use Carp;
use strict;
use warnings;
use Getopt::Long;

use List::Util qw(sum);

sub mean {
    return sum(@_)/@_;
}

#Get the bam file as input

my ($input);

GetOptions
(
'i|input=s'         => \$input,
);

( $input && -f $input ) or die qq[Usage: $0 -i <input vcf>\n];



my @mpileup_out;


@mpileup_out =  `samtools mpileup -l /nfs/users/nfs_m/mh23/rDNA_region.bed $input 2>/dev/null`; 


 
 my %mpileup_hash;
 my @positions;
 my @values;
 
foreach my $l (@mpileup_out){
 
	chomp( $l );	
	my @s = split( /\t/, $l );
 	
 	#the position is $s[1] & coverage is $s[3]
	#make it into a hash
	
	$mpileup_hash{$s[1]} = $s[3];
 
 
  	push(@positions, $s[1]); 
    push(@values, $s[3]); 
 
 }
 
 #go through the hash and take the mean of each 25
 
 #get length of array 
 
 my $length_ar = scalar @positions;
 my $length = $length_ar/25;


 
 
 my %output;
 
 for (my $i=0; $i < $length; $i++) {
 
 	my @mean_values=();
 	@mean_values = splice (@values, 0, 25);
 	my @mean_positions=();
 	@mean_positions = splice (@positions, 0, 25);
 	
 	#get the first position from the list of 25
 	my $pos = shift @mean_positions;
 	
 	#get the mean
 	my $mean = eval(join("+", @mean_values)) / @mean_values;
 	
 	$output{$pos}=$mean;
 	
 	 	
 } 
 
 #print output
 

 
print "$_ $output{$_}\n" for (sort { $a cmp $b } keys %output);