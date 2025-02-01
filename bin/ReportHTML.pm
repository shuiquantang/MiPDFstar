#!/usr/bin/perl -I /home/stdell/Desktop/debug/1.midog_report_scripts/midog_report_scripts/bin

package ReportHTML;
use BuildingBlock;
use PathogenPage;
use AmrPage;
use AmrgenePage;
use TaxaPage;
use AlphaPage;
use ReferencePage;
use ReportFunctions;
use Encode qw/encode decode/;


#$i, $patient_info, $pathogen_ref_info, $tmp_dir, $output_dir, $tag
sub create_report{
    my $sample_id = shift;#customer label
    my $patient_info = shift;
    my $pathogen_info = shift; # contain references information
    my $tmp_dir = shift;
    my $output_dir = shift;
    my $tag = shift;
    my $script_dir = shift;
    my $bac_pathogen_abun = shift;
    my $fungi_pathogen_abun = shift;
    my $s3_output_folder = shift;
    my $ref_range = shift;
    my $table_link=shift;
    my $report_HTML_file = "$tmp_dir/$sample_id/$sample_id\_report_$tag.html";
    my $random_str = $patient_info->{'Random String'};
    mkdir("$output_dir/$sample_id/$random_str");
    my $report_PDF_file = "$output_dir/$sample_id/$random_str/$sample_id\_report_$tag.pdf";
    open(my $f1, ">$report_HTML_file") or die;
    my $input_dir = "$tmp_dir/$sample_id";
    my @ref_list; # list of reference
    my $tot_pages = 5;
    if ($sample_id =~ /^MiV[0-9]+/) {
        if (BuildingBlock::canine_feces_only($patient_info)) {
	    $tot_pages ++;
	}
    }
    
    my $page_no = 1;
    PathogenPage::page($sample_id, $f1, $patient_info, $pathogen_info, $input_dir, $script_dir, \@ref_list, $tot_pages, $page_no, $ref_range);
    $page_no++;
    AmrPage::page($sample_id, $f1, $patient_info, $pathogen_info, $input_dir, $script_dir, \@ref_list, $bac_pathogen_abun, $fungi_pathogen_abun, $tot_pages, $page_no);
    $page_no++;
    TaxaPage::page($sample_id, $f1, $patient_info, $pathogen_info, $input_dir, $script_dir, \@ref_list, $tot_pages, $page_no, $ref_range);
    $page_no++;
    if ($sample_id =~ /^MiV[0-9]+/) {
	if (BuildingBlock::canine_feces_only($patient_info)){
	    AlphaPage::page($sample_id, $f1, $patient_info, $pathogen_info, $input_dir, $script_dir, \@ref_list, $tot_pages, $page_no);
	    $page_no ++;
	}
	
    }
    AmrgenePage::page($sample_id, $f1, $patient_info, $pathogen_info, $input_dir, $script_dir, $table_link, \@ref_list, $tot_pages, $page_no);
    $page_no++;
    ReferencePage::page($sample_id, $f1, $patient_info, $pathogen_info, $input_dir, $script_dir, \@ref_list, $tot_pages, $page_no);
    close $f1;
    ReportFunctions::html2pdf($report_HTML_file, $report_PDF_file);
    my $report_link = '';
    if (-e $report_PDF_file) {
	$report_link = "$s3_output_folder/$sample_id/$random_str/$sample_id\_report_$tag.pdf";
    }
    $patient_info->{'Report Link'}=$report_link;
    
}

sub compile_patient_info{
    #\@samples, $patient_info_coln_names, \%all_info, $summary_file
    my $tmp_dir = shift;
    my $samples = shift;
    my $summary_file = shift;
    my %order;
    my %lines;
    my %patient_info;
    my @coln_names;
    foreach my $i (@{$samples}){
	my $file = "$tmp_dir/$i/updated_info.tsv";
	if (-e $file) {
	    open(my $fh, "<$file") or die;
	    @coln_names = ();
	    while (my $line = <$fh>) {
		chomp $line;
		my @coln = split(/\t/, $line);
		$patient_info{$i}{$coln[0]}=$coln[1];
		push(@coln_names, $coln[0]);
	    }
	    close $fh;
	}
    }
    open(my $f1, ">$summary_file") or die;
    my $header = join("\t", @coln_names);
    print($f1 "$header\n");
    
    foreach my $i (keys%patient_info){
	my @coln = ();
	for(my $j=0; $j<scalar(@coln_names);$j++){
	    my $value = $patient_info{$i}{$coln_names[$j]};
	    push(@coln, $value);
	    if ($j==0) {
		my @id = split(/\_/, $value);
		$order{$i}=$id[1];
	    }
	}
	my $line = join("\t", @coln);
	$lines{$i}=$line;
    }
    
    my @order = sort{$order{$a} <=> $order{$b}}keys(%order);
    foreach my $i (@order){
	my $line = $lines{$i};
	$line = encode("utf8",  $line, 1);
	print($f1 "$line\n");
    }
    close $f1;
}

1;
