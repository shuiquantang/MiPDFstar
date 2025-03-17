#!/usr/bin/perl

package ReportFunctions;
use Inputs;


sub create_amr_gene_table{
    my $f1=shift;
    my $AMR_gene_table_file = shift;
    my %AMR_info;
    my ($row, $coln)= Inputs::read_tsv_table($AMR_gene_table_file, \%AMR_info);

    print($f1 "<table class=\"AMRgenetable\">\n");
    print($f1 "<tr>\n");
    for(my $i=0; $i<scalar(@{$coln});$i++){ # skip the last column
	my $name = $coln->[$i];
	if ($name =~ /^AMR_Gene_Detected/){
	    print($f1 "<th width=\"160px\" class=\"AMRgeneheader\">$name</th>\n");
	}elsif($name =~ /^Resistance_Against/){
	    print($f1 "<th width=\"290px\" class=\"AMRgeneheader\">$name</th>\n");
	}elsif($name =~ /^Function/){
	    print($f1 "<th width=\"290px\" class=\"AMRgeneheader\">$name</th>\n");
	}
	
    }
    print($f1 "</tr>\n");
    
    my $amr_genes_to_list = 60; # show top 50bp
    if (scalar(@{$row})<60) {
	$amr_genes_to_list = scalar(@{$row});
    }
    
    for (my $i=0; $i<$amr_genes_to_list;$i++){
	print($f1 "<tr>\n");
	my $amr_gene = $row->[$i];
	print($f1 "<td class=\"gene\"><i>$amr_gene</i></td>\n");
	for (my $j=1; $j<scalar(@{$coln})-2; $j++){
	    my $value = $AMR_info{$row->[$i]}{$coln->[$j]};
	    print($f1 "<td class=\"gene\">$value</td>\n");
	   
	}
	print($f1 "</tr>\n");
    }
    
    print($f1 "</table>\n");
}


sub html2pdf{
    my $html_file = shift;
    my $pdf_file = shift;
    system("wkhtmltopdf --disable-smart-shrinking --page-size letter --dpi 600 --margin-bottom 0.8cm --margin-left 0.8cm --margin-right 0.8cm --margin-top 0.8cm $html_file $pdf_file");
    # somehow the previous set margins does not work well with wkhtmltopdf. I had to reset the margins like this to make it work.
}

sub significance_abbr_key{
    my $f1 = shift;
    my $significance_abbreviation_keys = <<EOF;
<h4>Abbreviation Key:</h4>
<p class=\"note\">
<b>&nbsp;<span class='greendot'></span>&nbsp; Normal.</b> Within the reference range of clinically healthy animals. 
<b>&nbsp;<span class='greydot'></span>&nbsp; Intermediate.</b> Outside the reference range of clinically healthy animals.<br>
<b>&nbsp;<span class='reddot'></span>&nbsp; High.</b> Significantly higher than the reference range of clinically healthy animals.
</p>
EOF
    print($f1 "$significance_abbreviation_keys\n");
}


sub AMR_key_tables_exotic{
    my $f1 = shift;
    
    print($f1 "<h4>Abbreviation Keys and Symbols:</h4>");
    my $AMR_key_table = <<EOF;    
<table class="AMRkeytable">
    <tr>
	<td class="resistant" width="30px">NR</td>
	<td class="keyexplain" width="300px">Not Recommended (Due to either Resistance Genes Detected, Intrinsic Resistance, or <&nbsp10% Effectiveness in Antibiogram Studies)</td>
	<td class="keyexplain" width="110px"></td>
	<td class="symbols" width="30x">*</td>
	<td class="keyexplain" width="270px">Antibiotic Drug Tiers for Companion Animals, Antimicrobial Resistance and Stewardship Initiative, University of Minnesota</td>
    </tr>
    <tr>
	<td class="poor" width="30px">P</td>
	<td class="keyexplain" width="300px">Poor Performance (< 50% Effectiveness in Antibiogram Studies)</td>
	<td class="keyexplain" width="110px"></td>
	<td class="symbols" width="30x"></td>
	<td class="keyexplain" width="270px"></td>
    </tr>
    <tr>
	<td class="fair" width="30px">F</td>
	<td class="keyexplain" width="300px">Fair Performance (< 75% Effectiveness in Antibiogram Studies)</td>
	<td class="keyexplain" width="110px"></td>
	<td class="symbols" width="30x">&#167;</td>
	<td class="keyexplain" width="270px">Contraindicated in animal patients</td>
    </tr>
    <tr>
	<td class="good" width="30px">G</td>
	<td class="keyexplain" width="300px">Good Performance (> 75% Effectiveness in Antibiogram Studies)</td>
	<td class="keyexplain" width="110px"></td>
	<td class="symbols" width="30x">&#182;</td>
	<td class="keyexplain" width="270px">Variable bioavailability in animal patients</td>
    </tr>
    <tr>
	<td class="none" width="30px">NRD</td>
	<td class="keyexplain" width="300px">No Antibiotic Resistance Detected Based on the MiDOG Analysis</td>
	<td class="keyexplain" width="110px"></td>
	<td class="symbols" width="30x"></td>
	<td class="keyexplain" width="270px"></td>
    </tr>
</table>
 
EOF
    print($f1 "$AMR_key_table\n");
}

