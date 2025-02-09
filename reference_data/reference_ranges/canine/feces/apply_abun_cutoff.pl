#!/usr/bin/perl
#use strict;
#use warnings;

use vars qw($opt_i $opt_t $opt_o);
&Getopts('i:t:o:');

my %abun;
my @coln_order;
my @taxa_order;
my $input_table = $opt_i;
my $threshold = 0.001;
if ($opt_t) {
    $threshold = $opt_t;
}


open(my $f1, "<$input_table") or die;
my $header = <$f1>;
my %sum;
read_abun_table($f1, \%abun, \@coln_order, \@taxa_order, \%sum);
close $f1;
normalization(\%abun, \%sum);
filtration(\%abun, $threshold, \%sum);
normalization(\%abun, \%sum);
my $output_table = "new_$input_table";
open(my $f2, ">$opt_o") or die;
print($f2 "$header");
write_abun_table($f2, \%abun, \@coln_order, \@taxa_order);
close $f2;

sub normalization{
    my $abun = shift;
    my $sum = shift;
    foreach my $taxa (keys(%{$abun})){
        foreach my $sample (keys(%{$abun->{$taxa}})){
            my $total_abun = $sum->{$sample};
            my $value = $abun->{$taxa}->{$sample};
            if ($total_abun>0) {
                $value = $value/$total_abun;
            }
            $abun->{$taxa}->{$sample} = $value;
        }
    }
    foreach my $i (keys(%{$sum})){
        $sum->{$i}=1;
    }
}

sub filtration{
    my $abun = shift;
    my $threshold = shift;
    my $sum = shift;
    my %taxa_sum;
    foreach my $taxa (keys(%{$abun})){
        foreach my $sample (keys(%{$abun->{$taxa}})){
            my $value = $abun->{$taxa}->{$sample};
            if ($value<$threshold) {
                delete($abun->{$taxa}->{$sample});
                $sum->{$sample} -= $value;
            }else{
                $taxa_sum{$taxa}+=$value;
            }
        }
    }
    foreach my $taxa (keys(%{$abun})){
        if (exists($taxa_sum{$taxa})) {
            
        }else{
            delete($abun->{$taxa});
        }
        
    }
}

sub read_abun_table{
    my $f1 = shift;
    my $abun = shift;
    my $coln_order = shift;
    my $taxa_order = shift;
    my $sum = shift;
    while (my $line = <$f1>) {
        chomp $line;
        my @coln = split(/\t/, $line);
        if ($line =~ /^#/) {
            foreach my $i (@coln){
                push (@{$coln_order}, $i);
            }
        }else{
            my $taxa = $coln[0];
            if ($taxa =~ /^None;|^k__Plantae;/) {
                next;
            }
            push(@{$taxa_order}, $taxa);
            for (my $i=1; $i<scalar(@{$coln_order}); $i++){
                my $value = $coln[$i];
                my $sample_id = $coln_order->[$i];
                if ($value>0) {
                    $abun->{$taxa}->{$sample_id}=$value;
                    $sum->{$sample_id}+=$value;
                }
            }
        }
        
    }
}

sub write_abun_table{
    my $f2 = shift;
    my $abun = shift;
    my $coln_order = shift;
    my $taxa_order = shift;
    my $header = join("\t", @{$coln_order});
    print($f2 "$header\n");
    foreach my $i (@{$taxa_order}){
        if (! exists($abun->{$i})) {
            next;
        }
        my @coln = ($i);
        foreach my $j (@{$coln_order}){
            my $value = 0;
            if (exists($abun->{$i}->{$j})) {
                $value = $abun->{$i}->{$j};
            }
            push(@coln, $value);
        }
        my $line = join("\t", @coln);
        print($f2 "$line\n");
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
