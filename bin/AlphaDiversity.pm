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
    my $bac_shannon_table = "$tmp_dir/$sample_id/bac_shannon.txt";
    my $bac_richness_table = "$tmp_dir/$sample_id/bac_richness.txt";
    my $fungi_shannon_table = "$tmp_dir/$sample_id/fungi_shannon.txt";
    my $fungi_richness_table = "$tmp_dir/$sample_id/fungi_richness.txt";
    
    if (-e $bac_abun_file) {
	my $fecal_bac_ref = "$ref_data_dir/canine/feces/healthy_fecal_bac.txt";
	my $bac_output_file = "$tmp_dir/$sample_id/healthy_fecal_bac.txt";
	system("perl $ref_data_dir/canine/feces/apply_abun_cutoff.pl -i $fecal_bac_ref -o $bac_output_file -t 0.001");
	
	my $bac_species_table = "$project_dir/midog.a.Bac16Sv13/taxa_plots/sorted_otu_L7.txt";
	my $bac_shannon_plot = "$tmp_dir/$sample_id/bac_shannon.png";
	
	system("Rscript $alpha_div_script_dir/bac_shannon.R $bac_species_table $sample_id $bac_output_file $bac_shannon_plot $bac_shannon_table > /dev/null 2>&1");
	
	my $bac_richness_plot = "$tmp_dir/$sample_id/bac_richness.png";
	
	system("Rscript $alpha_div_script_dir/bac_richness.R $bac_species_table  $sample_id $bac_output_file $bac_richness_plot $bac_richness_table > /dev/null 2>&1");
    }
    

    
    # fungi alpha plots
    my $fungi_abun_file = "$tmp_dir/$sample_id/4.fungi_table.tsv";
    if (-e $fungi_abun_file) {
	my $fecal_fungi_ref = "$ref_data_dir/canine/feces/healthy_fecal_fungal.txt";
	my $fungi_output_file = "$tmp_dir/$sample_id/healthy_fecal_fungal.txt";
	system("perl $ref_data_dir/canine/feces/apply_abun_cutoff.pl -i $fecal_fungi_ref -o $fungi_output_file -t 0.001");
	
	my $fungi_species_table = "$project_dir/midog.b.FungiITS/taxa_plots/sorted_otu_L7.txt";
	my $fungi_shannon_plot = "$tmp_dir/$sample_id/fungi_shannon.png";
	
	system("Rscript $alpha_div_script_dir/fungi_shannon.R $fungi_species_table  $sample_id $fungi_output_file $fungi_shannon_plot $fungi_shannon_table > /dev/null 2>&1");
	
	my $fungi_richness_plot = "$tmp_dir/$sample_id/fungi_richness.png";
	
	system("Rscript $alpha_div_script_dir/fungi_richness.R $fungi_species_table  $sample_id $fungi_output_file $fungi_richness_plot $fungi_richness_table > /dev/null 2>&1");
    }
    my $alpha_div_table = "$tmp_dir/$sample_id/alpha_div.tsv";
    
    my %alpha_div;
    read_alpha_file($bac_shannon_table, 'bac_evenness', \%alpha_div);
    read_alpha_file($bac_richness_table, 'bac_richness', \%alpha_div);
    read_alpha_file($fungi_shannon_table, 'fungi_evenness', \%alpha_div);
    read_alpha_file($fungi_richness_table, 'fungi_richness', \%alpha_div);
    my @order = qw(bac_richness bac_evenness fungi_richness fungi_evenness);
    my $header = join("\t", @order);
    open(my $f1, ">$alpha_div_table") or die;
    print($f1 "$header\n");
    my @coln = ();
    foreach my $i (@order){
	my $value = 'NA';
	if (exists($alpha_div{$i})) {
	    $value = $alpha_div{$i};
	    $value = sprintf("%.1f", $value);
	}
	push(@coln, $value);
    }
    my $line = join("\t", @coln);
    print($f1 "$line\n");
    close $f1;
}


1;