sub AMR_key_tables{
    my $f1 = shift;
    
    print($f1 "<h4>Abbreviation Keys and Symbols:</h4>");
    my $AMR_key_table = <<EOF;    
<table class="AMRkeytable">
    <tr>
	<td class="resistant" width="30px">NR</td>
	<td class="keyexplain" width="300px">Not Recommended (Due to either Resistance Genes Detected, Intrinsic Resistance, or <&nbsp10% Effectiveness in Antibiogram Studies)</td>
	<td class="deliverykey" width="30x">PO</td>
	<td class="keyexplain" width="80px">Oral, by mouth</td>
	<td class="symbols" width="30x">*</td>
	<td class="keyexplain" width="270px">Antibiotic Drug Tiers for Companion Animals, Antimicrobial Resistance and Stewardship Initiative, University of Minnesota</td>
    </tr>
    <tr>
	<td class="poor" width="30px">P</td>
	<td class="keyexplain" width="300px">Poor Performance (< 50% Effectiveness in Antibiogram Studies)</td>
	<td class="deliverykey" width="30x">IV</td>
	<td class="keyexplain" width="80px">Intravenous Injection</td>
	<td class="symbols" width="30x">&#8224;</td>
	<td class="keyexplain" width="270px">Dosis may vary based on patient species and/or type of infection. Reference at: www.midogtest.com/antibiotics</td>
    </tr>
    <tr>
	<td class="fair" width="30px">F</td>
	<td class="keyexplain" width="300px">Fair Performance (< 75% Effectiveness in Antibiogram Studies)</td>
	<td class="deliverykey" width="30x">SC</td>
	<td class="keyexplain" width="80px">Subcutaneous Injection</td>
	<td class="symbols" width="30x">&#167;</td>
	<td class="keyexplain" width="270px">Contraindicated in animal patients</td>
    </tr>
    <tr>
	<td class="good" width="30px">G</td>
	<td class="keyexplain" width="300px">Good Performance (> 75% Effectiveness in Antibiogram Studies)</td>
	<td class="deliverykey" width="30x">TU</td>
	<td class="keyexplain" width="80px">Topical Use</td>
	<td class="symbols" width="30x">&#182;</td>
	<td class="keyexplain" width="270px">Variable bioavailability in animal patients</td>
    </tr>
    <tr>
	<td class="none" width="30px">NRD</td>
	<td class="keyexplain" width="300px">No Antibiotic Resistance Detected Based on the MiDOG Analysis</td>
	<td class="deliverykey" width="30x">--</td>
	<td class="keyexplain" width="80px">No Info</td>
	<td class="symbols" width="30x"></td>
	<td class="keyexplain" width="270px"></td>
    </tr>
</table>
 
EOF
    print($f1 "$AMR_key_table\n");
}

