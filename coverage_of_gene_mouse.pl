#!/usr/bin/env perl
# 
# Author:       mh23
# Maintainer:   mh23
# Created:  02.06.2015
# Name:  coverage_of_gene_mouse.pl <Ensembl_ID> <BAM>

# Description: This script can be used to get the coverage across all exons of a specific gene for mouse WES bam files

use Carp;
use strict;
use warnings;
use Bio::EnsEMBL::Registry;

######################
## Script Structure ##
######################

# 1 - Connect to the API
# 2 - Get command line input 
# 3 - Get exon locations of gene from API
# 4 - Use samtools mpileup (human ref genome) 



########################
## Connect to the API ##
########################

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
    -user => 'anonymous'
);


######################################
## Take input from the command line ##
######################################

# Take the Ensembl gene name as an input
my $gene_name = shift;
# Take a bam file as an input 
my $bam_file = shift;


#########################################
## Get positions of all exons of gene ##
#########################################

# Define the adaptor
my $gene_adaptor  = $registry->get_adaptor( 'Mouse', 'Core', 'Gene' );
my $gene = $gene_adaptor -> fetch_by_stable_id($gene_name);
my @transcripts = $gene->get_all_Transcripts();

my $gstring = feature2string($gene);
    #print "$gstring\n";

sub feature2string
{
    my $feature = shift;

    my $stable_id  = $feature->stable_id();
    my $seq_region = $feature->slice->seq_region_name();
    my $start      = $feature->start();
    my $end        = $feature->end();
    my $strand     = $feature->strand();

    return sprintf( "%s: %s:%d-%d (%+d)",
        $stable_id, $seq_region, $start, $end, $strand );
}

my $chr = $gene->chr_name();
my $can_tr = $gene->canonical_transcript();
my @exons = @{ $can_tr->get_all_Exons() };

my @starts; my @ex_ids; my @ends;
foreach my $exo (@exons){
	my $id = $exo->stable_id();
	my $start = $exo->start();
	my $end = $exo->end();
	push(@ex_ids, $id);
	push(@starts, $start);
	push(@ends, $end);
	#print "$id\t$chr\t$start\t$end\n";
}


#########################################
## Check samtools mpileup for coverage ##
#########################################

my $i = 0; my @coverages;
my $length = scalar @ex_ids;

for (my $i=0; $i < $length; $i++) {
	
	my $exon_length = $ends[$i]-$starts[$i]+1;
	
	my $range = "$chr".':'."$starts[$i]".'-'."$ends[$i]";
	my @mpileup_out;
	@mpileup_out =  `samtools mpileup  -A -Q 0 -r $range -f /lustre/scratch105/vrpipe/refs/mouse/GRCm38/GRCm38_68.fa $bam_file 2>/dev/null`; 

	my $cov = 0;
	foreach my $pos (@mpileup_out){
		chomp( $pos );    
    	my @s = split( /\t/, $pos );
		$cov = $cov+$s[3];
	}
	my $av_cov = $cov/$exon_length;
	
	push(@coverages, $av_cov);

}


###################
## Print results ##
###################


for (my $i=0; $i < $length; $i++) {
	print("$ex_ids[$i]\t$chr\t$starts[$i]\t$ends[$i]\t$coverages[$i]\n");}


