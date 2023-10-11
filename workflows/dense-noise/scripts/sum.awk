
# SUM AWK

# Sum of 1st column

BEGIN {
  total = 0
}

{ total = total + $1 }

END {
  print(total)
}
