
# EXTRACT HOLDOUT ERRORS AWK
# Finds this data in the python.log and reports a summary of it:
# 2020-07-07 14:38:50 Comparing y_true and y_pred:
# 2020-07-07 14:38:50   mse: 0.0063
# 2020-07-07 14:38:50   mae: 0.0541
# 2020-07-07 14:38:50   r2: 0.7352
# 2020-07-07 14:38:50   corr: 0.8590

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
