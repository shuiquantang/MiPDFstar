#!/usr/bin/perl

package BuildingBlock;
use Inputs;

use Text::CSV;

sub create_donut_plots{
    my $donut_plot_script = shift;
    my $sample_id = shift;
    my $input_dir = shift;
    my $tmp_dir = shift;
    # python donut_plot.py -i inputs/domain.tsv -o domain_plot.svg -t "Bactera vs Fungi"
    my $domain_file = "$input_dir/$sample_id/domain_abun.tsv";
    if (-e $domain_file && -s $domain_file) {
	system("python3 $donut_plot_script -i $domain_file -o $tmp_dir/$sample_id/1.bac_vs_fungi.png -t \"Bacteria vs Fungi\" -s 0");
    }
    
    my $bac_file = "$input_dir/$sample_id/1.bac_perc.tsv";
    if (-e $bac_file && -s $bac_file) {
	system("python3 $donut_plot_script -i $bac_file -o $tmp_dir/$sample_id/2.bac_abun.png -t Bacteria -s 1");
	system("python3 $donut_plot_script -i $bac_file -o $tmp_dir/$sample_id/2.bac_abun_2.png -t \"Your Sample\" -s 1");
    }
    
    my $fungi_file = "$input_dir/$sample_id/2.fungi_perc.tsv";
    if (-e $fungi_file && -s $fungi_file) {
	system("python3 $donut_plot_script -i $fungi_file -o $tmp_dir/$sample_id/3.fungi_abun.png -t Fungi -s 1");
	system("python3 $donut_plot_script -i $fungi_file -o $tmp_dir/$sample_id/3.fungi_abun_2.png -t \"Your Sample\" -s 1");
    }
    
}

sub create_AMR_tables{
    #$i, $input_dir, $tmp_dir, $AMR_reference_table
    my $sample_id = shift;
    my $input_dir = shift;
    my $tmp_dir = shift;
    my $AMR_ref_table = shift;
    my $eucast_file = shift;
    my $pathogen_list = shift;
    my $AMR_gene_info_table = shift;
    my $pathogen_amr_table = shift;
    my $all_amr_table = shift;
    my $abun_table = shift;
    my %AMR_ref;
    my ($midog_drug_list, $header) = Inputs::read_tsv_table($AMR_ref_table, \%AMR_ref);
    Inputs::enroll_eucast_data(\%AMR_ref, $eucast_file);
    my %detected_drug_resistance;
    Inputs::read_drug_resistance_table("$input_dir/$sample_id/4.drug.resistance.tsv", \%detected_drug_resistance);
    my $abun = Inputs::read_abun_table("$input_dir/$sample_id/$abun_table");
    my @all_species = sort{$abun->{$b} <=> $abun->{$a}}keys%{$abun};
    my @patho_list = sort{$pathogen_list->{$b} <=> $pathogen_list->{$a}} keys(%{$pathogen_list});
    my $output_file = "$tmp_dir/$sample_id/$pathogen_amr_table";
    my $maximum_pathogens_to_show = 5;
    merge_print_AMR(\@patho_list, \%AMR_ref, \%detected_drug_resistance, $midog_drug_list, $header, $output_file, $maximum_pathogens_to_show);
    # print an intermediate file that output AMR info for all species including non-pathogenic ones.
    $output_file = "$tmp_dir/$sample_id/$all_amr_table";
    $maximum_pathogens_to_show = 1000;
    merge_print_AMR(\@all_species, \%AMR_ref, \%detected_drug_resistance, $midog_drug_list, $header, $output_file, $maximum_pathogens_to_show);
    
}


