#!/usr/bin/perl

package PathogenPage;

use BuildingBlock;
use ReportFunctions;
use Encode qw/encode decode/;

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
    my $html_style = "$script_dir/HTML_styles/midog_stylesheet.css";
    my $midog_logo = "$script_dir/HTML_styles/MiDOG.Logo.R.png";
    my $VDI_logo = "$script_dir/HTML_styles/VDI.Logo.png";
    my $patient_species = lc($patient_info->{'Species'});
    my $sample_type = lc($patient_info->{'Sample Type'});
    my $exotic_animal = ReportFunctions::exotic_animal_classifier($patient_species); # if cats or dogs, 0; if others, 1;
#-----------------------------------------------------------------------------
# print HTML head
    my $title_line =  "<td id=\"title\">All-in-One Microbial Test</td>";
    if ($exotic_animal == 1) {
	$title_line = "<td id=\"title\">All-in-One Microbial Test<br><span style=\"color:red;\">Exotic Animal Report</span></td>"
    }
    my $VDI_logo_line = "";
    if ($sample_id =~ /^MiV[0-9]+/) {
	$VDI_logo_line = "<td><img src=\"$VDI_logo\" alt=\"VDI Logo!\" id=\"vdi_logo\"></td>";
	$title_line = "<td id=\"title\">GI Microbiome Panel</td>";
    }
    
    
    my $html_head = <<EOF;
<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
    <meta charset="utf-8">
    <title>Report</title>
    <link rel="stylesheet" href="$html_style">
</head>
<table class="page1header">
      <tr>
	<td><img src="$midog_logo" alt="Midog Logo!" id="logo"></td>
	$title_line
	$VDI_logo_line
	<td id="pagenum">Page $page_no of $tot_pages</td>
      </tr>
</table>
EOF
    print($f1 "$html_head\n");

    
#-----------------------------------------------------------------------------
# print sample infomration table
    my @row1 = ('Patient Name', 'Health Status', 'Account Number');
    my @row2 = ('Owner\'s Name', 'Ordered By', 'Sample ID');
    my @row3 = ('Breed', 'Email', 'Sample Type');
    my @row4 = ('Age', 'Hospital', 'Received Date');
    my @row5 = ('Species', 'Location', 'Report Date');
    my @sample_info_table_headers = (\@row1, \@row2, \@row3, \@row4, \@row5);
    
    # get today's date
    use Time::Piece;
    my $report_date = localtime()->strftime('%m/%d/%y');
    
    print($f1 "<div>\n<table class=\"sampleinfo\">\n");
    foreach my $i (@sample_info_table_headers){
	print($f1 "<tr>\n");
	for(my $j=0; $j<scalar(@{$i}); $j++){
	    my $name = $i->[$j];
	    my $value = $patient_info->{$name};
	    $value = encode("utf8",  $value, 1);
	    if ($name eq 'Account Number') {
		$name = 'Account #';
	    }
	    if ($name eq 'Ordered By') {
		$name = 'Ordered by';
	    }
	    if ($name eq 'Report Date') {
		$value = $report_date;
	    }
	    if (length($value)>40) {
		$value = substr($value, 0, 40);
	    }
	    if ($name eq 'Email') {
		if ($sample_id =~ /^MiV[0-9]+/) {
		    $value='';
		}
		
	    }
	    if ($j==1) { # give more width to the value column of the 2nd ones
		print($f1 "<td class=\"Name\">$name\:</td>\n<td class=\"Value2\">$value</td>\n");
	    }else{
		print($f1 "<td class=\"Name\">$name\:</td>\n<td class=\"Value\">$value</td>\n");
	    }
	    
	}
	print($f1 "</tr>\n");
    }
    print($f1 "</table>\n</div>\n");

    
#-----------------------------------------------------------------------------
# print Bacteria pathogen table
    print($f1 "<h2 style=\"float:left;\">Potential Clinically Relevant Microbes Detected:</h2>\n");
    my $canine_health_range_intro = <<EOF;
<p class='text'>Top 5 potential Bacterial and Eukaryotic pathogens are listed. The comprehensive list of all microbes are shown in page 3.
"Significance" column indicates the difference of the species' abundance from "Normal Range", i.e. its abundance in clinical healthy animals.
Less than 1000 cells of Bacteria or less than 10 cells of Fungi are often not clinically significant.
</p>
EOF

    my $general_patho_intro = <<EOF;
<p class='text'>Top 5 potential Bacterial and Eukaryotic pathogens are listed. The comprehensive list of all microbes are shown in page 3.
Less than 1000 cells of Bacteria or less than 10 cells of Fungi are often not clinically significant.
</p>
EOF
    my $patho_table_notes = <<EOF;
