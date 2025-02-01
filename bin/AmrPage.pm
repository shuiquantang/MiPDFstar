#!/usr/bin/perl

package AmrPage;

use BuildingBlock;
use ReportFunctions;

sub page{
    my $sample_id = shift;
    my $f1 = shift;
    my $patient_info = shift;
    my $pathogen_ref_info = shift;
    my $input_dir = shift;
    my $script_dir = shift;
    my $ref_list = shift;
    my $bac_pathogen_abun = shift;
    my $fungi_pathogen_abun = shift;
    my $tot_pages = shift;
    my $page_no = shift;
    my $midog_logo = "$script_dir/HTML_styles/MiDOG.Logo.R.png";
    my $patient_species = lc($patient_info->{'Species'});
    my $sample_type = lc($patient_info->{'Sample Type'});
    my $exotic_animal = ReportFunctions::exotic_animal_classifier($patient_species); # if cats or dogs, 0; if others, 1;
#-----------------------------------------------------------------------------
# print page 2 header
    my $page2_header = ReportFunctions::get_header($page_no, $patient_info, $midog_logo, $tot_pages);
    print($f1 "$page2_header\n");

#-----------------------------------------------------------------------------
# print AMR table
    print($f1 "<h4 style=\"float:left;\">Antimicrobial Resistance for Detected Clinically Relevant Microbes</h4>\n");
    my $AMR_statement =<<EOF;
<p class="note">
The sample was screened for antibiotic resistance genes and intrinsic resistances. Please follow antimicrobial stewardship guidelines for cautious antibiotic use.
</p>
EOF
    print($f1 "$AMR_statement\n");

    my $AMR_table_file = "$input_dir/5.AMR.table.tsv";
    if (scalar(keys(%{$bac_pathogen_abun}))>0) {
	if ($exotic_animal == 1) {
	    ReportFunctions::create_AMR_table_exotic($f1, $AMR_table_file, $bac_pathogen_abun);
	}else{
	    ReportFunctions::create_AMR_table($f1, $AMR_table_file, $bac_pathogen_abun);
	}
	
    }
    
    print($f1 "<p class=\"note\"> </p>\n");
    my $AMR_table_file_fungi = "$input_dir/5a.fungi.AMR.table.tsv";
    if (scalar(keys(%{$fungi_pathogen_abun}))>0) {
	
	if ($exotic_animal == 1) {
	    ReportFunctions::create_AMR_table_exotic($f1, $AMR_table_file_fungi, $fungi_pathogen_abun);
	}else{
	    ReportFunctions::create_AMR_table($f1, $AMR_table_file_fungi, $fungi_pathogen_abun);
	}
	
    }
    
    if (scalar(keys(%{$fungi_pathogen_abun}))>0 || scalar(keys(%{$bac_pathogen_abun}))>0) {
	
	if ($exotic_animal == 1) {
	    ReportFunctions::AMR_key_tables_exotic($f1);
	}else{
	    ReportFunctions::AMR_key_tables($f1);
	}
    }else{
	print($f1 "<h4 class=\"endnote\">No pathogens were detected!</h4>\n");
    }
    
}


1;