sub merge_print_AMR{
    my $patho_list=shift;
    my $AMR_ref = shift;
    my $detected_drug_resistance = shift;
    my $midog_drug_list = shift;
    my $header = shift;
    my $output_file = shift;
    my $maximum_pathogens_to_show = shift;
    my $drug_info;
    my @header = @{$header}[1,2,3];
    if (scalar(@{$patho_list})>$maximum_pathogens_to_show) {#
	my @new = @{$patho_list}[0..$maximum_pathogens_to_show-1];
	$patho_list = \@new;
    }
    foreach my $i (@{$midog_drug_list}){
	foreach my $j (@{$patho_list}){
	    my @sp = split(/\-|\ /, $j); # for ambiguous species
	    my $genus = shift(@sp);
	    $drug_info->{$i}->{$j}='NA';
	    my $sp_match=0;
	    foreach my $sp (@sp){
		my $species = "$genus $sp";
		if (exists($AMR_ref->{$i}->{$species})) {
		    $drug_info->{$i}->{$j}=$AMR_ref->{$i}->{$species};
		    $sp_match=1;
		}
	    }
	    if ($sp_match ==0) {
		# if no species match, then try to match the genus.
		if (exists($AMR_ref->{$i}->{$genus})) {
		    $drug_info->{$i}->{$j}=$AMR_ref->{$i}->{$genus};
		}
		
	    }
	    

	}
    }
    
    foreach my $i (@{$midog_drug_list}){
	foreach my $j (@header){
	    if (exists($AMR_ref->{$i}->{$j})) {
		    $drug_info->{$i}->{$j}=$AMR_ref->{$i}->{$j};
	    }
	}
    }
    push(@header, @{$patho_list});
    foreach my $i (@{$midog_drug_list}){
	foreach my $j (@header){
	    if (exists($detected_drug_resistance->{$i}->{$j})) {
		my @genes = @{$detected_drug_resistance->{$i}->{$j}};
		my $gene_list = join(" | ", @genes);
		$drug_info->{$i}->{$j}=$gene_list;
	    }
	    
	}
    }
    
    open(my $f1, ">$output_file") or die;
    my $coln_name = join("\t", @header);
    my $antibiotics = $header->[0];
    print($f1 "$antibiotics\t$coln_name\n");
    foreach my $i (@{$midog_drug_list}){
	my @coln = ($i);
	foreach my $j (@header){
	    my $value = $drug_info->{$i}->{$j};
	    push(@coln, $value);
	}
	my $line = join("\t", @coln);
	print($f1 "$line\n");
    }
    close $f1;
    
}

sub create_abun_tables{
    #$i, $input_dir, $tmp_dir, \%pathogen_list
    my $sample_id = shift;
    my $input_dir=shift;
    my $tmp_dir = shift;
    my $pathogen_ref_info=shift;

    my $ref_range = shift;
    my $patient_info = shift;
    my $amr_genes = shift;
    my $AID_url = shift;
    
    my $abs_bac = Inputs::read_abun_table("$input_dir/$sample_id/1.bac_cells.tsv");
    my $rel_bac = Inputs::read_abun_table("$input_dir/$sample_id/1.bac_perc.tsv");
    # buld bacterial pathogen table
    my $bac_pathogen_table = "$tmp_dir/$sample_id/1.bac_pathogen_table.tsv"; #table 1
    build_abun_table($abs_bac, $rel_bac, $ref_range, $bac_pathogen_table, 5, 0, $patient_info, $amr_genes, $AID_url, $pathogen_ref_info);
    # build bacteral abundance table
    my $bac_table="$tmp_dir/$sample_id/3.bac_table.tsv"; #table 3
    build_abun_table($abs_bac,$rel_bac, $ref_range, $bac_table, 8, 0, $patient_info, $amr_genes, $AID_url);
    
    my $abs_fungi = Inputs::read_abun_table("$input_dir/$sample_id/2.fungi_cells.tsv");
    my $rel_fungi = Inputs::read_abun_table("$input_dir/$sample_id/2.fungi_perc.tsv");
    # buld fungi pathogen table
    my $fungi_pathogen_table="$tmp_dir/$sample_id/2.fungi_pathogen_table.tsv"; #table 2
    build_abun_table($abs_fungi,$rel_fungi, $ref_range, $fungi_pathogen_table, 5, 0, $patient_info, $amr_genes, $AID_url, $pathogen_ref_info);
    # build fungi abundance tabl
    my $fungi_table="$tmp_dir/$sample_id/4.fungi_table.tsv"; #table 4
    build_abun_table($abs_fungi,$rel_fungi, $ref_range, $fungi_table, 8, 0, $patient_info, $amr_genes, $AID_url);
    
    #return bacteria pathogen relative abundance
    my $bac_pathogen_abun = pathogen_match($rel_bac, $pathogen_ref_info);
    my $fungi_pathogen_abun = pathogen_match($rel_fungi, $pathogen_ref_info);
    return ($bac_pathogen_abun, $fungi_pathogen_abun);
    
}