sub create_AMR_table{
    my $f1=shift;
    my $AMR_table_file = shift;
    my $bac_pathogen_abun = shift;
    my %drug_info = shift;
    my ($row, $coln)= Inputs::read_tsv_table($AMR_table_file, \%drug_info);
    my @usage = @{$coln}[2,3];
    my @drug = @{$coln}[1,0];
    my $num = scalar(@{$coln});
    my @sp = @{$coln}[4..$num-1];
    my @coln_name = (@drug, @sp, @usage); 
    
    print($f1 "<table class=\"AMRtable\">\n");
    print($f1 "<tr>\n");
    my $fungi = 0;
    for(my $i=0; $i<scalar(@coln_name);$i++){
	my $name = $coln_name[$i];
	if ($name =~ /^Suggested Dose/){
	    print($f1 "<th width=\"110px\" class=\"AMRheader\">$name<sup>&#8224;</sup></th>\n");
	}elsif($name =~ /^Drug Delivery/){
	    print($f1 "<th width=\"70px\" class=\"AMRheader\">$name</th>\n");
	}elsif($name =~ /^Antibiotics|^Antifungals/){
	    print($f1 "<th width=\"80px\" class=\"AMRheader\">$name</th>\n");
	}elsif($name =~ /Drug Tiers/){
	    print($f1 "<th width=\"30px\" class=\"AMRheader\">$name*</th>\n");
	}elsif($name =~ /Drug Class/){
	    print($f1 "<th width=\"50px\" class=\"AMRheader\">$name</th>\n");
	    $fungi=1;
	}else{
	    my $abun = $bac_pathogen_abun->{$name};
	    $abun = sprintf("%.1f", $abun);
	    print($f1 "<th width=\"85px\" class=\"AMRheader\"><p><i>$name</i><br>($abun&nbsp%)</p></th>\n");
	}
	
	
    }
    print($f1 "</tr>\n");
    
    for (my $i=0; $i<scalar(@{$row});$i++){
	print($f1 "<tr>\n");
	my $drug = $row->[$i];
	for (my $j=0; $j<scalar(@coln_name); $j++){
	    my $value = $drug_info{$row->[$i]}{$coln_name[$j]};
	    if ($j==0) {
		if ($fungi == 0) {
		    if ($i ==0) {
			print($f1 "<td rowspan=\"23\" class=\"tier\">$value</td>\n");
		    }elsif($i==23){
			print($f1 "<td rowspan=\"7\" class=\"tier\">$value</td>\n");
		    }elsif($i==30){
			print($f1 "<td rowspan=\"14\" class=\"tier\">$value</td>\n");
		    }
		}else{
		    if ($i ==0) {
			print($f1 "<td rowspan=\"3\" class=\"tier\">$value</td>\n");
		    }elsif($i==3){
			print($f1 "<td rowspan=\"3\" class=\"tier\">$value</td>\n");
		    }elsif ($i>=6){
			print($f1 "<td class=\"tier\">$value</td>\n");
		    }
		}
		
		
	    }elsif($j==1){
		if ($drug eq 'Pradofloxacin') {
		    print($f1 "<td class=\"drug\">$drug<sup>&#167;</sup></td>");
		}elsif($drug eq 'Ciprofloxacin'){
		    print($f1 "<td class=\"drug\">$drug<sup>&#167;&#182;</sup></td>");
		}else{
		    print($f1 "<td class=\"drug\">$drug</td>");
		}
		
		
	    }elsif($j<$num-2){
		if ($value eq 'G') {
		    print($f1 "<td class=\"good\">$value</td>\n");
		}elsif ($value eq 'F') {
		    print($f1 "<td class=\"fair\">$value</td>\n");
		}elsif ($value eq 'P') {
		    print($f1 "<td class=\"poor\">$value</td>\n");
		}elsif($value eq 'NA'){
		    print($f1 "<td class=\"none\">NRD</td>");
		}else{
		    print($f1 "<td class=\"resistant\">NR</td>\n");
		}
	    }else{
		print($f1 "<td class=\"usage\">$value</td>\n");
	    }
	}
	print($f1 "</tr>\n");
    }
    
    print($f1 "</table>\n");
    
}


