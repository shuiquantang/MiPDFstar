#!/usr/bin/perl

package ReferencePage;

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
    my $midog_logo = "$script_dir/HTML_styles/MiDOG.Logo.R.png";
    my $patient_species = lc($patient_info->{'Species'});
    my $sample_type = lc($patient_info->{'Sample Type'});
#-----------------------------------------------------------------------------
# print page 5 header
    my $page_header = ReportFunctions::get_header($page_no, $patient_info, $midog_logo, $tot_pages);
    print($f1 "$page_header\n");

#-----------------------------------------------------------------------------
# print references
    print($f1 "<h2>References</h2>\n");
    print($f1 "<div class=\"ref\"><ol>\n");
    foreach my $i (@{$ref_list}){
	$i = encode("utf8",  $i, 1);
	print($f1 "<li>$i</li>\n");
    }
    print($f1 "</ol></div>\n");
# print methods
    my $methods = <<EOF;
    
<h2>Methods</h2>
<p>
The MiDOG<sup>&reg</sup> All-in-One Microbial Test is a targeted, Next-generation DNA sequencing testing service able to identify molecular
signatures unique to the identity and character of a specific microorganism. This test relies on safeguarded preservation and transport of
collected samples, thorough extraction of DNA from all microbes present in the specimen, select amplification of microbial DNA followed
by Next-generation DNA sequencing using the latest technologies from Illumina (Illumina, Inc., San Diego, CA). Data handling is done via
curated microbial databases to accurately align DNA sequences to ensure precise and accurate (species-level) identification of all bacteria
and fungi present in the specimen.
</p>
<h2>When no Bacterial or Fungal Species are Detected:</h2>
<p>
When no bacterial or fungal species are detected in this test, this result may be due to a very low microbial load and/or low concentration
of microbial DNA in the sample provided. In this case, we recommend re-sampling the area of interest and re-submitting specimen for analysis.
</p>
EOF

# Disclaimer
    my $disclaimer = <<EOF;

<h2>Phylogenetic Rank Abbreviations</h2>
<p>
If the detected bacterial or fungal taxon could not be identified down to the genus level, the closest phylogenetic rank identified is provided.
An abbreviation indicating the level of the rank is displayed aside. The meaning of the abbreviations is shown as:(p) Phylum level, (c) Class level,
(o) Order level, and (f) Family level.
</p>

<h2>Disclaimer</h2>
<p>
The information contained in this MiDOG<sup>&reg</sup> report is intended only to be factor for use in a diagnosis and treatment regime for the animal
patient. As with any diagnosis or treatment regime, you should use clinical discretion with each animal patient based on a complete
evaluation of the animal patient, including history, physical presentation and complete laboratory data, including confirmatory tests. All
test results should be evaluated in the context of the patients individual clinical presentation. The information in the MiDOG ® report has
not been evaluated by the FDA.
<br>&nbsp<br>
<br>&nbsp<br>
</p>
EOF

    my $customer_support= <<EOF;
<h3 style="text-align:center;">Customer Support</h3>
<p style="text-align:center;font-size:12px;line-height: 20px;">
Tel: (833)456-4364<br>
info\@midogtest.com<br>
www.midogtest.com
</p>
EOF

    if ($sample_id =~ /^MiV[0-9]+/) {
	$customer_support= <<EOF;
<h3 style="text-align:center;">Customer Support</h3>
<p style="text-align:center;font-size:12px;line-height: 20px;">
Tel: 805-577-6742<br>
consult\@vdilab.com<br>
www.vdilab.com
</p>
EOF
    }
    print($f1 "$methods\n$disclaimer\n$customer_support\n");

}
1;
