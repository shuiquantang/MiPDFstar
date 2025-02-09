#!/usr/bin/perl
use strict;
use warnings;
package AlphaDiversity;

sub create_alpha_div_plots{
    #$i, $input_dir, $tmp_dir, $AMR_reference_table
    my $sample_id = shift;
    my $project_dir = shift;
    my $tmp_dir = shift;
    my $ref_data_dir = shift;
    my $alpha_div_script_dir = shift;
    # bac alpha plots
    my $bac_abun_file = "$tmp_dir/$sample_id/3.bac_table.tsv";
    if (-e $bac_abun_file) {
	my $fecal_bac_ref = "$ref_data_dir/canine/feces/healthy_fecal_bac.txt";
	my $bac_output_file = "$tmp_dir/$sample_id/healthy_fecal_bac.txt";
	system("perl $ref_data_dir/canine/feces/apply_abun_cutoff.pl -i $fecal_bac_ref -o $bac_output_file -t 0.001");
	
	my $bac_species_table = "$project_dir/report_input_files/$sample_id/1.prok_perc.tsv";
	my $bac_shannon_plot = "$tmp_dir/$sample_id/prok_shannon.png";
	system("Rscript $alpha_div_script_dir/bac_shannon.R $bac_species_table $sample_id $bac_output_file $bac_shannon_plot > /dev/null 2>&1");
	
	my $bac_richness_plot = "$tmp_dir/$sample_id/prok_richness.png";
	system("Rscript $alpha_div_script_dir/bac_richness.R $bac_species_table  $sample_id $bac_output_file $bac_richness_plot > /dev/null 2>&1");
    }
    

    
    # fungi alpha plots
    my $fungi_abun_file = "$tmp_dir/$sample_id/4.fungi_table.tsv";
    if (-e $fungi_abun_file) {
	my $fecal_fungi_ref = "$ref_data_dir/canine/feces/healthy_fecal_fungal.txt";
	my $fungi_output_file = "$tmp_dir/$sample_id/healthy_fecal_fungal.txt";
	system("perl $ref_data_dir/canine/feces/apply_abun_cutoff.pl -i $fecal_fungi_ref -o $fungi_output_file -t 0.001");
	
	my $fungi_species_table = "$project_dir/report_input_files/$sample_id/1.euk_perc.tsv";
	my $fungi_shannon_plot = "$tmp_dir/$sample_id/fungi_shannon.png";
	system("Rscript $alpha_div_script_dir/euk_shannon.R $fungi_species_table  $sample_id $fungi_output_file $fungi_shannon_plot > /dev/null 2>&1");
	
	my $fungi_richness_plot = "$tmp_dir/$sample_id/fungi_richness.png";
	system("Rscript $alpha_div_script_dir/euk_richness.R $fungi_species_table  $sample_id $fungi_output_file $fungi_richness_plot > /dev/null 2>&1");
    }
    
    
    
}


1;
