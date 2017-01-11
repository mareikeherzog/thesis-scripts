#! /usr/bin/perl
#
# File: intersect_vcf_mutlists.pl
#
# Command: perl /nfs/users/nfs_m/mh23/Scripts/intersect_vcf_mutlists.pl <mutationlistfile> <vcf file> 
# or:perl /nfs/users/nfs_m/mh23/Scripts/intersect_vcf_mutlists.pl  <vcf file> <mutationlistfile>
# Author: Mareike Herzog
# Description:
# This script can be used to check whether all mutations introduced into simulated genomes
# were actually found and are present in vcf files or whether the mutations found were
# present in the mutation lists 
        
        
use strict;
use warnings;

#get the files from the command line
my $mut_file=shift;
my $vcf_file=shift;

#variables
my $count;
my $found;
my $missed;
my $error;
my %miss;

#Open the mutation file
open(F, $mut_file ) or die ("Unable to open file $mut_file: $!\n" );
#go through file line by line
while ( my $line = <F>) {
	next if $. < 2; #first or first 72 line skipped
	my($f1, $f2, $f3, $f4) = split '\t', $line;	
	my $cat = "$f1\t$f2";
	
	my $command = qq[cat $vcf_file | egrep -w "$f1" | egrep -w "$f2" | wc -l];
    #$count = `$command`;
    
    
	if ($count == 1) {
		$found += 1;
	
	}
	if ($count > 1) {
		$error += 1;
	}
	else {
		$missed += 1;
		$miss{$cat} += 1;
	}
	
}
close F or die "Cannot close $mut_file: $!\n";

my $sum = $missed + $found;

my $percent=$found/$sum;

print("Output:\n");
print("Total number: $sum.\n");
print("Found Mutations: $found. \n");
print("Missed Mutations: $missed. \n");
print("Percentage of mutations found: $percent. \n");

foreach my $category ( sort { $a cmp $b } keys %miss ){
	print("$category\n");
}