sub create_AMR_table_exotic{
    my $f1=shift;
    my $AMR_table_file = shift;
    my $bac_pathogen_abun = shift;
    my %drug_info = shift;
    my ($row, $coln)= Inputs::read_tsv_table($AMR_table_file, \%drug_info);
    my @drug = @{$coln}[1,0];
    my $num = scalar(@{$coln});
    my @sp = @{$coln}[4..$num-1];
    my @coln_name = (@drug, @sp); 
    
    print($f1 "<table class=\"AMRtable\">\n");
    print($f1 "<tr>\n");
    my $fungi=0;
    for(my $i=0; $i<scalar(@coln_name);$i++){
	my $name = $coln_name[$i];
	if ($name =~ /^Suggested Dose/){
	    print($f1 "<th width=\"110px\" class=\"AMRheader\">$name<sup>&#8224;</sup></th>\n");
	}elsif($name =~ /^Drug Delivery/){
	    print($f1 "<th width=\"70px\" class=\"AMRheader\">$name</th>\n");
	}elsif($name =~ /^Antibiotics|^Antifungals/){
	    print($f1 "<th width=\"80px\" class=\"AMRheader\">$name</th>\n");
	}elsif($name =~ /Drug Tiers/){
	    print($f1 "<th width=\"30px\" class=\"AMRheader\">$name*</th>\n");
	}elsif($name =~ /Drug Class/){
	    print($f1 "<th width=\"50px\" class=\"AMRheader\">$name</th>\n");
	    $fungi=1;
	}else{
	    my $abun = $bac_pathogen_abun->{$name};
	    $abun = sprintf("%.1f", $abun);
	    print($f1 "<th width=\"85px\" class=\"AMRheader\"><p><i>$name</i><br>($abun&nbsp%)</p></th>\n");
	}
	
	
    }
    print($f1 "</tr>\n");
    
    for (my $i=0; $i<scalar(@{$row});$i++){
	print($f1 "<tr>\n");
	my $drug = $row->[$i];
	for (my $j=0; $j<scalar(@coln_name); $j++){
	    my $value = $drug_info{$row->[$i]}{$coln_name[$j]};
	    if ($j==0) {
		if ($fungi == 0) {
		    if ($i ==0) {
			print($f1 "<td rowspan=\"23\" class=\"tier\">$value</td>\n");
		    }elsif($i==23){
			print($f1 "<td rowspan=\"7\" class=\"tier\">$value</td>\n");
		    }elsif($i==30){
			print($f1 "<td rowspan=\"14\" class=\"tier\">$value</td>\n");
		    }
		}else{
		    if ($i ==0) {
			print($f1 "<td rowspan=\"3\" class=\"tier\">$value</td>\n");
		    }elsif($i==3){
			print($f1 "<td rowspan=\"3\" class=\"tier\">$value</td>\n");
		    }elsif ($i>=6){
			print($f1 "<td class=\"tier\">$value</td>\n");
		    }
		}
	    }elsif($j==1){
		if ($drug eq 'Pradofloxacin') {
		    print($f1 "<td class=\"drug\">$drug<sup>&#167;</sup></td>");
		}elsif($drug eq 'Ciprofloxacin'){
		    print($f1 "<td class=\"drug\">$drug<sup>&#167;&#182;</sup></td>");
		}else{
		    print($f1 "<td class=\"drug\">$drug</td>");
		}
		
		
	    }elsif($j<$num-2){
		if ($value eq 'G') {
		    print($f1 "<td class=\"good\">$value</td>\n");
		}elsif ($value eq 'F') {
		    print($f1 "<td class=\"fair\">$value</td>\n");
		}elsif ($value eq 'P') {
		    print($f1 "<td class=\"poor\">$value</td>\n");
		}elsif($value eq 'NA'){
		    print($f1 "<td class=\"none\">NRD</td>");
		}else{
		    print($f1 "<td class=\"resistant\">NR</td>\n");
		}
	    }else{
		print($f1 "<td class=\"usage\">$value</td>\n");
	    }
	}
	print($f1 "</tr>\n");
    }
    
    print($f1 "</table>\n");
    
}


