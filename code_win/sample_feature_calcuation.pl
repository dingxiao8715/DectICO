#!/usr/bin/perl
#fix some bugs in Kmer content statistics
#20120603:fix one bug : illigeal division by zero
#20120611:fix one bug : when kbt is unequal to kbh
#20120827:fix one bug : add default values
#20131231:for sample calculation
#latest : print all kmers
use strict;
use Getopt::Long;

my $HELP="
Usage:
      perl $0 -f fasta.fa -kc Kmer_C -kr Kmer_R -krh Kmer_R_head -krt Kmer_R_tail
              -model out_model -o output_file
      -f : string
           input sequence file in fasta format
      -kc : int (defaule : 4)
           the Kmer length for the statistics of Kmer frequency
      -kr :int (default :4 )
           the Kmer length for the statistics of related information
      -krh : int (default : 2)
           the head length of Kmer for the statistics of related information
      -krt : int (default : 2)
           the tail length of Kmer for the statistics of related information
      -kb : int (default :4 )
           the Kmer length for the statistics of BBC value
      -kbh : int (default : 2)
           the head length of Kmer for the statistics of BBC value
      -kbt : int (default : 2)
           the tail length of Kmer for the statistics of BBC value
      -model : string 0/1,0/1,0/1;   default 1,0,0
           content
           MI
           DRA
      -o : string
           the output file name
";
die $HELP if(@ARGV <4 );

my @four=("A","T","C","G");

my $fa;
my $kc=4;
my $kr=4;
my $krh=2;
my $krt=2;
my $kb=4;
my $kbh=2;
my $kbt=2;
my $model="1,0,0";
my $file_out_name;

GetOptions(
    "f:s"=>\$fa,
    "kc:i"=>\$kc,
    "kr:i"=>\$kr,
    "krh:i"=>\$krh,
    "krt:i"=>\$krt,
    "kb:i"=>\$kb,
    "kbh:i"=>\$kbh,
    "kbt:i"=>\$kbt,
    "model:s"=>\$model,
    "o:s"=>\$file_out_name
);

if($krh+$krt != $kr or $kbh+$kbt != $kb){
    warn "kmer length must equal to head length plus tail length\n";
    print "kr: ",$kr,"\tkrh: ",$krh,"\tkrt: ",$krt,"\n";
    print "kb: ",$kb,"\tkbh: ",$kbh,"\tkbt: ",$kbt,"\n";
    die;
}

my @index=split/,/,$model;
#test
print "model:\t",$model,"\n";
my $vector_length;

open(OUT,">$file_out_name") || die ("can not write to $file_out_name");
print OUT "file_name\t";

my @four=("A","C","G","T");

my @content_kmer=creat_K_mer($kc);
my @related_kmer=creat_K_mer($kr);
my @related_info_head_kmer=creat_K_mer($krh);
my @related_info_tail_kmer=creat_K_mer($krt);
my @bbc_kmer=creat_K_mer($kb);

my %comple;
foreach my $k_tmp (@content_kmer){
            my $complement=reverse $k_tmp;
            $complement=~tr/ATCG/TAGC/;
            my @pair=($k_tmp,$complement);
            @pair=sort @pair;
            $comple{$pair[0]}=$pair[1];
}

my @stat_content_kmer=sort keys %comple;

my @stat_bbc_kmer;

if($kbh == $kbt){
    my %comple;
    foreach my $k_tmp (@bbc_kmer){
        my $complement=reverse $k_tmp;
        $complement=~tr/ATCG/TAGC/;
        my @pair=($k_tmp,$complement);
        @pair=sort @pair;
        $comple{$pair[0]}=$pair[1];
    }
    @stat_bbc_kmer=sort keys %comple;
}
else{
    @stat_bbc_kmer=sort @bbc_kmer;
}

#content
if($index[0]){
    foreach (@stat_content_kmer){
        $vector_length++;
        print OUT $_,"\t";
    }
    print "content:\t",$#stat_content_kmer+1,"\n";
}

#MI
if($index[1]){
    foreach (@related_info_head_kmer){
        $vector_length++;
        print OUT $_,"\t";
    }
    print "MI:\t",$#related_info_head_kmer+1,"\n";
}

