
# TIME NVM AWK

# See time-nvm.sh

BEGIN {
  total = 0;
}

{ total = total + $4; }

END {
  print(total / NR);
}
