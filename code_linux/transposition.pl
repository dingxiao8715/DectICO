#!/usr/bin/perl

my $file = shift;
open (FILE,$file) || die "Can't open $file";
my @arr;
my $max_col=0;
my $row = 0;
while (<FILE>) {
    chomp;
    my @data = split /\s+/;
    my $col = 0;
    foreach ( @data ) {
        $arr[$row][$col] = $_;
        $col++;
    }
    if($col>$max_col){
        $max_col=$col;
    }
    $row++;

}
for my $c (0..$max_col-1){
    for my $r (0..$row){
        print $arr[$r][$c],"\t";
    }
    print "\n";
}
