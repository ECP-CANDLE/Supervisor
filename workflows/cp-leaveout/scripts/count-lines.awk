#!/usr/bin/awk -f

# COUNT LINES AWK
# Like cat, but counts lines and time

BEGIN {
  t0 = systime()
  count = 0
}

{
  print $0
  count++
}

END {
  t1 = systime()
  duration = t1 - t0
  if (duration == 0)
    rate = "infinity"
  else
    rate = count/duration
  print "count:", count, "in", duration, "seconds. rate:", rate \
    > "/dev/stderr"
}