<p class=text'>
* AID stands for Animal Infection Database. It is a resource center to provide more information for microbes in animal microbiome settings.
</p>
EOF
  
    if (scalar(keys(%{$ref_range}))>0) {
	print($f1 "$canine_health_range_intro\n");
    }else{
	print($f1 "$general_patho_intro\n");
    }
    # Bacteria pathogen table
    my $bac_patho_file = "$input_dir/1.prok_pathogen_table.tsv";
    print($f1 "<h3>1.Bacteria</h3>\n");
    if (-e $bac_patho_file) {
	ReportFunctions::create_abun_table($f1, $bac_patho_file, $pathogen_ref_info, $ref_list);
	
    }else{
	print($f1 "<h4>No Known Bacterial Pathogen Detected!</h4>\n");
    }
    
    # fungal pathogen table
    my $fungi_patho_file = "$input_dir/2.euk_pathogen_table.tsv";
    print($f1 "<h3>2.Eukaryota</h3>\n");
    if (-e $fungi_patho_file) {
	ReportFunctions::create_abun_table($f1, $fungi_patho_file, $pathogen_ref_info, $ref_list);
    }else{
	print($f1 "<h4>No Known Eukaryotic Pathogen Detected!</h4>\n");
    }
    
    # virus pathogen table
    my $virus_patho_file = "$input_dir/7.virus_pathogen_table.tsv";
    print($f1 "<h3>3.Viruses</h3>\n");
    if (-e $virus_patho_file) {
	ReportFunctions::create_abun_table($f1, $virus_patho_file, $pathogen_ref_info, $ref_list);
    }else{
	print($f1 "<h4>No Known Virus Pathogen Detected!</h4>\n");
    }
    
    # if it is the right sample type and there is at least one table present, show the notes
    if (scalar(keys(%{$ref_range}))>0) {
	if ((-e $fungi_patho_file) ||(-e $bac_patho_file)) {
	    ReportFunctions::significance_abbr_key($f1);
	}
    }
    if ((-e $bac_patho_file) || (-e $fungi_patho_file)) {
	print($f1 "$patho_table_notes\n");
    }
#-----------------------------------------------------------------------------
    #microbial profile overview
    print($f1 "<p>&nbsp</p>\n");
    print($f1 "<h2>Microbial Overview:</h2>\n");
    my $microbial_overview_text = <<EOF;
<p class='note'>
<b>Domain Composition</b>: the relative abundance between Bacteria, Archaea and Eukaryota.
<b>Bacteria & Archaea</b>: the percentage profile of Bacteria and Archaea species alone.
<b>Eukaryota</b>: the percentage profile of Eukaryota species alone.
Each color represents a species. The larger the colored segment is, the more abundant the species is.
</p>
EOF
    my $bactera_vs_fungi_img = "$input_dir/1.prok_vs_euk.png";
    my $bactera_img = "$input_dir/2.prok_abun.png";
    my $fungi_img = "$input_dir/3.euk_abun.png";
    
    my $no_microbes_detected=<<EOF;
<h4>No Microbes were Detected</h4>
<p class="endnote">Please Note: It is common to see no microbial load in healthy urine samples. For more information see the Methods Section under: 'When no Microbial Species are Detected'.</p>
EOF
    my @figs = ($bactera_vs_fungi_img, $bactera_img, $fungi_img);
    my $microbial_overview_img="";
    
    if (-e $bactera_vs_fungi_img) {
	print($f1 "<table class=\"overview\">\n");
	print($f1 "<tr>\n");
	print($f1 "<td class=\"overview\"><img src=\"$bactera_vs_fungi_img\" alt=\"No microbes detected!\" class=\"donut\"></td>");
	   if (-e $bactera_img) {
	    print($f1 "<td class=\"overview\"><img src=\"$bactera_img\" alt=\"No bacteria or archaea detected!\" class=\"donut\"></td>");
	}else{
	    print($f1 "<td class=\"overview\">No bacteria or archaea detected!</td>");
	}
	if (-e $fungi_img) {
	    print($f1 "<td class=\"overview\"><img src=\"$fungi_img\" alt=\"No eukaryota detected!\" class=\"donut\"></td>");
	}else{
	    print($f1 "<td class=\"overview\">No eukaryota detected!</td>");
	}
	print($f1 "</table>\n");
	print($f1 "</tr>\n");
	print($f1 "$microbial_overview_text\n");
    }else{
	print($f1 "$no_microbes_detected\n");
    }
    
    
   
}


1;