sub get_header{
    my $page_number=shift;
    my $patient_info = shift;
    my $midog_logo = shift;
    my $tot_pages = shift;
    my $patient_name = $patient_info->{'Patient Name'};
    my $owner_name = $patient_info->{"Owner\'s Name"};
    my $ordered = $patient_info->{"Ordered By"};
    my $account = $patient_info->{"Account Number"};
    my $page_header = <<EOF;
<table class="pageheader">
    <tr>
	<td rowspan="2" width="180px"><img src="$midog_logo" alt="Midog Logo!" id="logo2"></td>
	<td class="header1"><b>Patient Name:</b></td>
	<td class="header2">$patient_name</td>
	<td class="header1"><b>Ordered by:</b></td>
	<td class="header2">$ordered</td>
	<td rowspan="2" id="pagenum">Page $page_number of $tot_pages</td>
    </tr>
    <tr>
	<td class="header1"><b>Owner's Name:</b></td>
	<td class="header2">$owner_name</td>
	<td class="header1"><b>Account #:</b></td>
	<td class="header2">$account</td>
    </tr>
    
</table>
EOF
    return($page_header);
}

sub create_abun_table{
    my $f1=shift;
    my $abun_table_file= shift;
    my $pathogen_info = shift;
    my $ref_list = shift;
    
    my %taxa_abun;
    my ($row, $coln)= Inputs::read_csv_table2($abun_table_file, \%taxa_abun);
    print($f1 "<div>\n<table class=\"abuntable\">\n");
    print($f1 "<tr>\n");
    for(my $i=0; $i<scalar(@{$coln});$i++){
	my $name = $coln->[$i];
	if ($i == 0) {
	    print($f1 "<th class=\"species\">$name</th>\n");
	}elsif($name eq 'AID'){
	    print($f1 "<th class=\"abun2\">$name*</th>\n");
	}else{
	    print($f1 "<th class=\"abun\">$name</th>\n");
	}
    }
    print($f1 "</tr>\n");
    foreach my $x (@{$row}){
	print($f1 "<tr>\n");
	# find the refs, add to $ref_list, return the keys;
	my $new_refs = get_pathogen_ref($x, $pathogen_info);
	my $ref_keys = add_to_refs($new_refs, $ref_list);
	# print the pathogen names together with their keys.
	my $query_name =$x;
	$query_name=~ tr/\ /\+/;
	my $google_link = "https://www.google.com/search?q=$query_name";
	
	if (length($ref_keys)>0) {
	    if ($abun_table_file =~ /_pathogen_/) {
		print($f1 "<td class=\"species\"><a href=\"$google_link\"><i>$x</i></a> $ref_keys</td>\n");
	    }else{
		print($f1 "<td class=\"species\"><a href=\"$google_link\"><font color=\"red\"><i>$x</i></font></a> $ref_keys</td>\n");
	    }  
	}else{
	    print($f1 "<td class=\"species\"><a href=\"$google_link\"><i>$x</i></a></td>\n");
	}
	# print values;
	for (my $y=1; $y<scalar(@{$coln}); $y++){
	    my $key = $coln->[$y];
	    my $value = $taxa_abun{$x}{$key};
	    if ($key eq 'Percentage') {
		$value = sprintf("%.1f", $value);
		$value.= ' %';
	    }
	    if ($key eq 'Cells per Sample') {
		$value = round_to_2d($value);
		$value = commify($value);
	    }
	    
	     if ($key eq 'Normal Range') {
		if ($value =~ /%$/) {
		    $value = substr($value, 0, length($value)-1);
		    my @values = split(/\-/, $value);
		    $values[1] = sprintf("%.1f", $values[1]);
		    $values[1].= ' %';
		    $value = $values[0]."-".$values[1];
		}else{
		    if ($value =~ /\-/){
			my @values = split(/\-/, $value);
			$values[1] = round_to_2d($values[1]);
			$values[1] = commify($values[1]);
			$value = $values[0]."-".$values[1];
		    }
		    
		    
		}
		
		
	    }
	    
	    if ($key eq 'Significance') {
		if ($value eq 'High') {
		    print($f1 "<td class=\"abun\">&nbsp<span class=\"reddot\"></span>&nbsp$value</td>");
		}elsif($value eq 'Intermediate'){
		    print($f1 "<td class=\"abun\">&nbsp<span class=\"greydot\"></span>&nbsp$value</td>");
		}elsif($value eq 'Normal'){
		    print($f1 "<td class=\"abun\">&nbsp<span class=\"greendot\"></span>&nbsp$value</td>");
		}else{
		    print($f1 "<td class=\"abun\">NA</td>\n");
		}
	    }elsif ($key eq 'AID'){
		if (length($value)==0) {
		    print($f1 "<td class=\"abun2\">--</td>\n");
		}else{
		    my @urls = split(/\ /, $value);
		    my $html_text ='';
		    if (scalar(@urls)==1) {
			my $url = $urls[0];
			$html_text = "<a href=\"$url\">[Link]</a>";
		    }else{
			for (my $i=0; $i<scalar(@urls); $i++){
			    my $num = $i+1; my $url = $urls[$i];
			    my $text = "<a href=\"$url\">[$num]</a>";
			    $html_text.=$text;
			}
		    }
		    print($f1 "<td class=\"abun\">$html_text</td>\n");
		}
	    }else{
		print($f1 "<td class=\"abun\">$value</td>\n");
	    }
	    
	    
	}
	print($f1 "</tr>\n");
    }
    print($f1 "</table>\n</div>\n");
}