sub pathogen_match{
    my $sp2abun = shift;
    my $pathogen_ref = shift;
    my %patho2abun;
    foreach my $i (keys(%{$sp2abun})){
	my @sp = split(/\ |\-/, $i);
	my $genus = shift(@sp);
	foreach my $j (@sp){
	    my $new_sp = $genus.' '.$j;
	    if (exists($pathogen_ref->{$new_sp})) {
		$patho2abun{$i}=$sp2abun->{$i};
	    }elsif(exists($pathogen_ref->{$genus})){
		$patho2abun{$i}=$sp2abun->{$i};
	    }
	}
    }
    return(\%patho2abun);
}

sub build_abun_table{
    my $abs = $_[0];
    my $rel = $_[1];
    my $ref_range = $_[2];
    my $output_file = $_[3];
    my $maximum_species_to_show = $_[4];
    my $minimum_abs = $_[5];
    my $patient_info =$_[6];
    my $amr_genes = $_[7];
    my $AID_url = $_[8];
    my $species = $patient_info->{'Species'};
    my $sample_type = $patient_info->{'Sample Type'};
    my $pathogen_ref_info;
    
    # if it is a pathogen table
    if (scalar(@_)==10) {
	my $pathogen_ref_info = $_[9];
	$abs = pathogen_match($abs, $pathogen_ref_info);
	$rel = pathogen_match($rel, $pathogen_ref_info);
    }
    my @species_order = sort{$rel->{$b} <=> $rel->{$a}}keys(%{$rel});
    if (keys(@species_order)==0) { #empty tables
	return();
    }
    
    open(my $f1, ">$output_file") or die;
    my @titles;
    my $header='';
    my @columns;
    my $line='';
    
    my $counter = 0;
    if (%{$ref_range}) {
	@titles = ('Species Detected', 'AID', 'Percentage', 'Cells per Sample', 'Normal Range', 'Significance');
	$header = join(",", @titles);
	print($f1 "$header\n");
	foreach my $i (@species_order){
	    my $rel_abun = $rel->{$i};
	    my $abs_abun = $abs->{$i};
	    if ($abs_abun<=$minimum_abs) {
		next;
	    }
	    
	    my $low = 0;
	    my $C1 = 'Unknown';
	    my $C2 = 'Unknown';
	    my $key = $i;
	    
	    if ($i eq 'Staphylococcus pseudintermedius') {# special treatment for this species
		$key = "Staphylococcus delphini-intermedius-pseudintermedius";
	    }
	    $key =~ s/[\*]//g;
	    $key =~ s/^\s//g;
	    $key =~ s/\s$//g;
	    
	    if (exists($ref_range->{$key})) {
		$C1 = $ref_range->{$key}->{'C1'};
		$C2 = $ref_range->{$key}->{'C2'};
	    }
	    my $significance = '';
	    my $range='';
	    $range = "$low\-$C1";
	    if ($C1 eq 'Unknown') {
		$significance = 'NA';
		$range = 'NA'
	    }else{
		my $abun_to_compare = $abs_abun;
		my @feces_keywords = ('feces', 'fecal');
		if (word_match(lc($sample_type), \@feces_keywords)) {
		    $abun_to_compare = $rel_abun;
		    $range .= "%";
		}
		
		if ($abun_to_compare<$C1) {
		    $significance = 'Normal';
		}elsif($abun_to_compare<=$C2){
		    $significance = 'Intermediate';
		}else{
		    $significance = 'High';
		}
		
	    }
	    my $MRS_tag='';# the tag for methicillin-resistant staphylococcus sp.
	    $MRS_tag = assign_MRS_tag($i, $amr_genes);
	    my $AID_tag = search_AID_records($AID_url, $i);
	    print($f1 "$i$MRS_tag,$AID_tag,$rel_abun,$abs_abun,$range,$significance\n");
	    $counter++;
	    if ($counter == $maximum_species_to_show) {
		last;
	    }
	    
	    
	    
	}
	close $f1;
	
    }else{
	@titles = ('Species Detected', 'AID', 'Percentage (%)', 'Cells per Sample');
	$header = join(",", @titles);
	print($f1 "$header\n");
	foreach my $i (@species_order){
	    my $rel_abun = $rel->{$i};
	    my $abs_abun = $abs->{$i};
	    if ($abs_abun<=$minimum_abs) {
		next;
	    }
	    my $MRS_tag='';# the tag for methicillin-resistant staphylococcus sp.
	    $MRS_tag = assign_MRS_tag($i, $amr_genes);
	    my $AID_tag = search_AID_records($AID_url, $i);
	    print($f1 "$i$MRS_tag,$AID_tag,$rel_abun,$abs_abun\n");
	    $counter++;
	    if ($counter == $maximum_species_to_show) {
		last;
	    }
	}
    }
    
    
    
}

