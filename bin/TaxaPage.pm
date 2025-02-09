#!/usr/bin/perl

package TaxaPage;

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
    my $tot_pages = shift;
    my $page_no = shift;
    my $ref_range = shift;
    my $midog_logo = "$script_dir/HTML_styles/MiDOG.Logo.R.png";
    my $patient_species = lc($patient_info->{'Species'});
    my $sample_type = lc($patient_info->{'Sample Type'});
#-----------------------------------------------------------------------------
# print page 3 header
    my $page_header = ReportFunctions::get_header($page_no, $patient_info, $midog_logo, $tot_pages);
    print($f1 "$page_header\n");

#-----------------------------------------------------------------------------
# print Bacteria profile and table
    print($f1 "<h2 style=\"float:left;\">Supplemental Data</h2>\n");
    
    # healthy reference image depending on sample type.
   
    my $host = $patient_info->{'host'};
    my $site = $patient_info->{'site'};
    my $fungi_healthy_img ="$script_dir/reference_data/reference_ranges/$host/$site/fungi_healthy.svg";
    my $bac_healthy_img="$script_dir/reference_data/reference_ranges/$host/$site/bac_healthy.svg";;
    
    # print bacteria composition image
    print($f1 "<h3 style=\"float:left;\">Total Bacteria & Archaea Composition</h3>\n");
    my $bacteria_img = "$input_dir/2.prok_abun_2.png";
    if (-e $bacteria_img) {
	my $tot_bacteria_intro =<<EOF;	
<p>
Charts below depict the relative abundance of all detected bacterial/archaeal species. Each color represents a different species. The
larger the colored segment is, the more abundant that species is in the specimen.
</p>
EOF
	print($f1 "$tot_bacteria_intro\n");
	
	my $bacteria_overview_img="";
	if (-e $bac_healthy_img) {
	    $bacteria_overview_img= <<EOF;
<table class="overview">
    <tr>
	<td class="overview"><img src="$bacteria_img" alt="No bacteria or archaea detected!" class="donut"></td>
	<td class="overview"><img src="$bac_healthy_img" alt="No bacteria or archaea reference data!" class="donut"></td>
    </tr>
</table>
EOF
	}else{
	    $bacteria_overview_img= <<EOF;
<table class="overview">
    <tr>
	<td class="overview"><img src="$bacteria_img" alt="No bacteria or archaea detected!" class="donut"></td>
    </tr>
</table>
EOF
	}
	
	print($f1 "$bacteria_overview_img");
    }
    
    
    # print bacteria abundance table
    my $bac_abun_file = "$input_dir/3.prok_table.tsv";
    my $bac_table_intro =<<EOF;	
<p>
The table below lists top 8 bacterial/archaeal species detected within the limit of detection. The absolute and relative abundances of each species is shown. Potential clinically relevant microbes are highlighted in red.
</p>
EOF
    if (-e $bac_abun_file) {
	print($f1 "$bac_table_intro\n");
	ReportFunctions::create_abun_table($f1, $bac_abun_file, $pathogen_ref_info, $ref_list);
    }else{
	print($f1 "<h4>No bacteria or archaea detected!</h4>\n");
    }
    
    
    # print fungi images
    print($f1 "<p class=\"blank\">&nbsp</p>\n");
    print($f1 "<h3 style=\"float:left;\">Total Eukaryota Composition</h3>\n");
    my $fungi_img = "$input_dir/3.euk_abun_2.png";
    if (-e $fungi_img) {
	my $tot_fungi_intro =<<EOF;
<p>
Charts below depict the relative abundance of all detected eukaryotic species. Each color represents a different species. The
larger the colored segment is, the more abundant that species is in the specimen.
</p>
EOF
	print($f1 "$tot_fungi_intro\n");
	
	my $fungi_overview_img="";
	if (-e $fungi_healthy_img) {
	    $fungi_overview_img= <<EOF;
<table class="overview">
    <tr>
	<td class="overview"><img src="$fungi_img" alt="No eukaryotes detected!" class="donut"></td>
	<td class="overview"><img src="$fungi_healthy_img" alt="No eukaryotic reference data!" class="donut"></td>
    </tr>
</table>
EOF
	}else{
	    $fungi_overview_img= <<EOF;
<table class="overview">
    <tr>
	<td class="overview"><img src="$fungi_img" alt="No eukaryotes detected!" class="donut"></td>
    </tr>
</table>
EOF
	}
	
	print($f1 "$fungi_overview_img");
    }
    
    # print fungi table
    my $fungi_abun_file = "$input_dir/4.euk_table.tsv";
    my $fungi_table_intro =<<EOF;	
<p>
The table below lists top 8 eukaryotic species detected within the limit of detection. The absolute and relative abundances of each species is shown. Potential clinically relevant microbes are highlighted in red.
</p>
EOF
    if (-e $fungi_abun_file) {
	print($f1 "$fungi_table_intro\n");
	ReportFunctions::create_abun_table($f1, $fungi_abun_file, $pathogen_ref_info, $ref_list);
    }else{
	print($f1 "<h4>No eukaryotes detected!</h4>\n");
    }
    # print abbreviation keys
    if (scalar(keys(%{$ref_range}))>0) {
	if ((-e $fungi_abun_file) ||(-e $bac_abun_file)) {
	    ReportFunctions::significance_abbr_key($f1);
	}
    }
    my $AID_note =<<EOF;
<p class=text'>
* AID stands for Animal Infection Database. It is a resource center to provide more information for microbes in animal microbiome settings.
</p>
EOF
    if ((-e $bac_abun_file) || (-e $fungi_abun_file)){
	print($f1 "$AID_note\n");
    }
}


1;
