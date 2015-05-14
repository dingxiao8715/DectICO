#!/usr/bin/perl
use warnings;

my $filename = shift;
my $pos =shift;
my $l=1;

open(FILE, $filename) || die "Could not read from $filename";
<FILE>;while(<FILE>){
        chomp;
        my @seq=split(/\s+/,$_);
        my $sample_name=shift @seq;
        my $i=1;
        foreach my $seq (@seq){
        $seq= "$i:$seq";$i++;
        }
        my $new_seq=join("\t",@seq);
        if ($l < $pos+1){
             print "1 ",$new_seq,"\n";
        }
        else{
             print "-1 ",$new_seq,"\n";
        }
        $l++;
}
close FILE;