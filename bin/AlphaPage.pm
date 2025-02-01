#!/usr/bin/perl

package AlphaPage;

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
    my $midog_logo = "$script_dir/HTML_styles/MiDOG.Logo.R.png";
    my $patient_species = lc($patient_info->{'Species'});
    my $sample_type = lc($patient_info->{'Sample Type'});
    my $exotic_animal = ReportFunctions::exotic_animal_classifier($patient_species); # if cats or dogs, 0; if others, 1;
#-----------------------------------------------------------------------------
# print page 2 header
    my $page_header = ReportFunctions::get_header($page_no, $patient_info, $midog_logo, $tot_pages);
    print($f1 "$page_header\n");

#-----------------------------------------------------------------------------
# print Bacterial richness table
    print($f1 "<h2 style=\"float:left;\">Bacterial Richness Score</h2>\n");
    my $statement =<<EOF;
<p class="note">
The microbial richness score counts how many types of bacteria are found in the sample. A loss of microbial richness, 
indicated by a score below that of the clinical healthy reference range, is a common indication
of an unbalanced microbiome and can be an indicator of disease.
</p>
EOF
    my $else_statement = "<p>Bacterial richness score is not available!</p>\n";
    my $alt = "Bacterial Richness Image";
    
    my $img = "$input_dir/bac_richness.png";
    print_alpha_div_plot($statement, $else_statement, $alt, $img, $f1);
    
# print Bacterial evenness table
    print($f1 "<h2 style=\"float:left;\">Bacterial Evenness Score</h2>\n");
    $statement =<<EOF;
<p class="note">
The Microbial Evenness Score is an extension of the richness score above. The evenness score counts how many different kind of bacteria are found
in a sample (richness score) and how evenly their numbers are distributed. For example, if you find 3 different kind of bacteria, and their relative
distribution is 90:5:5, that score would be lower than a sample has a relative distribution of 33:33:33. A loss of microbial diveristy, indicted by a
score below that of the clinically healthy reference range, is a common indication of an unbalanced microbiome and can be an indicator of disease.
</p>
EOF
    $else_statement = "<p>Bacterial evenness score is not available!</p>\n";
    $alt = "Bacterial Evenness Image";
    $img = "$input_dir/bac_shannon.png";
    
    print_alpha_div_plot($statement, $else_statement, $alt, $img, $f1);

    
# print Bacterial richness table
    print($f1 "<h2 style=\"float:left;\">Fungal Richness Score</h2>\n");
    $statement =<<EOF;
<p class="note">
The richness score counts how many different types of fungi are found in the sample.
</p>
EOF
    $else_statement = "<p>Fungal richness score is not available!</p>\n";
    $alt = "Fungal Richness Image";
    
    $img = "$input_dir/fungi_richness.png";
    print_alpha_div_plot($statement, $else_statement, $alt, $img, $f1);
    
    
# print fungal evenness table
    print($f1 "<h2 style=\"float:left;\">Fungal Evenness Score</h2>\n");
    $statement =<<EOF;
<p class="note">
The evenness score is an extension of the richness score above. The evenness score counts how many different kind of fungi are found in a sample
(richness score) and how evenly their numbers are distributed.
</p>
EOF
    $else_statement = "<p>Fungal evenness score is not available!</p>\n";
    $alt = "Fungal Evenness Image";
    $img = "$input_dir/fungi_shannon.png";
    
    print_alpha_div_plot($statement, $else_statement, $alt, $img, $f1);
    
}

sub print_alpha_div_plot{
    my $statement = shift;
    my $else_statement = shift;
    my $alt = shift;
    my $img = shift;
    my $f1 = shift;
    if (-e $img) {
	print($f1 "$statement\n");
	print($f1 "<img src=\"$img\" alt=\"$alt\" class=\"div_plot\">\n");
    }else{
	print($f1 $else_statement);
    }
}

1;