sub assign_MRS_tag{
    my $sp = shift;
    my $amr_genes = shift;
    my $tag = '';
    if (exists($amr_genes->{'mecA'})) {
	if ($sp eq 'Staphylococcus aureus') {
	    $tag = " (MRSA)";
	}elsif($sp eq 'Staphylococcus pseudintermedius'){
	    $tag = " (MRSP)";
	}elsif($sp eq 'Staphylococcus epidermidis'){
	    $tag = " (MRSE)";
	}elsif($sp eq 'Staphylococcus schleiferi'){
	    $tag = " (MRSS)";
	}
    }
    return($tag);
}

sub get_reference_range{
    my $patient_info=shift;
    my $ref_dir = shift;
    my $host_nomenclature_file = "$ref_dir/nomenclature_host_species.csv";
    my $species = $patient_info->{'Species'};
    my $breed = $patient_info->{'Breed'};
    my $host = word_search($species, $host_nomenclature_file);
    if (length($host) == 0) {
	$host = word_search($breed, $host_nomenclature_file);
    }
    $patient_info->{'host'}=$host;
    
    my $body_site_nomenclature_file = "$ref_dir/nomenclature_body_site.csv";
    my $sample_type = $patient_info->{'Sample Type'};
    my $body_site = '';
    if (exists($patient_info->{'Body Site'})) {
	$body_site = $patient_info->{'Body Site'};
    }
    
    my $site = word_search($sample_type, $body_site_nomenclature_file);
    if (length($site) == 0) {
	$site = word_search($body_site, $body_site_nomenclature_file);
    }
    $patient_info->{'site'}=$site;
    
    my $ref_file='';
    my %ref_range=();
    $ref_file = "$ref_dir/$host/$site/health_status_reference_range.csv";
    if (-e $ref_file) {
	Inputs::read_csv_table($ref_file, \%ref_range);
    }
    return(\%ref_range);
}

sub word_match{
    my $word = shift;
    my $refs = shift;
    foreach my $i (@{$refs}){
	if ($word =~ /$i/) {
	    return (1);
	}
	
    }
    return(0);
}




sub get_pathogen_list{
    my $patient_info = shift;
    my $pathogen_dir = shift;
    my $patient_species = lc($patient_info -> {'host'});
    $patient_species =~ s/\s+//g;
    my @nonexotic = ('canine', 'dog', 'feline', 'cat');
    my $pathogen_list="$pathogen_dir/exotic_pathogen_list.csv";
    foreach my $i (@nonexotic){
	if (lc($patient_species) eq $i) {
	    $pathogen_list = "$pathogen_dir/non_exotic_pathogen_list.csv";
	}
    }
    my %pathogen_ref;
    my @pathogens = Inputs::read_csv_table($pathogen_list, \%pathogen_ref);
    return(\%pathogen_ref);
}

sub build_sample_folders{
    my $dir = shift;
    
    if (-d $dir) {
	system("rm -r $dir");
    }else{
	mkdir($dir);
    }
    
    my $samples = shift;
    foreach my $i (@{$samples}){
	mkdir("$dir/$i");
    }
}

