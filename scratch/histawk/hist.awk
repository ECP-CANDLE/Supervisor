
# HIST AWK
# See hist.sh for usage

# NOTE: we redefine the record separator (RS) to comma
# C is the the array of counts for each token

BEGIN {
  RS = ","
  for (i = 0; i < 10000; i++) {
    C[i] = 0;
  }
}

{ 
  C[$0] = C[$0]+1;
}

END {
  for (i = 0; i < 10000; i++) {
    # Only print non-zeros for now
    if (C[i] != 0) {
      print(i, C[i]);
    }
  }
}
