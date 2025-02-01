#!/usr/bin/perl -I /home/stdell/Desktop/debug/1.midog_report_scripts/midog_report_scripts/bin

#-i md0437.221114.zymo/report_input_files -t 221114 -s s3:// -p md0437 -l MI50042309
use strict;
use warnings;
use Getopts qw(Getopts);

use Inputs;
use SanityCheck;
use BuildingBlock;
use ReportHTML;
use AlphaDiversity;
use File::Spec::Functions;
use File::Basename;
use File::Path qw(remove_tree);
use Parallel::Loops;
use Cwd 'abs_path';

my $work_dir = `pwd`;
chomp $work_dir;
my $script_dir = dirname(__FILE__);
$script_dir = abs_path($script_dir);
my $bin_path = catdir($script_dir,'Bin');

use vars qw($opt_i $opt_t $opt_s $opt_l $opt_p $opt_c);
&Getopts('i:t:s:l:p:c:');
my $input_dir; if (!$opt_i) { die('report input directory -i\n');die}else{$input_dir=$opt_i;}
my @dir = split(/\//, $input_dir);
pop@dir;
my $project_dir = join("/", @dir);
my $tag; if (!$opt_t) { die('input tags -o\n');die}else{$tag=$opt_t;}
my $s3_output_dir; if (!$opt_s) { die('s3 output directory -s\n');die}else{$s3_output_dir=$opt_s;}
my $project_id =''; if ($opt_p){$project_id=$opt_p;}
my $sample_list=''; if ($opt_l){$sample_list=$opt_l;}
my $skip_samples_without_patient_info = 1;
if (defined($opt_c)){
      $skip_samples_without_patient_info=$opt_c;
} # if -c 0 -> don't skip; if -c 1, skip


my @samples;
if (length($sample_list)>0) {
      @samples = split(/\,/, $sample_list);
}else{
      @samples = Inputs::collect_samples($input_dir);
}

# check input files
SanityCheck::check_inputs(\@samples, $input_dir);

# generate intermediate figures and tables
my $tmp_dir = "$work_dir/report_intermediates";
my $output_dir = "$work_dir/reports";
Inputs::build_sample_folders($tmp_dir, \@samples);
Inputs::build_sample_folders($output_dir, \@samples);

# produce building blocks, create the report and upload to s3;
my $reference_data_dir = "$script_dir/reference_data";
my $AMR_reference_table = "$script_dir/reference_data/midog.pathogen.AMR.ref.tsv";
my $AMR_reference_table_fungi = "$script_dir/reference_data/midog.fungal.pathogen.AMR.ref.tsv";
my $AMR_gene_info_table = "$script_dir/reference_data/AMR_gene_drug_class.tsv";
my $eucast_intrinsic_resistance_file = "$script_dir/reference_data/Eucast_intrinsic_resistance.tsv";
my $donut_plot_scirpt = "$script_dir/bin/donut_plot.py";
my $alpha_div_script_dir = "$script_dir/bin/rscripts";
my @all_info;
my $patient_info_coln_names;
my $cpu = `nproc`;
chomp $cpu;
my $pl = Parallel::Loops->new($cpu);
$pl -> share( \@all_info );
$pl -> foreach (\@samples, sub{
      my $i = $_;
#foreach my $i (sort(@samples)){
      # read pathgen information, including species info, sample type info
      my ($patient_info, $coln_names) = Inputs::extract_patient_info($i, $input_dir);
      #skip the samples (e.g. controls) if it has no patient information
      if ($skip_samples_without_patient_info == 1) {
            if (scalar(keys(%{$patient_info}))==0) {remove_tree("$output_dir/$i"); remove_tree("$tmp_dir/$i");
                                                    return;
                                                    #next;
                                                    }
      }
      # read AID database
      my $AID_url = BuildingBlock::get_AID_url($reference_data_dir);
      # read pre-defined reference range based on sample type
      my $ref_range = BuildingBlock::get_reference_range($patient_info, $reference_data_dir);
      # read pre-defined pathogen list based on host species
      my $pathogen_ref_info = BuildingBlock::get_pathogen_list($patient_info, $reference_data_dir);
      # build AMR gene table
      my $amr_genes = BuildingBlock::create_AMR_gene_tables($i, $input_dir, $tmp_dir, $AMR_gene_info_table);
      # build abundance tables and return bacterial pathogen list and its relative abundance
      my ($bac_pathogen_abun, $fungi_pathogen_abun) = BuildingBlock::create_abun_tables($i, $input_dir, $tmp_dir, $pathogen_ref_info, $ref_range, $patient_info, $amr_genes, $AID_url);
      # create abundance donut plots$pathogen_ref_info
      BuildingBlock::create_donut_plots($donut_plot_scirpt, $i, $input_dir, $tmp_dir);
      # build AMR table for the detected bacterial pathogens
      my $bac_abun_table = '1.bac_cells.tsv';
      my $bac_pathogen_amr_table = '5.AMR.table.tsv';
      my $bac_amr_table = '6.AMR.table.all.microbes.tsv';
      BuildingBlock::create_AMR_tables($i, $input_dir, $tmp_dir, $AMR_reference_table, $eucast_intrinsic_resistance_file, $bac_pathogen_abun, $AMR_gene_info_table, $bac_pathogen_amr_table, $bac_amr_table, $bac_abun_table);
      # build AMR table for the detected fungi
      my $fungi_abun_table = '2.fungi_cells.tsv';
      my $fungi_pathogen_amr_table = '5a.fungi.AMR.table.tsv';
      my $fungi_amr_table = '6a.fungi.AMR.table.all.microbes.tsv';
      BuildingBlock::create_AMR_tables($i, $input_dir, $tmp_dir, $AMR_reference_table_fungi, $eucast_intrinsic_resistance_file, $fungi_pathogen_abun, $AMR_gene_info_table, $fungi_pathogen_amr_table, $fungi_amr_table, $fungi_abun_table);
      # Alpha diversity analysis
      if ($i =~ /^MiV[0-9]+/) {
            if (BuildingBlock::canine_feces_only($patient_info)) {
                  AlphaDiversity::create_alpha_div_plots($i, $project_dir, $tmp_dir, $reference_data_dir, $alpha_div_script_dir);
            }
      }
      
      # collect patient information
      my $zip_tables = "$i\_tables_$tag.zip";
      my $random_str = $patient_info->{'Random String'};
      my $table_link = "$s3_output_dir/$i/$random_str/$zip_tables";
      ## build the html report
      ReportHTML::create_report($i, $patient_info, $pathogen_ref_info, $tmp_dir, $output_dir, $tag, $script_dir, $bac_pathogen_abun, $fungi_pathogen_abun, $s3_output_dir, $ref_range, $table_link);
      $patient_info->{'tables_link'}=$table_link;
      push(@{$coln_names}, 'tables_link');
      write_info($tmp_dir, $i, $patient_info, $coln_names);
      system("zip -j $output_dir/$i/$random_str/$zip_tables $tmp_dir/$i/*.tsv");
#}
});

#create summary file including report links for report QC
my $summary_file = "$project_id\_report_summary_$tag.tsv";
ReportHTML::compile_patient_info($tmp_dir, \@samples, $summary_file);

sub write_info{
      my $tmp_dir=shift;
      my $i = shift;
      my $hash = shift;
      my $colns = shift;
      my $file = "$tmp_dir/$i/updated_info.tsv";
      open(my $f1, ">$file") or die;
      foreach my $i (@{$colns}){
            my $value = $hash->{$i};
            print($f1 "$i\t$value\n");
      }
      close $f1;
}