sub create_AMR_gene_tables{
    my $sample_id = shift;
    my $input_dir = shift;
    my $tmp_dir = shift;
    my $AMR_gene_info_table = shift;
    my %AMR_gene_info;
    my ($all_genes, $header1) = Inputs::read_tsv_table($AMR_gene_info_table, \%AMR_gene_info);
    my $input_file = "$input_dir/$sample_id/all.amr.tsv";
    my $output_file = "$tmp_dir/$sample_id/all.amr.tsv";
    my %AMR_genes;
    if (! -e $input_file) {
	return;
    }
    
    my ($genes, $header2) = Inputs::read_tsv_table($input_file, \%AMR_genes);
    my @genes = sort {$AMR_genes{$a}{'Resistance_Against'} cmp $AMR_genes{$b}{'Resistance_Against'}} keys(%AMR_genes);
    my @rows;
    my $max_genes_to_show=60;
    my $num=1;
    foreach my $i (@genes){
	my @id = split(/\./, $i);
	my $gene_name = join(" ", @id);
	my $gene_id = pop(@id);
	my $gene_full_name;
	my $drug_class;
	if (exists($AMR_gene_info{$gene_id})) {
	    $gene_full_name = $AMR_gene_info{$gene_id}{'Name'};
	    $drug_class = $AMR_gene_info{$gene_id}{'Drug Class'};
	}else{
	    next;
	}
	
	
	my $function = $AMR_gene_info{$gene_id}{'Function'};
	my $read_counts = $AMR_genes{$i}{'Copy_Number_Estimation'};
	my $mutation = $AMR_genes{$i}{'Mutation'};
	my $assign_to = $AMR_genes{$i}{'Assign_to'};
	if ($assign_to eq 'Staphylococcus delphini-intermedius-pseudintermedius') {
	    $assign_to = 'Staphylococcus pseudintermedius';
	}
	
	if ($mutation ne 'NA') {
	    $mutation = 'mutated';
	    $function.= " (mutated)";
	    if (length($assign_to)>0) {
		$gene_full_name = $gene_full_name." ($assign_to)";
	    }
	}
	
	if ($num>$max_genes_to_show) {
	    last;
	}
	
	my $row = "$gene_full_name\t$drug_class\t$function\t$mutation\t$read_counts";
	push(@rows, $row);
	$num++;
    }
    if (scalar(@rows)>0) {
	open(my $f1, ">$output_file") or die;
	print($f1 "AMR_Gene_Detected\tResistance_Against\tFunction\tMutation\tCopy_Number_Estimation\n");
	my $all_rows = join("\n", @rows);
	print($f1 "$all_rows\n");
	close $f1;
    }
    return(\%AMR_genes);
}

sub canine_feces_only{
    my $patient_info = shift;
    my $host = $patient_info->{'host'};
    my $site = $patient_info->{'site'};
    if (($host eq 'canine')&&($site eq 'feces')) {
	return(1);
    }else{
	return(0);
    }
    
}

sub word_search{
    my $query = shift;
    $query = lc($query);
    my $file = shift;
    if (length($query)==0) {
	return('');
    }
    my %dict;
    open(my $f1, "<$file") or die;
    while (my $line = <$f1>) {
	chomp $line;
	if ($line !~ /^#/) {
	    my @coln = split(/\,/, $line);
	    my $key_name = $coln[0];
	    foreach my $i (@coln){
		$i = lc($i);
		$i =~ s/^\s+|\s+$//g;
		if (length($i)==0) {
		    next;
		}
		
		if ($i =~ /\ /) {
		    if ($query =~ /$i/) {
			return($key_name);
		    }
		}else{
		    my @query_words = split(/\ /, $query);
		    foreach my $j (@query_words){
			$j =~ s/[^a-zA-Z-]//;
			if ($j =~ /^$i/) {
			    return($key_name);
			}
			
		    }
		}
		
		
	    }
	}
	
    }
    return(''); #if no matches are found, return empty string.
    
}

sub search_AID_records{
    my $AID_url = shift;
    my $species = shift;
    my @names = split(/\ /, $species);
    my $genus = $names[0];
    my @spp = split(/\-/, $names[1]);
    my @urls=();
    foreach my $i (@spp){
	my $sp = "$genus $i";
	if (exists($AID_url->{$sp})) {
	    my $url = $AID_url->{$sp};
	    push(@urls, $url);
	}
    }
    if (scalar(@urls)==0) {
	if (exists($AID_url->{$genus})) {
	    my $url = $AID_url->{$genus};
	    push(@urls, $url);
	}
	
    }
    my $tag = "";
    if (scalar(@urls)>0) {
	$tag = join(" ", @urls);
    }
    return $tag;
}

sub get_AID_url{
    my $ref_dir = shift;
    open(my $f1, "<$ref_dir/AID_url.tsv") or die;
    my %AID_url;
    while (my $line = <$f1>) {
	chomp $line;
	my @coln = split(/\t/, $line);
	$AID_url{$coln[0]}=$coln[1];
    }
    close $f1;
    return(\%AID_url);
}

1;
