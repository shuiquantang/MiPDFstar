#!/usr/bin/perl

package AmrgenePage;

use ReportFunctions;

sub page{
    my $sample_id = shift;
    my $f1 = shift;
    my $patient_info = shift;
    my $pathogen_ref_info = shift;
    my $input_dir = shift;
    my $script_dir = shift;
    my $table_link = shift;
    my $ref_list = shift;
    my $tot_pages = shift;
    my $page_no = shift;
    my $midog_logo = "$script_dir/HTML_styles/MiDOG.Logo.R.png";
    my $patient_species = lc($patient_info->{'Species'});
    my $sample_type = lc($patient_info->{'Sample Type'});
    # print page 3 header
    my $bac_abun_file = "$input_dir/3.bac_table.tsv";
    $page_header = ReportFunctions::get_header($page_no, $patient_info, $midog_logo, $tot_pages);
    print($f1 "$page_header\n");
    
    my $AMR_gene_table_intro =<<EOF;	
<p>
The table below lists antimicrobial resistance genes that are detected in this sample. For antibiotics usage guidance, please first refer to the "Antibiotic Resistance" table shown in Page 2.
 Use this table only as an additioanl resource when needed. Inferring antibiomicrobial resistance from the resistance genes detected should be cautious, espeically in a mixed microbial population.
</p>
EOF
    my $amr_gene_file = "$input_dir/all.amr.tsv";
    print($f1 "<h3 style=\"float:left;\">Antimicrobial Resistance Genes Detected</h3>\n");
    if ((-e $amr_gene_file) && (-e $bac_abun_file)) {
	print($f1 "$AMR_gene_table_intro\n");
	ReportFunctions::create_amr_gene_table($f1, $amr_gene_file);
    }else{
	print($f1 "<h4>No Antimicrobial Resistance Genes Detected!</h4>\n");
    }
    if ($sample_id =~ /^MiV[0-9]+/) {
        print($f1 "<h3 style=\"float:left;\">Abundance Table Download Link</h3>\n");
	#print($f1 "<td class=\"species\"><a href=\"$google_link\"><i>$x</i></a> $ref_keys</td>\n");
	print($f1 "<p><a href=\"$table_link\">$table_link</a></p>");
    }
}


1;
