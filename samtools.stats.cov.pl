#!/usr/bin/env perl

#Author:       mh23    
# Maintainer:   mh23
# Created:      09.11.2015

# Name: 		samtools.stats.cov.pl  -i $x
my $less_5_count = 0;
my $less_10_count = 0;
my $total_count = 0;
my $coverage_sum = 0;
my $av_cov = 0;
use Carp;
use strict;
use warnings;
use Getopt::Long;
my ($input);
# Get options from the command line
GetOptions
('i|input=s'         => \$input,);
#Check input was supplied
( $input && -f $input ) or die qq[Usage: $0 -i <input fa>\n];
#Open the file
my $ifh;
if( $input =~ /\.gz/ ){open($ifh, qq[gunzip -c $input|]);}else{open($ifh, $input ) or die $!;}
#Loop through the file
while( my $l = <$ifh> ){
	#remove any new line characters
	chomp( $l );
	#each line is:
	#[999-999]	999	1
	my @s = split('\t', $l );
	if ($s[1] < 5){$less_5_count=$less_5_count+$s[2]}
	if ($s[1] < 10) {$less_10_count=$less_10_count+$s[2]}
	$total_count=$total_count+$s[2];
	my $multiplication = $s[1]*$s[2];
	$coverage_sum = $coverage_sum + $multiplication;
	} #close while
close( $ifh );
$av_cov = $coverage_sum / $total_count;
print ("$total_count\t$av_cov\t$less_5_count\t$less_10_count\n");
