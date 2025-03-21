#!/usr/bin/perl

package Inputs;

use Text::CSV;
use Encode qw/encode decode/;
use Spreadsheet::XLSX;

sub enroll_eucast_data{
    #\%AMR_ref, $eucast_file
    my $AMR_ref = shift;
    my $eucast_file = shift;
    open(my $f1, "<$eucast_file") or die;
    my $header = <$f1>; chomp $header;
    my @drugs = split(/\t/,$header);
    while (my $line = <$f1>) {
	chomp $line;
	my @coln = split(/\t/, $line);
	for (my $i=1; $i<scalar(@drugs); $i++){
	    add_to_amr_ref($AMR_ref, $coln[0], $drugs[$i], $coln[$i]);
	}
	
    }
    close $f1;
    
}

sub add_to_amr_ref{
    my $AMR_ref=shift;
    my $sp = shift;
    my $drugs = shift;
    my $value = shift;
    
    my @drugs = split(/\|/, $drugs);
    my @sp = split(/\|/, $sp);
    foreach my $i (@drugs){
	foreach my $j (@sp){
	    if ($AMR_ref->{$i}->{$j}) {
		next;
	    }else{
		$AMR_ref->{$i}->{$j}=$value;
	    }
	}
    }
}


sub collect_samples{
    my $root = shift;
    opendir(my $dir1, $root) or die;
    my @subfolders = ();
    while (my $item = readdir($dir1)) {
        # Use a regular expression to ignore files beginning with a period
        if (-d "$root/$item") {
	    next if ($item =~ m/^\./);
	    next if ($item eq 'report');
	    next if ($item eq 'knitr_tmp');
	    push(@subfolders, $item);
	}
    }
    return (@subfolders);
}

sub build_sample_folders{
    my $dir = shift;
    my $samples = shift;
    
    if (-d $dir) {
	system("rm -r $dir");
    }
    mkdir($dir);
    foreach my $i (@{$samples}){
	mkdir("$dir/$i");
    }
}

sub read_abun_table{
    my $abun_file = shift;
    my %abun_profile;
    if (-e $abun_file) {
	open(my $f1, "<$abun_file");
	while (my $line = <$f1>) {
	    chomp $line;
	    my @coln = split(/\t/, $line);
	    #if ($coln[0] eq 'Staphylococcus delphini-intermedius-pseudintermedius') {
		#$coln[0] = 'Staphylococcus pseudintermedius';
	    #}
	    $abun_profile{$coln[0]}=$coln[1];
	}
	close $f1;
    }
    return (\%abun_profile);
}

sub read_csv_table{
    my $table = shift;
    my $hash = shift;
    open(my $f1, "<$table") or die ("$table\n");
    my $header = <$f1>;
    $header = decode("UTF-8", $header);
    chomp $header; $header =~ s/\r//g;
    my $csv = Text::CSV->new();
    $csv->parse($header);
    my @header = $csv->fields();
    my @row_order;
    my @error;
    while (my $line = <$f1>) {
	$line = decode("UTF-8", $line);
	chomp $line; $line =~ s/\r//g;
	my $status = $csv->parse($line);
	if (!$status) {
	    push(@error, $line);
	}
	
	my @coln = $csv->fields();
	$coln[0] =~ s/^\s+|\s+$//g;
	$coln[0] =~ s/\*//g;
	if (length($coln[0])==0) {
	    next;
	}
	    
	push(@row_order, $coln[0]);
	for (my $i=1; $i<scalar(@header); $i++){
	    
	    $hash->{$coln[0]}{$header[$i]}=$coln[$i];
	    
	}
    }
    return(@row_order);
}

sub read_csv_table2{
    my $table = shift;
    my $hash = shift;
    open(my $f1, "<$table") or die("$table\n");
    my $header = <$f1>;
    chomp $header; $header =~ s/\r//g;
    my $csv = Text::CSV->new();
    $csv->parse($header);
    my @header = $csv->fields();
    my @row_order;
    my @error;
    while (my $line = <$f1>) {
	chomp $line; $line =~ s/\r//g;
	my $status = $csv->parse($line);
	if (!$status) {
	    push(@error, $line);
	}
	
	my @coln = $csv->fields();
	$coln[0] =~ s/^\s+|\s+$//g;
	if (length($coln[0])==0) {
		next;
	    }
	push(@row_order, $coln[0]);
	for (my $i=1; $i<scalar(@header); $i++){
	    
	    
	    $hash->{$coln[0]}{$header[$i]}=$coln[$i];
	    
	}
    }
    return(\@row_order, \@header);
}

