$input = $ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4],$ARGV[5];
print "perl features_select.pl $ARGV[0] $ARGV[1] > selected.txt
perl transposition.pl selected.txt > selected_tmp
perl format_transform_SVM_singlefile_title.pl selected_tmp $ARGV[3] > selected_train_tmp
rm selected.txt selected_tmp 
./svm-train -v $ARGV[4] selected_train_tmp > $ARGV[2]
./svm-train selected_train_tmp $ARGV[5]
rm selected_train_tmp
";
