
# DISTILL HOLDOUT ERRORS PL
# Original holdout error plotting scripts from Brettin
#          Slack #cp-leaveout 2020-07-24
# Input:  holdout-errors.txt from extract-holdout-errors
# Output: Plottable file for plot-holdout-errors.py

$class = uc(shift @ARGV);
if($class eq "MSE") {$idx=1}
elsif($class eq "MAE") {$idx=2}
elsif($class eq "R2") {$idx=3}
else {die "invalid arg, usage: $0 MSE|MAE|R2"}
while(<>){
    chomp;
    s/mse://;
    s/mae://;
    s/r2://;
    @a=split/\s+/;
    $a[0]=~s/\s+//g;
    $h{$a[0]}=$a[$idx];
}
foreach $s (sort keys %h) {
    if ( $s=~/1\.(\d)\.(\d)\.(\d)\.(\d)\.(\d)/ ) {
        #print "1.$1", "\n";
        print $h{"1.$1"}, "\t";
        print $h{"1.$1.$2"}, "\t";
        print $h{"1.$1.$2.$3"}, "\t";
        print $h{"1.$1.$2.$3.$4"}, "\t";
        print $h{"1.$1.$2.$3.$4.$5"}, "\t";
        print "$class\n";
    }
}