#referece
sub get_pathogen_ref{
    my $patho = shift;
    my $pathogen_ref_info = shift;
    my @refs=();
    $patho = pathogen_match($patho, $pathogen_ref_info); #some taxa that has '-' won't have a direct match
    if (exists($pathogen_ref_info->{$patho})) {
	if (length($pathogen_ref_info->{$patho}->{'Citation1'})>10) {
	    push(@refs, $pathogen_ref_info->{$patho}->{'Citation1'});
	}
	if (length($pathogen_ref_info->{$patho}->{'Citation2'})>10) {
	    push(@refs, $pathogen_ref_info->{$patho}->{'Citation2'});
	}
	if (length($pathogen_ref_info->{$patho}->{'Citation3'})>10) {
	    push(@refs, $pathogen_ref_info->{$patho}->{'Citation3'});
	}
    }

    return(\@refs);
}
sub pathogen_match{
    my $taxa = shift;
    my $ref_info = shift;
    my @sp = split(/\ |\-/, $taxa);
    my $genus = shift(@sp);
    foreach my $j (@sp){
	my $new_sp = $genus.' '.$j;
	if (exists($ref_info->{$new_sp})) {
	    return($new_sp);
	}
    }
    if (exists($ref_info->{$genus})) {
	return($genus);
    }
    
    return ($taxa);
}

sub add_to_refs{
    my $new_refs = shift;
    my $refs = shift;
    my %repeats = ();
    foreach my $i (@{$new_refs}){
	foreach my $j (@{$refs}){
	    if ($i eq $j) {
		$repeats{$i}++;
	    }
	    
	}
	
    }
    my @non_redunctant;
    foreach my $i (@{$new_refs}){
	if (exists($repeats{$i})) {
	    
	}else{
	    push(@non_redunctant, $i);
	}
	
    }
    if (scalar(@non_redunctant)>0) {
	push(@{$refs}, @non_redunctant);
    }
    
    
    my @keys;
    foreach my $i (@{$new_refs}){
	for (my $j=0; $j<scalar(@{$refs}); $j++){
	    if ($i eq $refs->[$j]) {
		my $key = $j+1;
		push(@keys, "$key");
	    }
	    
	}
    }
    @keys = sort{$a<=>$b}@keys;
    
    my $keys='';
    foreach my $i (@keys){
	$keys.="[$i]";
    }
    return $keys;
}


sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}

sub round_to_2d{
    my $num =shift;
    $num = int($num);
    my $digits = length("$num");
    my $div = 10**($digits-1);
    $num = sprintf("%.1f", $num/$div)*$div;
}

sub exotic_animal_classifier{
    my $species = shift;
    my @non_exotic_species = ("canine", "feline", "cat", "dog");
    my $exotic = 1;
    foreach my $i (@non_exotic_species){
	if (lc($species) eq $i) {
	    $exotic = 0;
	}
	
    }
    return($exotic);
    
}

1;
