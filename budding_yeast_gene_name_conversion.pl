#!/software/bin/perl

# File: budding_yeast_gene_name_conversion.pl
#
# Command: perl /nfs/users/nfs_m/mh23/Scripts/budding_yeast_gene_name_conversion.pl  
# Author: Mareike Herzog
# Description:
# This script is used to convert the systematic yeast gene names (e.g. YBL088C) to their
# common yeast names (e.g. TEL1) and adds a third column containing the SGD description.
# Input 1 is the yeast conversion file: 
# /nfs/users/nfs_m/mh23/Reference_charts/yeast_genelist_nameconv.tsv
# Input 2 is a txt file with the systematic yeast names in the first column and no other 
# input.

use strict;
use warnings;

# Read the input:
my $conversion_file=shift;
my $input_file=shift;

# Declare variables:
my %name_conversion; # a hash with the systematic name as the key and the common name as the entry
my %description; # Build a hash with the systematic name as key and the description as entry



# Open the Conversion file and make hashes for the systematic gene names:
open(F, $conversion_file ) or die ("Unable to open file $conversion_file: $!\n" );
        #go through file line by line
        while ( my $line = <F>) {
                next if $. == 1; #first line skipped
                #split the line into its columns
                my($f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8) = split '\t', $line;
        		# $f2 is the systematic gene name; $f3 is the common name and $f4 is the description
                # Build a hash with the systematic name as the key and the common name as the entry
                $name_conversion{$f2}=$f3;
                # Build a hash with the systematic name as key and the description as entry
                $description{$f2}=$f4;
                #Test print:
        }# close while
close F or die "Cannot close $conversion_file: $!\n";


# Open the sample file and go line by line printing the conversions
open(F, $input_file) or die ("Unable to open file $input_file: $!\n" );
        #go through file line by line
        while ( my $line = <F>) {
			#split the line into its columns
            my($f1) = split '\t', $line;
			chomp($f1);
			print("$f1\t");
			if(defined($name_conversion{$f1})){
			print("$name_conversion{$f1}\t$description{$f1}\n");}
			else{print("\n");}
		}# close while
close F or die "Cannot close $input_file: $!\n";