sub read_tsv_table{
    my $table = shift;
    my $hash = shift;
    open(my $f1, "<$table") or return();
    my $header = <$f1>;
    chomp $header; $header =~ s/\r//g;
    my @header = split(/\t/, $header);
    my @row_order;
    my @error;
    while (my $line = <$f1>) {
	chomp $line; $line =~ s/\r//g;
	my @coln = split(/\t/, $line);
	$coln[0] =~ s/^\s+|\s+$//g;
	push(@row_order, $coln[0]);
	if (length($coln[0])==0) {
	    next;
	}
	for (my $i=1; $i<scalar(@header); $i++){
	    if (defined($coln[$i])) {
		if (length($coln[$i])>0) {
		    $hash->{$coln[0]}{$header[$i]}=$coln[$i];
		}
		
	    }
	    
	    
	}
    }
    return(\@row_order, \@header);
}

sub parallel_process_allocation{
    # determine the number of parallel processes for each step.
    my $max_memory_consumption_per_process = shift;
    my $max_memory = `free -m | awk 'FNR == 2 {print \$2}'`; # max memory available in the system in Mb
    chomp($max_memory);
    my $max_core = `nproc`;
    chomp($max_core);
    if ($max_core==1) { # if the system only has one cpu
	return 1;
    }
    
    my $max_core_to_use;
    my $a = $max_core-1;
    my $b = int($max_memory/$max_memory_consumption_per_process);
    if ($a>=$b) {
	$max_core_to_use=$b;
    }else{
	$max_core_to_use=$a;
    }
    if ($max_core_to_use>1) { # save at least two cpu cores for system
	return $max_core_to_use;
    }else{
	return 1; # only one can use
    }
}

sub extract_patient_info{
    my $sample_id = shift;
    my $dir = shift;
    my %patient_info;
    my $patient_file = "$dir/$sample_id/0.patient.info.csv";
    my @header=();
    if (-e $patient_file) {
	open(my $f1, "<$patient_file") or die;
	my $header = <$f1>;
	chomp $header; $header =~ s/\r//g;
	my $line = <$f1>;
	chomp $line; $line =~ s/\r//g;
	my @info;
	
	if ($header =~ /\t/) {
	    @header = split(/\t/, $header);
	    @info = split(/\t/, $line);
	}else{
	    my $csv = Text::CSV->new();
	    $header = decode("UTF-8", $header);
	    my $status = $csv->parse($header);
	    @header = $csv->fields();
	    $line = decode("UTF-8", $line);
	    $status = $csv->parse($line);
	    @info = $csv->fields();
	}
	
	for (my $i=0; $i<scalar(@header); $i++){
	    $info[$i] =~ s/^\s+|\s+$//g;
	    $header[$i] =~ s/^\s+|\s+$//g;
	    $patient_info{$header[$i]}=$info[$i];
	}
    }else{
	print("Warnings:$sample_id does not have patient info; skipped!\n");
    }
    return (\%patient_info, \@header);
}
use strict;
use warnings;
use Spreadsheet::XLSX;


sub parse_pathogen_ref_table{
    my $table = shift;
    my @pathogens;
    my %pathogen_info;
    my @sheet_names = qw(Bacteria Fungi Parasites);
    foreach my $i (@sheet_names){
	my @sp = parse_excel_table($table, $i, \%pathogen_info);
	push(@pathogens, @sp);
    }
    return(\@pathogens, \%pathogen_info);
}

sub parse_excel_table {
    my ($excel_file, $sheet_name, $table_data) = @_;

    # Open the Excel file
    my $excel = Spreadsheet::XLSX->new($excel_file);

    # Find the sheet by name
    my $sheet;
    foreach my $worksheet (@{$excel->{Worksheet}}) {
        if ($worksheet->{Name} eq $sheet_name) {
            $sheet = $worksheet;
            last;
        }
    }

    # If the sheet is not found, return an error
    unless ($sheet) {
        die "Sheet '$sheet_name' not found in the Excel file.\n";
    }

    # Extract column titles from the first row
    my @column_titles;
    $sheet->{MaxCol} ||= $sheet->{MinCol};  # Ensure MaxCol is defined
    for my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
        my $cell = $sheet->{Cells}[0][$col];  # First row (row 0)
        push @column_titles, $cell ? $cell->{Val} : '';
    }

    # Initialize the output structures
    my @species_list;

    # Iterate over each row starting from the second row
    for my $row ($sheet->{MinRow} + 1 .. $sheet->{MaxRow}) {
        my $species_name = $sheet->{Cells}[$row][0] ? $sheet->{Cells}[$row][0]->{Val} : '';
        push @species_list, $species_name;

        # Populate the hash with the species name as the first key
        # and the column title as the second key
        for my $col ($sheet->{MinCol} + 1 .. $sheet->{MaxCol}) {
            my $column_title = $column_titles[$col];
            my $cell_value = $sheet->{Cells}[$row][$col] ? $sheet->{Cells}[$row][$col]->{Val} : '';
            $table_data->{$species_name}{$column_title} = $cell_value;
        }
    }

    return (@species_list);
}
1;
