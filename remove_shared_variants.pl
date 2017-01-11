#!/usr/bin/env perl
# 
# Author:       mh23
# Maintainer:   mh23
# Created: 		17.03.2015
# Test: 		remove_shared_variants.pl -i merged.vcf > merged.removed.vcf

use Carp;
use strict;
use warnings;
use Getopt::Long;

my ($input);

GetOptions
(
    'i|input=s'         => \$input,
);

( $input && -f $input ) or die qq[Usage: $0 -i <input vcf>\n];

my $ifh;
if( $input =~ /\.gz/ ){open($ifh, qq[gunzip -c $input|]);}else{open($ifh, $input ) or die $!;}

my @samples;
while( my $l = <$ifh> )
{
    my $m = $l;
    my $counter = 0;
    chomp( $l );
    if( $l =~ /^#/ || $l =~ /^#CHROM/){ print $m; }
    next if( $l =~ /^#/ && $l !~ /^#CHROM/);
    my @s = split( /\t/, $l );
    if( $m =~ /#CHROM/ ){for(my $i=0;$i<@s;$i++){$samples[$i]=$s[$i];}next;}
	for(my $i=9;$i<@s;$i++){if($s[$i]=~/1\/1:/||$s[$i]=~/1\/0:/||$s[$i]=~/0\/1:/||$s[$i]=~/\//){
		$counter++;
	}}
	next if ($counter>1);
	print $m;
}
close( $ifh );