#!/usr/bin/perl

package SanityCheck;

sub check_inputs{
    my $samples=shift;
    my $input_dir = shift;
    my $die = 0;
    foreach my $i (@{$samples}){
	if (-d "$input_dir/$i") {
	    
	}else{
	    print("Input files of sample $i are not found!\n");
	    $die = 1;
	}
	
    }
    if ($die == 1) {
	die("Sanity_check failed!\n");
    }
    
}


1;
