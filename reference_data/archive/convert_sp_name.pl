#use strict;
#use warnings;


use vars qw($opt_i $opt_o $opt_r);
&Getopts('i:o:r:');
open(my $f1, "<$opt_i") or die;
open(my $f2, ">$opt_o") or die;
my @sp;
my %sp_abun;
my $header = <$f1>;
chomp $header;
while (my $line = <$f1>) {
    chomp $line;
    my @coln = split(/\,/, $line);
    my $sp = extract_species_name($coln[0]);
    if (exists($sp_abun{$sp})) {
        my $C1 = $sp_abun{$sp}{'C1'};
        my $C2 = $sp_abun{$sp}{'C2'};
        if ($C1 eq 'Unknown' || $coln[1] eq 'Unknown') {
            $sp_abun{$sp}{'C1'} = 'Unknown';
            $sp_abun{$sp}{'C2'} = 'Unknown';
            next;
        }
        if ($C2 eq 'Unknown' || $coln[2] eq 'Unknown') {
            $sp_abun{$sp}{'C1'} = 'Unknown';
            $sp_abun{$sp}{'C2'} = 'Unknown';
            next;
        }
        
        if (($coln[1] eq 'Infinity') || ($C1 eq 'Infinity')) {
            $sp_abun{$sp}{'C1'} = 'Infinity';
        }else{
            $sp_abun{$sp}{'C1'} += $coln[1];
        }
        if (($coln[2] eq 'Infinity') || ($C2 eq 'Infinity')) {
            $sp_abun{$sp}{'C2'} = 'Infinity';
        }else{
            $sp_abun{$sp}{'C2'} += $coln[2];
        }
        
    }else{
        $sp_abun{$sp}{'C1'} = $coln[1];
        $sp_abun{$sp}{'C2'} = $coln[2];
        if ($sp_abun{$sp}{'C2'} eq 'Inf') {
            my $x=0;
        }
        
        push(@sp, $sp);
        
    }
}

print($f2 "$header\n");

my %rrna_copy_db;
my $rrna_db = $opt_r;
read_rrna_db($rrna_db, \%rrna_copy_db);

my $default_16S_cp_per_genome = 3;
foreach my $sp (@sp){
    my $C1 = $sp_abun{$sp}{'C1'};
    #$C1 = copy2cell($C1, $sp, $default_16S_cp_per_genome, \%rrna_copy_db);
    my $C2 = $sp_abun{$sp}{'C2'};
    #$C2 = copy2cell($C2, $sp, $default_16S_cp_per_genome, \%rrna_copy_db);
    print($f2 "$sp,$C1,$C2\n");
}


sub extract_species_name{
    my $lineage = shift;
    my @ranks = split(/;/, $lineage);
    my $genus='';
    my $species='';
    foreach my $i (reverse(@ranks)){
	if ($i =~ /^s__/) {
	    $species = substr($i, 3, length($i)-3);
	    if ($species =~ /^sp[0-9]/) {
		$species = 'sp.';
	    }elsif($species eq 'NA'){
		$species = 'sp.';
	    }
	    
	}elsif ($i =~ /^g__/) {
	    $genus = substr($i, 3, length($i)-3);
	    if ($genus eq 'NA') {
		$genus='';
	    }elsif($genus =~ /\-/){
		$genus='';
	    }else{
		return("$genus $species");
	    }
	    
	    
	}else{
	    $genus = substr($i, 3, length($i)-3);
	    my $rank = substr($i,0,1);
	    if ($genus eq 'NA') {
		$genus = '';
	    }else{
		return("($rank)$genus $species");
	    }
	    
	}
    }
    
    
}

sub copy2cell{
    my $abs = shift;
    my $sp = shift;
    my $default_copies_per_genome = shift;
    my $rna_copy_dict = shift;
    my $copies_per_genome=$default_copies_per_genome;
    my @sp = split(/\-|\ /, $sp);
    my $genus = shift(@sp);
    my $sum=0;
    my $num=0;
    foreach my $i (@sp){
	if (exists($rna_copy_dict->{"$genus $i"})) {
	    my $copies = $rna_copy_dict->{"$genus $i"};
	    $sum+=$copies;
	    $num++;
	}
    }
    
    if ($num>0) {
	$copies_per_genome = $sum/$num;
    }
    
    my $new_abs = int($abs/$copies_per_genome);
    return ($new_abs);
}

sub read_rrna_db{
    my $db_file = shift;
    my $dict = shift;
    if (-e $db_file) {
	open(my $f1, "<$db_file") or die;
	while (my $line = <$f1>) {
	    chomp $line;
	    if ($line !~ /^#/) {
		my @coln = split(/\t/, $line);
		$dict->{$coln[0]}=$coln[1];
	    }
	}
    }
    
    
}

sub Getopts {
    local($argumentative) = @_;
    local(@args,$_,$first,$rest);
    local($errs) = 0;
    @args = split( / */, $argumentative );
    while(@ARGV && ($_ = $ARGV[0]) =~ /^-(.)(.*)/) {
		($first,$rest) = ($1,$2);
		$pos = index($argumentative,$first);
		if($pos >= 0) {
			if($args[$pos+1] eq ':') {
				shift(@ARGV);
				if($rest eq '') {
					++$errs unless(@ARGV);
					$rest = shift(@ARGV);
				}
				eval "
				push(\@opt_$first, \$rest);
				if (!defined \$opt_$first or \$opt_$first eq '') {
					\$opt_$first = \$rest;
				}
				else {
					\$opt_$first .= ' ' . \$rest;
				}
				";
			}
			else {
				eval "\$opt_$first = 1";
				if($rest eq '') {
					shift(@ARGV);
				}
				else {
					$ARGV[0] = "-$rest";
				}
			}
		}
		else {
			print STDERR "Unknown option: $first\n";
			++$errs;
			if($rest ne '') {
				$ARGV[0] = "-$rest";
			}
			else {
				shift(@ARGV);
			}
		}
	}
    $errs == 0;
}