$input = $ARGV[0];

print "#!/usr/bin/perl\n`perl transposition.pl $ARGV[0] > tr.txt`;";