#BBC
my $kb_info=$kbh."-".$kbt;
if($index[2]){
    foreach (@stat_bbc_kmer){
        $vector_length++;
        print OUT $kb_info,"_",$_,"\t";
    }
    print "bbc:\t\t",$#stat_bbc_kmer+1,"\n";
}
print OUT "\n";
print "Vector length:\t",$vector_length,"\n";

my %all_seq;
my $seq_id=0;
open(FA,$fa) || die  ("can not read $fa\n");
$/=">";
<FA>;
while(my $block=<FA>){
            chomp $block;
            my @lines=split/\n/,$block;
            my $first=shift @lines;
        $seq_id++;
            my $seq=join"",@lines;
            $seq=~tr/atcg/ATCG/;
        $all_seq{$seq_id}=$seq;
}

#id
print OUT $file_out_name,"\t";
#content
if($index[0]){
	my %freq=content_stat();
        my @print_out;
               foreach my $con_kmer (@stat_content_kmer){
                    push(@print_out,$freq{$con_kmer});
        }
        @print_out=normal(@print_out);
        foreach (@print_out){
                      print OUT $_,"\t";
               }
}


#correlation & information
if($index[1]){
        my %pro=related_pro_stat();
        my @print_out;
        foreach (@related_info_head_kmer){
                push(@print_out,$pro{$_});
        }
        @print_out=normal(@print_out);
        foreach (@print_out){
                print OUT $_,"\t";
        }
}


#bbc
if($index[2]){
        my %bbc=bbc_stat();
        my @print_out;
        foreach (@stat_bbc_kmer){
                push(@print_out,$bbc{$_});
        }
        @print_out=normal(@print_out);
        foreach (@print_out){
                print OUT $_,"\t";
        }
}

print OUT "\n";



sub content_stat{     #right version; latest 2013.12.30
        my %kmer_num;
        foreach my $i (keys %all_seq){
                my $seq=$all_seq{$i};
                    foreach(1..length($seq)-$kc+1){
                        my $substring=substr($seq,$_-1,$kc);
                        $kmer_num{$substring}++;
                    }
                    $seq=~tr/ATCG/TAGC/;
                    $seq=reverse $seq;
                    foreach(1..length($seq)-$kc+1){
                        my $substring=substr($seq,$_-1,$kc);
                        $kmer_num{$substring}++;
                    }
        }
            my %freq;
            my $real_total_num;
            foreach (@stat_content_kmer){
                $real_total_num+=$kmer_num{$_};
            }
            foreach (@stat_content_kmer){
                $freq{$_}=$kmer_num{$_}/$real_total_num;
            }
            return %freq;
}




