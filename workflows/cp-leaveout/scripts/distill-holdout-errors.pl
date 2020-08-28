
# DISTILL HOLDOUT ERRORS PL
# Original holdout error plotting scripts from Brettin
#          Slack #cp-leaveout 2020-07-24
# Uses stdin/stdout
# Input:  holdout-errors.txt from extract-holdout-errors
# Output: Plottable TSV file for plot-holdout-errors.py

$stages = uc(shift @ARGV);
$class  = uc(shift @ARGV);
# Select error type for this run
# (index is the column in the data after removing text tokens):
if    ($class eq "MSE") {$idx=1}
elsif ($class eq "MAE") {$idx=2}
elsif ($class eq "R2" ) {$idx=3}
else {die "usage: $0 <STAGES> MSE|MAE|R2"}

while(<>){
    chomp;
    # Remove readability tokens:
    s/mse://;
    s/mae://;
    s/r2://;
    # Split on WS:
    @a=split/\s+/;
    # h: The big Perl hash of all the data
    #    Maps node ID to the selected error type value:
    $h{$a[0]}=$a[$idx];
}

# Suppresses a warning about the ~~ operator below:
use experimental 'smartmatch';

# Plot one line for each "leaf" node - a node ID with no children
foreach $id (sort keys %h) {
    # Loop if there are any children of this node in the hash
    if (/$id\./ ~~ %h) { next; }

    # Construct a line for the output TSV via prepend:
    # Gets the parent ids for each id (drops 2 trailing chars)
    #      until the id is too short
    @line = ();
    for ( ; length $id > 2 ; $id = substr $id, 0, -2) {
        unshift(@line, "$h{$id}\t");
    }
    # Fill in any missing stages (pandas can handle a blank value):
    while (scalar @line < $stages) {
        push(@line, "\t");
    }
    push(@line, $class);
    print(@line, "\n");
}
