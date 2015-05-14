#!/usr/bin/perl
my $all_feature=shift;
my $selected_feature=shift;
my %feature;
my $title;
open (ALL_FEATURE, $all_feature) || die "can't open $all_feature";
$title = <ALL_FEATURE>;
chomp $title;
while (<ALL_FEATURE>){
	chomp;
	my @feature=split/\t/;
	my $feature_name=shift @feature;
	my $feature_value=join "\t",@feature;
	$feature{$feature_name}=$feature_value;
}
close ALL_FEATURE;
print "$title\n";
open (SELECTED_FEATURE, $selected_feature) || die "can't open $selected_feature";
while (<SELECTED_FEATURE>){
	chomp;
	if (exists $feature{$_}){
		print "$_\t$feature{$_}\n";
	}
}
close SELECTED_FEATURE;