sub related_pro_stat{
        my %kmer=count_k_freq($kr);
        my %kmer_head=count_k_freq($krh);
        my %kmer_tail=count_k_freq($krt);
        my %kmer_corr;
        my %kmer_corr_num;
        foreach my $i (keys %all_seq){
                my $seq=$all_seq{$i};
                    foreach(1..length($seq)-$kr+1){
                        my $substring=substr($seq,$_-1,$kr);
                        if($substring =~ /[^ATCGatcg]/){
                                next;
                        }
                        my $head_tmp=substr($substring,0,$krh);
                        my $tail_tmp=substr($substring,$krh,$krt);
                        $kmer_corr{$head_tmp}{$tail_tmp}++;
                        $kmer_corr_num{$head_tmp}++;
                    }
                    $seq=reverse $seq;
                    $seq=~tr/ATCG/TAGC/;
                    foreach(1..length($seq)-$kr+1){
                        my $substring=substr($seq,$_-1,$kr);
                        if($substring =~ /[^ATCGatcg]/){
                                next;
                        }
                        my $head_tmp=substr($substring,0,$krh);
                        my $tail_tmp=substr($substring,$krh,$krt);
                        $kmer_corr{$head_tmp}{$tail_tmp}++;
                        $kmer_corr_num{$head_tmp}++;
                    }
        }
            my %related_pro;      #return 1
            foreach my $r_kmer (@related_kmer){
                my $head_tmp=substr($r_kmer,0,$krh);
                my $tail_tmp=substr($r_kmer,$krh,$krt);
                if($kmer_corr_num{$head_tmp}){
                            $related_pro{$r_kmer}=$kmer_corr{$head_tmp}{$tail_tmp};
                            $related_pro{$r_kmer}/=$kmer_corr_num{$head_tmp};
                }
                else{
                            $related_pro{$r_kmer}=0;
                }
            }

            foreach my $head_tmp (@related_info_head_kmer){
                my $sum;
                if($kmer_head{$head_tmp}==0){
                            $related_pro{$head_tmp}=0;
                            next;
                }
                foreach my $tail_tmp (@related_info_tail_kmer){
                            if($kmer_tail{$tail_tmp}==0){
                                next;
                            }
                            my $whole_kmer=$head_tmp.$tail_tmp;
                            if($kmer{$whole_kmer}==0){
                                next;
                            }
                            my $pro_1=$related_pro{$whole_kmer};
                            if($pro_1==0){
                                next;
                            }
                            if($kmer{$whole_kmer}==0){
                                next;
                            }
                            my $pro_2=(log($kmer{$whole_kmer})/log(2));
                            if($kmer_head{$head_tmp}==0 or $kmer_tail{$tail_tmp}==0){
                                next;
                            }
                            $pro_2-=(log($kmer_head{$head_tmp}*$kmer_tail{$tail_tmp})/log(2));
                            my $info_value=$pro_1*$pro_2;
                            $sum+=$info_value;
                }
                $related_pro{$head_tmp}=$sum;
            }
            return %related_pro;
}


sub creat_K_mer{
            my $k=shift;
            die "K must be int greater than 0\n" if ($k<1);
            if($k==1){
                return @four;
            }
            else{
                my @out;
                my @low=creat_K_mer($k-1);
                foreach my $f (@four){
                            foreach my $l_kmer(@low){
                                push(@out,$f.$l_kmer);
                            }
                }
                return @out;
            }
}

sub count_k_freq{
        my $k=shift;
        my %k_q;
        my $total_num;
        foreach my $i (keys %all_seq){
                my $seq=$all_seq{$i};
                    foreach(1..length($seq)-$k+1){
                        my $substring=substr($seq,$_-1,$k);
                        if($substring =~ /[^ATCGatcg]/){
                                next;
                        }
                        else{
                                $total_num++;
                                $k_q{$substring}++;
                        }

                    }
                    $seq=reverse $seq;
                    $seq=~tr/ATCG/TAGC/;
                    foreach(1..length($seq)-$k+1){
                        my $substring=substr($seq,$_-1,$k);
                        if($substring =~ /[^ATCGatcg]/){
                                next;
                        }
                        else{
                                $total_num++;
                                $k_q{$substring}++;
                        }
                    }
        }
            foreach (keys %k_q){
                $k_q{$_}/=$total_num;
            }
            return %k_q;
}

sub normal{
        my @in=@_;
        my @out;
        my @in_copy = sort {$a<=>$b} @in;
        my $max=$in_copy[-1];
        my $min=$in_copy[0];
        foreach (@in){
                my $tmp=($_-$min)/($max-$min);
                push(@out,$tmp);
        }
        return @out;
}
sub bbc_stat{         #right version; latest 2012.6.1
            my %kmer=count_k_freq($kb);
            my %kmer_head=count_k_freq($kbh);
            my %kmer_tail=count_k_freq($kbt);
            my %out;
            foreach my $b_kmer(@stat_bbc_kmer){
                my $head=substr($b_kmer,0,$kbh);
                my $tail=substr($b_kmer,$kbh,$kbt);
                $out{$b_kmer}=$kmer{$b_kmer};
                if($kmer_head{$head}==0 or $kmer_tail{$tail}==0){
                            $out{$b_kmer}=0;
                            next;
                }
                $out{$b_kmer}/=$kmer_head{$head};
                $out{$b_kmer}/=$kmer_tail{$tail};
            }
            return %out;
}
