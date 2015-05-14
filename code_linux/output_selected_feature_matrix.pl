#!/usr/bin/perl
my $feature_matrix=shift;
my $feature_selected=shift;
my $out=shift;
`perl transposition.pl $feature_matrix > tmp`;
`perl features_select.pl tmp $feature_selected > out_tmp`;
`perl transposition.pl out_tmp > $out`;
`rm tmp`;
`rm out_tmp`; 
