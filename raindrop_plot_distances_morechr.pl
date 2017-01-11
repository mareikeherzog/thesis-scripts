#!/usr/bin/e:v perl

# Author:       mh23
# Maintainer:   mh23
# Created: 		February 2016
# Name:			raindrop_plot_distances_morechr.pl

use Carp;
use strict;
use warnings;

my $pos=0;
my $distance=0;
my $old_pos=0;
my $prev_chr='1';


#Get the bam file as input
my $input = shift;
my $ifi;
# Open the Conversion file and make arrays for the exonic location of the gene:
if( $input =~ /\.gz/ ){open($ifi, qq[gunzip -c $input|]);}else{open($ifi, $input ) or die $!;}
        #go through file line by line
        while( my $l = <$ifi> ) {
                next if( $l =~ /^#/);
                #check if the line is an INDEL or not
                my $indel = 0;
                if ( $l =~ /INDEL/) {$indel=1;} else {$indel=0;}
                chomp $l;
                #split the line into its columns
                my($f1, $f2, $f3, $f4) = split '\t', $l;
                
                #the position is the new position
                if ($f1 eq 'I') {$pos = $f2;}#size 230,218 
                elsif ($f1 eq 'II') {$pos = $f2+230218;} #size 813,184
                elsif ($f1 eq 'III') {$pos = $f2+1043402;} #size 316,620
                elsif ($f1 eq 'IV') {$pos = $f2+1360022 ;}#size 1,531,933
                elsif ($f1 eq 'V') {$pos = $f2+2891955;}#size 576,874
                elsif ($f1 eq 'VI') {$pos = $f2+3468829;}#size 270,161
                elsif ($f1 eq 'VII') {$pos = $f2+3738990;}#size 1,090,940
                elsif ($f1 eq 'VIII') {$pos = $f2+4829930;}#size 562,643
                elsif ($f1 eq 'IX') {$pos = $f2+ 5392573;}#size 439,888
                elsif ($f1 eq 'X') {$pos = $f2+5832461;}#size 745,751
                elsif ($f1 eq 'XI') {$pos = $f2+6578212;}#size 666,816
                elsif ($f1 eq 'XII') {$pos = $f2+7245028;}#size 1,078,177
                elsif ($f1 eq 'XIII') {$pos = $f2+8323205;}#size 924,431
                elsif ($f1 eq 'XIV') {$pos = $f2+9247636;}#size 784,333
                elsif ($f1 eq 'XV') {$pos = $f2+10031969;}#size 1,091,291
                elsif ($f1 eq 'XVI') {$pos = $f2+11123260;}#size 948,066
                else{print "Error\n";}
                #calculate the distance between the old and the new position
                
		#print "Chr: $f1  Pos: $f2 Added_pos: $pos Dist: $distance\n "; 
                if ($f1 ne $prev_chr) {$prev_chr = $f1; $old_pos = $pos; next;} 
                $distance = $pos - $old_pos;
                #print results
                #print "Chr: $f1  Pos: $f2 Added_pos: $pos Dist: $distance\n ";
                if ($indel==0) {print "$pos\t$distance\t0\n";}
                if ($indel==1) {print "$pos\t0\t$distance\n";}
                #update the position variables
                $old_pos = $pos;
                $prev_chr = $f1;
                $distance = '';
                $pos = '';              
        }#close while          
close( $ifi );

                                    
