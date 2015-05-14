#!/usr/bin/perl
die "perl $0 <fasta.list> <kmer> <1_for_kc/2_for_kr_kb> > output.xls\n" if(@ARGV != 3);
my $fna_lst=shift;
my $kmer=shift;
my $choose=shift;

my $id=0;
open(LST,$fna_lst) || die;
while(my $line=<LST>){
        my $whole_head;
        my $whole_content;
        chomp $line;
        $id++;
        if($choose==1){
                `perl sample_feature_calcuation.pl -f $line -kc $kmer -model 1,0,0 -o $id.xls`;
                open(XLS,"$id.xls") || die;
                if($id>1){
                        <XLS>;
                        $whole_content=<XLS>;
                        print $whole_content;
                }
                else{
                        $whole_head=<XLS>;
                        $whole_content=<XLS>;
                        print $whole_head;
                        print $whole_content;
                }
                close XLS;
                `del $id.xls`;
        }

        elsif($choose==2){
                if($id>1){
                        foreach (1..$kmer-1){   #kr
                                my $krt=$kmer-$_;
                                `perl sample_feature_calcuation.pl -f $line -kr $kmer -krh $_ -krt $krt -model 0,1,0 -o $id.xls`;
                                open(XLS,"$id.xls") || die;
                                my $head=<XLS>;
                                my $content=<XLS>;
                                chomp $content;
                                if($_==1){
                                }
                                else{
                                        $content=del_first_column($content);
                                }
                                $whole_content.=$content;
                                close XLS;
                                `del $id.xls`;
                        }
                        foreach (1..int($kmer/2)){
                                my $kbt=$kmer-$_;
                                `perl sample_feature_calcuation.pl -f $line -kb $kmer -kbh $_ -kbt $kbt -model 0,0,1 -o $id.xls`;
                                open(XLS,"$id.xls") || die;
                                my $head=<XLS>;
                                my $content=<XLS>;
                                chomp $content;
                                $content=del_first_column($content);
                                $whole_content.=$content;
                                close XLS;
                                `del $id.xls`;
                        }
                        print $whole_content,"\n";
                }
                else{
                        foreach (1..$kmer-1){   #kr
                                my $krt=$kmer-$_;
                                `perl sample_feature_calcuation.pl -f $line -kr $kmer -krh $_ -krt $krt -model 0,1,0 -o $id.xls`;
                                open(XLS,"$id.xls") || die;
                                my $head=<XLS>;
                                my $content=<XLS>;
                                chomp $head;
                                chomp $content;
                                if($_==1){
                                }
                                else{
                                        $head=del_first_column($head);
                                        $content=del_first_column($content);
                                }
                                $whole_head.=$head;
                                $whole_content.=$content;
                                close XLS;
                                `del $id.xls`;
                        }
                        foreach (1..int($kmer/2)){
                                my $kbt=$kmer-$_;
                                `perl sample_feature_calcuation.pl -f $line -kb $kmer -kbh $_ -kbt $kbt -model 0,0,1 -o $id.xls`;
                                open(XLS,"$id.xls") || die;
                                my $head=<XLS>;
                                my $content=<XLS>;
                                chomp $head;
                                chomp $content;
                                $head=del_first_column($head);
                                $content=del_first_column($content);
                                $whole_head.=$head;
                                $whole_content.=$content;
                                close XLS;
                                `del $id.xls`;
                        }
                        print $whole_head,"\n";
                        print $whole_content,"\n";

                }
        }
        else{
                die "the third parameter must set as 1 or 2\n";
        }
}

sub del_first_column{
        my $in=shift;
        my @arr=split/\s+/,$in;
        shift @arr;
        my $out=join"\t",@arr;
        $out.="\t";
        return $out;
}
