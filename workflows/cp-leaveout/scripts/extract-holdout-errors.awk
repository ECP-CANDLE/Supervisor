
# EXTRACT HOLDOUT ERRORS AWK
# Finds error data in the python.log and reports a summary of it:

# Input:
# 2020-07-07 14:38:50 Comparing y_true and y_pred:
# 2020-07-07 14:38:50   mse: 0.0063
# 2020-07-07 14:38:50   mae: 0.0541
# 2020-07-07 14:38:50   r2: 0.7352
# 2020-07-07 14:38:50   corr: 0.8590

# Output:
# 1.1          mse: 0.0063 mae: 0.0538 r2: 0.7322
# 1.1.1        mse: 0.0053 mae: 0.0492 r2: 0.7745
# 1.1.1.1      mse: 0.0050 mae: 0.0480 r2: 0.7864
# 1.1.1.1.1    mse: 0.0050 mae: 0.0473 r2: 0.7900
# 1.1.1.1.1.1  mse: 0.0049 mae: 0.0469 r2: 0.7930
# 1.1.1.1.1.2  mse: 0.0049 mae: 0.0470 r2: 0.7930

$3 == "Comparing" {
  getline
  mse = $3 " " $4
  getline
  mae = $3 " " $4
  getline
  r2 = $3 " " $4
  printf "%-12s %s %s %s\n", node, mse, mae, r2
  exit
}
