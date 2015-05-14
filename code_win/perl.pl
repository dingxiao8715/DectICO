$input = $ARGV[0],$ARGV[1];

print "#!/usr/bin/perl\n`perl features_select.pl $ARGV[0] $ARGV[1] > fea.txt`;";