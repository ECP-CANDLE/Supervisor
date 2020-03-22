
# TIME NVM AWK

# See time-nvm.sh

BEGIN {
  total = 0;
}

{ total = total + $3; }

END {
  print(total / NR);
}
